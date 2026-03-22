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


    fun tryReauthorizeFromCache(name: String, uri: String, icon: String) {
        val cached = cache.load(activeWalletPackage)
        if (cached == null) {
            signal("mwa_error", MWAErrorCodes.AUTH_TOKEN_EXPIRED, "No cached token found.")
            return
        }
        if (cache.shouldReuse(activeWalletPackage)) {
            // Token is fresh (<30 min) — restore silently, no wallet interaction
            signal("reauthorized", cached.authToken)
            return
        }
        if (cache.shouldReauthorize(activeWalletPackage)) {
            // Token is stale but valid (<24h) — reauth via wallet (picker will show)
            reauthorize(cached.authToken, name, uri, icon)
            return
        }
        // Token too old — force fresh login
        cache.clear(activeWalletPackage)
        signal("mwa_error", MWAErrorCodes.AUTH_TOKEN_EXPIRED, "Session expired. Please reconnect.")
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


    fun disconnectWallet() {
        cache.clear(activeWalletPackage)
        signal("deauthorized")
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


    fun signMemoTransaction(memo: String, rpcUrl: String) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    // 1. Get cached address (public key)
                    val addressB58 = cache.load(activeWalletPackage)?.address
                        ?: run {
                            signal("mwa_error", MWAErrorCodes.AUTH_TOKEN_EXPIRED, "No cached address. Please reconnect.")
                            return@withTimeout
                        }
                    val pubkeyBytes = Base58.decode(addressB58)

                    // 2. Fetch recent blockhash from RPC
                    val blockhash = fetchRecentBlockhash(rpcUrl)
                        ?: run {
                            signal("mwa_error", MWAErrorCodes.RPC_ERROR, "Failed to fetch recent blockhash.")
                            return@withTimeout
                        }
                    val blockhashBytes = Base58.decode(blockhash)

                    // 3. Build memo transaction bytes
                    val txBytes = buildMemoTransaction(pubkeyBytes, blockhashBytes, memo)

                    // 4. Sign via MWA
                    val adapter = buildAdapter("InvokeQuest", "https://invoke.dev", "favicon.ico")
                    val result = adapter.transact(sender) {
                        signTransactions(transactions = arrayOf(txBytes))
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
            } catch (e: TimeoutCancellationException) {
                signal("mwa_error", MWAErrorCodes.NETWORK_TIMEOUT, "Timed out after 60s.")
            } catch (e: Exception) {
                signal("mwa_error", mapErrorCode(e), e.message ?: "Unknown error")
            } finally {
                isSessionActive.set(false)
            }
        }
    }

    private suspend fun fetchRecentBlockhash(rpcUrl: String): String? {
        return withContext(Dispatchers.IO) { try {
            val url = java.net.URL(rpcUrl)
            val conn = url.openConnection() as java.net.HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json")
            conn.doOutput = true
            conn.connectTimeout = 10_000
            conn.readTimeout = 10_000
            val body = """{"jsonrpc":"2.0","id":1,"method":"getLatestBlockhash","params":[{"commitment":"finalized"}]}"""
            conn.outputStream.use { it.write(body.toByteArray()) }
            val response = conn.inputStream.bufferedReader().readText()
            conn.disconnect()
            // Parse blockhash from JSON response
            val match = Regex(""""blockhash"\s*:\s*"([A-Za-z0-9]+)"""").find(response)
            match?.groupValues?.get(1)
        } catch (e: Exception) {
            Log.e(TAG, "fetchRecentBlockhash failed: $e")
            null
        } }
    }

    private fun buildMemoTransaction(feePayer: ByteArray, blockhash: ByteArray, memo: String): ByteArray {
        // Memo program ID
        val memoProgramId = Base58.decode("MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr")
        val memoBytes = memo.toByteArray(Charsets.UTF_8)

        // Transaction layout:
        // [1 byte] num_signatures = 1
        // [64 bytes] signature placeholder (zeros)
        // [1 byte] num_required_signers = 1
        // [1 byte] num_readonly_signed = 0
        // [1 byte] num_readonly_unsigned = 1
        // [1 byte] num_accounts = 2
        // [32 bytes] fee payer pubkey
        // [32 bytes] memo program id
        // [32 bytes] recent blockhash
        // [1 byte] num_instructions = 1
        // Instruction:
        //   [1 byte] program_id_index = 1
        //   [1 byte] num_accounts = 0
        //   [compact-u16] data length
        //   [N bytes] memo data

        val buf = java.io.ByteArrayOutputStream()

        // Header
        buf.write(1)                    // num_signatures
        buf.write(ByteArray(64))        // signature placeholder
        buf.write(1)                    // num_required_signers
        buf.write(0)                    // num_readonly_signed
        buf.write(1)                    // num_readonly_unsigned

        // Account keys
        buf.write(2)                    // num_accounts
        buf.write(feePayer)             // fee payer
        buf.write(memoProgramId)        // memo program

        // Recent blockhash
        buf.write(blockhash)

        // Instructions
        buf.write(1)                    // num_instructions
        buf.write(1)                    // program_id_index (memo program = index 1)
        buf.write(0)                    // num_account_indices

        // Compact-u16 encoding for memo length
        val memoLen = memoBytes.size
        if (memoLen < 128) {
            buf.write(memoLen)
        } else {
            buf.write((memoLen and 0x7F) or 0x80)
            buf.write(memoLen shr 7)
        }
        buf.write(memoBytes)

        return buf.toByteArray()
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
