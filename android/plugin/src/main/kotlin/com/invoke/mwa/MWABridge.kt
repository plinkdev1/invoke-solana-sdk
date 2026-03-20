package com.invoke.mwa

import android.app.Activity
import android.util.Base64
import com.solana.mobilewalletadapter.clientlib.ActivityResultSender
import com.solana.mobilewalletadapter.clientlib.MobileWalletAdapter
import com.solana.mobilewalletadapter.clientlib.RpcCluster
import com.solana.mobilewalletadapter.clientlib.TransactionResult
import com.google.gson.Gson
import kotlinx.coroutines.*
import java.util.concurrent.atomic.AtomicBoolean

/**
 * MWABridge.kt
 * Invoke SDK — Coroutine session manager for all MWA operations
 * Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 1
 *
 * CRITICAL PATTERNS (from reference doc):
 * 1. authorize() MUST be called inside EVERY transact() session
 * 2. wallet object is ONLY valid inside the transact() lambda
 * 3. base64 address decoding — account.address is base64, NOT base58
 * 4. One session at a time — AtomicBoolean concurrency guard
 * 5. 60s timeout on all user-facing wallet operations
 */
class MWABridge(
    private val activity: Activity,
    private val cache:    AuthCacheImpl,
    private val onSignal: (name: String, vararg args: Any) -> Unit
) {
    companion object {
        private const val SESSION_TIMEOUT_MS = 60_000L
        private const val TAG = "InvokeMWA"
    }

    private val isSessionActive = AtomicBoolean(false)
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val gson  = Gson()

    // Active wallet package — set when user selects a wallet
    private var activeWalletPackage = "app.phantom"

    // ── Authorize ────────────────────────────────────────────────────────────

    fun authorize(cluster: String, name: String, uri: String, icon: String) {
        if (!isSessionActive.compareAndSet(false, true)) {
            onSignal("mwa_error",
                MWAErrorCodes.SESSION_ALREADY_ACTIVE,
                "A wallet session is already active.")
            return
        }

        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val sender   = ActivityResultSender(activity)
                    val mwa      = MobileWalletAdapter()
                    val rpcCluster = when (cluster) {
                        "mainnet-beta" -> RpcCluster.MainnetBeta
                        "testnet"      -> RpcCluster.Testnet
                        else           -> RpcCluster.Devnet
                    }

                    val result = mwa.transact(sender) { wallet ->
                        val auth = wallet.authorize(
                            identityUri        = android.net.Uri.parse(uri),
                            iconRelativeUri    = android.net.Uri.parse(icon),
                            identityName       = name,
                            rpcCluster         = rpcCluster
                        )

                        // CRITICAL: base64 → bytes → base58
                        // Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 1.3
                        val addressBytes  = Base64.decode(
                            auth.accounts[0].address, Base64.DEFAULT)
                        val addressBase58 = Base58.encode(addressBytes)

                        // Save to cache
                        cache.save(activeWalletPackage, auth.authToken, addressBase58)

                        Pair(auth.authToken, addressBase58)
                    }

                    onSignal("authorized", result.first, result.second)
                }
            } catch (e: TimeoutCancellationException) {
                onSignal("mwa_error", MWAErrorCodes.NETWORK_TIMEOUT,
                    "Wallet operation timed out after 60s.")
            } catch (e: Exception) {
                onSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    // ── Reauthorize ──────────────────────────────────────────────────────────

    fun reauthorize(authToken: String, name: String, uri: String, icon: String) {
        if (!isSessionActive.compareAndSet(false, true)) {
            onSignal("mwa_error",
                MWAErrorCodes.SESSION_ALREADY_ACTIVE,
                "A wallet session is already active.")
            return
        }

        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val sender = ActivityResultSender(activity)
                    val mwa    = MobileWalletAdapter()

                    val result = mwa.transact(sender) { wallet ->
                        val reauth = wallet.reauthorize(
                            identityUri     = android.net.Uri.parse(uri),
                            iconRelativeUri = android.net.Uri.parse(icon),
                            identityName    = name,
                            authToken       = authToken
                        )
                        cache.save(activeWalletPackage, reauth.authToken,
                            cache.load(activeWalletPackage)?.address ?: "")
                        reauth.authToken
                    }

                    onSignal("reauthorized", result)
                }
            } catch (e: Exception) {
                val code = mapErrorCode(e)
                if (code == MWAErrorCodes.AUTH_TOKEN_INVALID) {
                    cache.clear(activeWalletPackage)
                }
                onSignal("mwa_error", code, e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    // ── Deauthorize ──────────────────────────────────────────────────────────

    fun deauthorize(authToken: String) {
        scope.launch {
            try {
                val sender = ActivityResultSender(activity)
                val mwa    = MobileWalletAdapter()
                mwa.transact(sender) { wallet ->
                    wallet.deauthorize(authToken = authToken)
                }
                cache.clear(activeWalletPackage)
                onSignal("deauthorized")
            } catch (e: Exception) {
                onSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            }
        }
    }

    // ── Sign Transactions ────────────────────────────────────────────────────

    fun signTransactions(transactionsB64: Array<String>) {
        if (!isSessionActive.compareAndSet(false, true)) {
            onSignal("mwa_error",
                MWAErrorCodes.SESSION_ALREADY_ACTIVE,
                "A wallet session is already active.")
            return
        }

        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val txBytes = transactionsB64.map {
                        Base64.decode(it, Base64.DEFAULT)
                    }.toTypedArray()

                    val sender = ActivityResultSender(activity)
                    val mwa    = MobileWalletAdapter()

                    val result = mwa.transact(sender) { wallet ->
                        val cached = cache.load(activeWalletPackage)
                            ?: throw Exception("Authorization not valid")
                        val auth = wallet.authorize(
                            identityUri     = android.net.Uri.parse("https://invokequest.dev"),
                            iconRelativeUri = android.net.Uri.parse("favicon.ico"),
                            identityName    = "InvokeQuest",
                            rpcCluster      = RpcCluster.Devnet
                        )
                        wallet.signTransactions(
                            transactions = txBytes
                        )
                    }

                    val signaturesB64 = result.signedPayloads.map {
                        Base64.encodeToString(it, Base64.NO_WRAP)
                    }.toTypedArray()

                    onSignal("transaction_signed", signaturesB64)
                }
            } catch (e: Exception) {
                onSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    // ── Sign And Send Transactions ────────────────────────────────────────────

    fun signAndSendTransactions(transactionsB64: Array<String>, minContextSlot: Int) {
        if (!isSessionActive.compareAndSet(false, true)) {
            onSignal("mwa_error",
                MWAErrorCodes.SESSION_ALREADY_ACTIVE,
                "A wallet session is already active.")
            return
        }

        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val txBytes = transactionsB64.map {
                        Base64.decode(it, Base64.DEFAULT)
                    }.toTypedArray()

                    val sender = ActivityResultSender(activity)
                    val mwa    = MobileWalletAdapter()

                    val result = mwa.transact(sender) { wallet ->
                        wallet.authorize(
                            identityUri     = android.net.Uri.parse("https://invokequest.dev"),
                            iconRelativeUri = android.net.Uri.parse("favicon.ico"),
                            identityName    = "InvokeQuest",
                            rpcCluster      = RpcCluster.Devnet
                        )
                        wallet.signAndSendTransactions(transactions = txBytes)
                    }

                    val signatures = result.signatures.map {
                        Base64.encodeToString(it, Base64.NO_WRAP)
                    }.toTypedArray()

                    onSignal("transaction_sent", signatures)
                }
            } catch (e: Exception) {
                onSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    // ── Sign Messages ────────────────────────────────────────────────────────

    fun signMessages(messagesB64: Array<String>, addressesB64: Array<String>) {
        if (!isSessionActive.compareAndSet(false, true)) {
            onSignal("mwa_error",
                MWAErrorCodes.SESSION_ALREADY_ACTIVE,
                "A wallet session is already active.")
            return
        }

        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val messages   = messagesB64.map {
                        Base64.decode(it, Base64.DEFAULT)
                    }.toTypedArray()
                    val addresses  = addressesB64.map {
                        Base64.decode(it, Base64.DEFAULT)
                    }.toTypedArray()

                    val sender = ActivityResultSender(activity)
                    val mwa    = MobileWalletAdapter()

                    val result = mwa.transact(sender) { wallet ->
                        wallet.authorize(
                            identityUri     = android.net.Uri.parse("https://invokequest.dev"),
                            iconRelativeUri = android.net.Uri.parse("favicon.ico"),
                            identityName    = "InvokeQuest",
                            rpcCluster      = RpcCluster.Devnet
                        )
                        wallet.signMessages(
                            messages  = messages,
                            addresses = addresses
                        )
                    }

                    val signedB64 = result.messages.map {
                        Base64.encodeToString(it, Base64.NO_WRAP)
                    }.toTypedArray()

                    onSignal("message_signed", signedB64)
                }
            } catch (e: Exception) {
                onSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    // ── Get Capabilities ─────────────────────────────────────────────────────

    fun getCapabilities() {
        scope.launch {
            try {
                val sender = ActivityResultSender(activity)
                val mwa    = MobileWalletAdapter()
                val result = mwa.transact(sender) { wallet ->
                    wallet.authorize(
                        identityUri     = android.net.Uri.parse("https://invokequest.dev"),
                        iconRelativeUri = android.net.Uri.parse("favicon.ico"),
                        identityName    = "InvokeQuest",
                        rpcCluster      = RpcCluster.Devnet
                    )
                    wallet.getCapabilities()
                }
                val json = gson.toJson(mapOf(
                    "supports_clone_authorization"        to result.supportsCloneAuthorization,
                    "supports_sign_and_send_transactions" to result.supportsSignAndSendTransactions,
                    "max_transactions_per_request"        to result.maxTransactionsPerSigningRequest,
                    "max_messages_per_request"            to result.maxMessagesPerSigningRequest
                ))
                onSignal("capabilities_received", json)
            } catch (e: Exception) {
                onSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            }
        }
    }

    // ── Get Installed Wallets ─────────────────────────────────────────────────

    fun getInstalledWallets() {
        try {
            val intent = android.content.Intent(
                "com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO")
            val resolveInfo = activity.packageManager
                .queryIntentActivities(intent,
                    android.content.pm.PackageManager.MATCH_ALL)
            val wallets = resolveInfo.map { info ->
                mapOf(
                    "package" to info.activityInfo.packageName,
                    "name"    to info.activityInfo.applicationInfo
                        .loadLabel(activity.packageManager).toString(),
                    "installed" to true
                )
            }
            onSignal("wallet_apps_detected", gson.toJson(wallets))
        } catch (e: Exception) {
            onSignal("wallet_apps_detected", "[]")
        }
    }

    // ── Cache Helpers (exposed to GDScript via plugin) ───────────────────────

    fun cacheHasToken(): Boolean = cache.hasToken(activeWalletPackage)
    fun cacheGetAgeSeconds(): Long = cache.getAgeSeconds(activeWalletPackage)
    fun cacheGetAddress(): String = cache.load(activeWalletPackage)?.address ?: ""
    fun cacheIsStale(): Boolean = cache.isStale(activeWalletPackage)
    fun cacheClear(): Unit = cache.clear(activeWalletPackage)
    fun cacheClearAll(): Unit = cache.clearAll()
    fun setActiveWallet(packageName: String) { activeWalletPackage = packageName }

    // ── Cleanup ──────────────────────────────────────────────────────────────

    fun destroy() {
        scope.cancel()
    }
}
