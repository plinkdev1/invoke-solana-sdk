package com.invoke.mwa

import android.util.Base64
import android.util.Log
import androidx.activity.ComponentActivity
import com.funkatronics.encoders.Base58
import com.solana.mobilewalletadapter.clientlib.*
import com.google.gson.Gson
import kotlinx.coroutines.*
import java.util.concurrent.atomic.AtomicBoolean

class MWABridge(
    private val activity: ComponentActivity,
    private val cache:    AuthCacheImpl,
    private val onSignal: (name: String, args: Array<Any>) -> Unit
) {
    companion object {
        private const val SESSION_TIMEOUT_MS = 60_000L
        private const val TAG = "InvokeMWA"
    }

    private val sender = ActivityResultSender(activity)
    private val isSessionActive = AtomicBoolean(false)
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val gson  = Gson()

    private var activeWalletPackage = "app.phantom"

    private fun signal(name: String, vararg args: Any) {
        onSignal(name, arrayOf(*args))
    }

    private fun buildAdapter(name: String, uri: String, icon: String): MobileWalletAdapter {
        return MobileWalletAdapter(
            connectionIdentity = ConnectionIdentity(
                identityUri  = android.net.Uri.parse(uri),
                iconUri      = android.net.Uri.parse("favicon.ico"),
                identityName = name
            )
        )
    }

    fun authorize(cluster: String, name: String, uri: String, icon: String) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    Log.d(TAG, "authorize: building adapter name=$name uri=$uri")
                    val adapter = buildAdapter(name, uri, icon)
                    Log.d(TAG, "authorize: calling transact")
                    val result = adapter.transact(sender) {
                        Log.d(TAG, "authorize: inside transact lambda, calling authorize()")
                        authorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = android.net.Uri.parse("favicon.ico"),
                            identityName = name
                        )
                    }
                    Log.d(TAG, "authorize: transact returned result=$result")
                    when (result) {
                        is TransactionResult.Success -> {
                            Log.d(TAG, "authorize: SUCCESS")
                            val auth       = result.authResult
                            val addressB58 = Base58.encodeToString(auth.accounts.first().publicKey)
                            cache.save(activeWalletPackage, auth.authToken, addressB58)
                            signal("authorized", auth.authToken, addressB58)
                        }
                        is TransactionResult.NoWalletFound -> {
                            Log.d(TAG, "authorize: NO WALLET FOUND")
                            signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No MWA wallet found on device.")
                        }
                        is TransactionResult.Failure -> {
                            Log.d(TAG, "authorize: FAILURE e=${result.e}")
                            signal("mwa_error", mapErrorCode(result.e), result.e.message ?: "Authorization failed")
                        }
                    }
                }
            } catch (e: TimeoutCancellationException) {
                Log.d(TAG, "authorize: TIMEOUT")
                signal("mwa_error", MWAErrorCodes.NETWORK_TIMEOUT, "Timed out after 60s.")
            } catch (e: Exception) {
                Log.d(TAG, "authorize: EXCEPTION e=$e")
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    fun reauthorize(authToken: String, name: String, uri: String, icon: String) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val adapter = buildAdapter(name, uri, icon)
                    val result  = adapter.transact(sender) {
                        reauthorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = android.net.Uri.parse(icon),
                            identityName = name,
                            authToken    = authToken
                        )
                    }
                    when (result) {
                        is TransactionResult.Success -> {
                            val auth = result.authResult
                            cache.save(activeWalletPackage, auth.authToken, cache.load(activeWalletPackage)?.address ?: "")
                            signal("reauthorized", auth.authToken)
                        }
                        is TransactionResult.NoWalletFound ->
                            signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No MWA wallet found on device.")
                        is TransactionResult.Failure -> {
                            val code = mapErrorCode(result.e)
                            if (code == MWAErrorCodes.AUTH_TOKEN_INVALID) cache.clear(activeWalletPackage)
                            signal("mwa_error", code, result.e.message ?: "Reauth failed")
                        }
                    }
                }
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    fun deauthorize(authToken: String) {
        scope.launch {
            try {
                val adapter = buildAdapter("InvokeQuest", "https://invokequest.dev", "favicon.ico")
                adapter.transact(sender) {
                    deauthorize(authToken = authToken)
                }
                cache.clear(activeWalletPackage)
                signal("deauthorized")
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            }
        }
    }

    fun signTransactions(transactionsB64: Array<String>) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val txBytes = transactionsB64.map { Base64.decode(it, Base64.DEFAULT) }.toTypedArray()
                    val adapter = buildAdapter("InvokeQuest", "https://invokequest.dev", "favicon.ico")
                    val result  = adapter.transact(sender) {
                        signTransactions(transactions = txBytes)
                    }
                    when (result) {
                        is TransactionResult.Success -> {
                            val sigs = result.successPayload?.signedPayloads
                                ?.map { Base64.encodeToString(it, Base64.NO_WRAP) }
                                ?.toTypedArray() ?: emptyArray()
                            signal("transaction_signed", sigs)
                        }
                        is TransactionResult.NoWalletFound ->
                            signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No wallet found.")
                        is TransactionResult.Failure ->
                            signal("mwa_error", mapErrorCode(result.e), result.e.message ?: "Sign failed")
                    }
                }
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    fun signAndSendTransactions(transactionsB64: Array<String>, minContextSlot: Int) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val txBytes = transactionsB64.map { Base64.decode(it, Base64.DEFAULT) }.toTypedArray()
                    val adapter = buildAdapter("InvokeQuest", "https://invokequest.dev", "favicon.ico")
                    val result  = adapter.transact(sender) {
                        signAndSendTransactions(transactions = txBytes)
                    }
                    when (result) {
                        is TransactionResult.Success -> {
                            val sigs = result.successPayload?.signatures
                                ?.map { Base64.encodeToString(it, Base64.NO_WRAP) }
                                ?.toTypedArray() ?: emptyArray()
                            signal("transaction_sent", sigs)
                        }
                        is TransactionResult.NoWalletFound ->
                            signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No wallet found.")
                        is TransactionResult.Failure ->
                            signal("mwa_error", mapErrorCode(result.e), result.e.message ?: "Sign and send failed")
                    }
                }
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    fun signMessages(messagesB64: Array<String>, addressesB64: Array<String>) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val messages  = messagesB64.map { Base64.decode(it, Base64.DEFAULT) }.toTypedArray()
                    val addresses = addressesB64.map { Base64.decode(it, Base64.DEFAULT) }.toTypedArray()
                    val adapter   = buildAdapter("InvokeQuest", "https://invokequest.dev", "favicon.ico")
                    val result    = adapter.transact(sender) {
                        signMessagesDetached(messages = messages, addresses = addresses)
                    }
                    when (result) {
                        is TransactionResult.Success -> {
                            val signed = result.successPayload?.messages
                                ?.mapNotNull { it.signatures.firstOrNull() }
                                ?.map { Base64.encodeToString(it, Base64.NO_WRAP) }
                                ?.toTypedArray() ?: emptyArray()
                            signal("message_signed", signed)
                        }
                        is TransactionResult.NoWalletFound ->
                            signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No wallet found.")
                        is TransactionResult.Failure ->
                            signal("mwa_error", mapErrorCode(result.e), result.e.message ?: "Sign messages failed")
                    }
                }
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    fun getCapabilities() {
        scope.launch {
            try {
                val adapter = buildAdapter("InvokeQuest", "https://invokequest.dev", "favicon.ico")
                val result  = adapter.transact(sender) {
                    getCapabilities()
                }
                when (result) {
                    is TransactionResult.Success -> {
                        val json = gson.toJson(mapOf(
                            "supports_clone_authorization"        to false,
                            "supports_sign_and_send_transactions" to true,
                            "max_transactions_per_request"        to 10,
                            "max_messages_per_request"            to 10
                        ))
                        signal("capabilities_received", json)
                    }
                    is TransactionResult.NoWalletFound ->
                        signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No wallet found.")
                    is TransactionResult.Failure ->
                        signal("mwa_error", mapErrorCode(result.e), result.e.message ?: "Get capabilities failed")
                }
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            }
        }
    }

    fun getInstalledWallets() {
        try {
            val intent = android.content.Intent(
                "com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO")
            val resolveInfo = activity.packageManager
                .queryIntentActivities(intent, android.content.pm.PackageManager.MATCH_ALL)
            val wallets: List<Map<String, Any>> = resolveInfo.map { info ->
                mapOf(
                    "package"   to info.activityInfo.packageName,
                    "name"      to info.activityInfo.applicationInfo.loadLabel(activity.packageManager).toString(),
                    "installed" to true
                )
            }
            signal("wallet_apps_detected", gson.toJson(wallets))
        } catch (e: Exception) {
            signal("wallet_apps_detected", "[]")
        }
    }

    fun cacheHasToken(): Boolean    = cache.hasToken(activeWalletPackage)
    fun cacheGetAgeSeconds(): Long  = cache.getAgeSeconds(activeWalletPackage)
    fun cacheGetAddress(): String   = cache.load(activeWalletPackage)?.address ?: ""
    fun cacheIsStale(): Boolean     = cache.isStale(activeWalletPackage)
    fun cacheClear()                = cache.clear(activeWalletPackage)
    fun cacheClearAll()             = cache.clearAll()
    fun setActiveWallet(pkg: String) { activeWalletPackage = pkg }

    fun destroy() { scope.cancel() }
}
