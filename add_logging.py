path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

old = '''    fun authorize(cluster: String, name: String, uri: String, icon: String) {
        if (!isSessionActive.compareAndSet(false, true)) {
            signal("mwa_error", MWAErrorCodes.SESSION_ALREADY_ACTIVE, "A wallet session is already active.")
            return
        }
        scope.launch {
            try {
                withTimeout(SESSION_TIMEOUT_MS) {
                    val adapter = buildAdapter(name, uri, icon)
                    val result = adapter.transact(sender) {
                        authorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = android.net.Uri.parse(icon),
                            identityName = name
                        )
                    }
                    when (result) {
                        is TransactionResult.Success -> {
                            val auth       = result.authResult
                            val addressB58 = Base58.encodeToString(auth.accounts.first().publicKey)
                            cache.save(activeWalletPackage, auth.authToken, addressB58)
                            signal("authorized", auth.authToken, addressB58)
                        }
                        is TransactionResult.NoWalletFound ->
                            signal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED, "No MWA wallet found on device.")
                        is TransactionResult.Failure ->
                            signal("mwa_error", mapErrorCode(result.e), result.e.message ?: "Authorization failed")
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
    }'''

new = '''    fun authorize(cluster: String, name: String, uri: String, icon: String) {
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
                            iconUri      = android.net.Uri.parse(icon),
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
    }'''

if old in content:
    content = content.replace(old, new)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Added logging to authorize()")
else:
    print("Pattern not found - check indentation")
