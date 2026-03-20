# GODOTMWA_REFERENCE_IMPLEMENTATION.md
## Consolidated Implementation Reference for INVOKE SDK (GodotMWA)
### Synthesized from MAGMA Protocol — React Native MWA + Fastify Backend
### Feed this doc at the TOP of every Claude Code session for this project

---

## ⚠️ CRITICAL PLATFORM DIFFERENCE — READ FIRST

MAGMA's MWA integration lives entirely inside the JS layer via
`@solana-mobile/mobile-wallet-adapter-protocol-web3js`. That npm
package internally handles all Android intent routing, WebSocket
session management, and wallet picker logic. There is ZERO native
Android/Kotlin code for MWA in MAGMA's `MainActivity.kt`.

**This means for GodotMWA (Kotlin plugin):** You are building from
scratch what that npm package does internally. You cannot lean on
any React Native abstraction. Every item below that MAGMA got for
free from the RN package must be explicitly implemented in Kotlin.

---

## SECTION 1: CRITICAL PATTERNS — Implement Exactly This Way

### 1.1 — The transact() Mental Model → Kotlin Equivalent

MAGMA's entire MWA flow lives inside one callback:
```typescript
await transact(async (wallet) => {
    const auth = await wallet.authorize({...});
    const signed = await wallet.signTransactions({...});
});
```

The Kotlin equivalent using `com.solanamobile:mobile-wallet-adapter-clientlib-ktx`:
```kotlin
// In MWAPlugin.kt — THIS IS THE CORRECT PATTERN
lifecycleScope.launch {
    try {
        val result = transact(activity) { wallet ->
            // authorize() MUST be called inside every transact() session
            // The wallet object is ONLY valid inside this lambda
            // Do NOT store the wallet object and use it outside
            val auth = wallet.authorize(
                identityUri = Uri.parse(identity.uri),
                iconRelativeUri = Uri.parse(identity.icon),
                identityName = identity.name,
                cluster = RpcCluster.Devnet
            )
            // Now do the actual work with auth.authToken
            auth
        }
        emitSignal("authorized", result.authToken, Base58.encode(result.publicKey))
    } catch (e: Exception) {
        emitSignal("mwa_error", mapErrorCode(e), e.message ?: "Unknown")
    }
}
```

**Why:** The wallet session object is stateful and only valid inside
the transact() callback. MAGMA learned this the hard way — storing
the wallet object across calls does not work. Each transact() opens
a new local WebSocket to the wallet app and closes it on completion.

### 1.2 — authorize() Inside Every transact() — NOT Just on First Connect

MAGMA calls `wallet.authorize()` on EVERY `transact()` invocation,
not just on first connection. This is correct and required.

```kotlin
// CORRECT — authorize every time
transact(activity) { wallet ->
    val auth = wallet.authorize(...)       // always call this
    wallet.signTransactions(auth.authToken, transactions)
}

// WRONG — do not try to reuse a session across transact() calls
val savedWallet = getStoredWalletSession()   // this doesn't exist
savedWallet.signTransactions(...)            // will fail
```

The wallet uses the `auth_token` to skip the user approval popup on
subsequent calls IF the token is still valid. First call = full popup.
Subsequent calls with valid token = silent background auth.

### 1.3 — base64 Address Decoding — The #1 Gotcha

The MWA spec returns `account.address` as **base64-encoded bytes**,
NOT as the base58 string you'd expect from Solana tooling.

```kotlin
// WRONG — will throw or give garbage
val publicKey = PublicKey(account.address)

// CORRECT — decode base64 first
val addressBytes = Base64.decode(account.address, Base64.DEFAULT)
val publicKey = PublicKey(addressBytes)
val base58Address = Base58.encode(addressBytes)
```

In GDScript, emit the base58 string to the game layer:
```gdscript
# In MobileWalletAdapter.gd
func _on_authorized(auth_token: String, address_base58: String) -> void:
    _current_account = MWAAccount.new()
    _current_account.address_base58 = address_base58
    authorized.emit(auth_token, _current_account)
```

### 1.4 — Wallet Detection Before Calling transact()

MAGMA does NOT do this — shows a generic error if no wallet installed.
GodotMWA must handle this explicitly. In Kotlin:

```kotlin
@UsedByGodot
fun getInstalledWallets(): String {
    val intent = Intent("com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO")
    val resolveInfo = activity!!.packageManager
        .queryIntentActivities(intent, PackageManager.MATCH_ALL)
    
    val wallets = resolveInfo.map { info ->
        mapOf(
            "package" to info.activityInfo.packageName,
            "name" to info.activityInfo.applicationInfo
                .loadLabel(activity!!.packageManager).toString(),
            "installed" to true
        )
    }
    return Gson().toJson(wallets)
}
```

**AndroidManifest.xml — required for Android 11+ (API 30+):**
```xml
<queries>
    <intent>
        <action android:name=
          "com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO"/>
    </intent>
    <!-- Explicit package visibility for known wallets -->
    <package android:name="app.phantom"/>
    <package android:name="com.backpack.wallet"/>
    <package android:name="com.solflare.mobile"/>
</queries>
```

Without this manifest entry, `queryIntentActivities()` returns empty
on Android 11+ regardless of what's installed. MAGMA has no native
code so it never needed this. You do.

### 1.5 — Concurrency Guard — One Session at a Time

MAGMA uses a simple boolean flag. Implement this in Kotlin:

```kotlin
private var isSessionActive = AtomicBoolean(false)

@UsedByGodot
fun authorize(cluster: String, name: String, uri: String, icon: String) {
    if (!isSessionActive.compareAndSet(false, true)) {
        emitSignal("mwa_error", ERROR_SESSION_ALREADY_ACTIVE,
            "A wallet session is already active")
        return
    }
    lifecycleScope.launch {
        try {
            // ... transact() call
        } finally {
            isSessionActive.set(false)  // always release
        }
    }
}
```

### 1.6 — Confirmation Pattern — Always Use Durable Nonce Form

MAGMA uses this correctly. Always use the object form, never
the deprecated signature-only form:

```kotlin
// CORRECT — durable nonce confirmation
val confirmation = connection.confirmTransaction(
    ConfirmTransactionParams(
        signature = txSignature,
        blockhash = recentBlockhash,
        lastValidBlockHeight = lastValidBlockHeight
    ),
    commitment = Commitment.Confirmed
)

// DEPRECATED — do not use
connection.confirmTransaction(signature)
```

### 1.7 — Blockhash Fetch — Inside the Session, Immediately Before Signing

MAGMA fetches blockhash inside the transact() callback immediately
before building the transaction. This is correct.

```kotlin
transact(activity) { wallet ->
    val auth = wallet.authorize(...)
    
    // Fetch blockhash HERE, inside the session
    val blockhashResponse = connection.getLatestBlockhash()
    val recentBlockhash = blockhashResponse.value.blockhash
    val lastValidBlockHeight = blockhashResponse.value.lastValidBlockHeight
    
    // Build transaction with fresh blockhash
    transaction.recentBlockhash = recentBlockhash
    
    wallet.signAndSendTransactions(...)
}
```

If blockhash is fetched outside the session and the user takes >60s
to approve, the transaction fails with `BlockhashNotFound`.

---

## SECTION 2: COMMON FAILURE MODES — Do NOT Do These

| Anti-Pattern | Why It Fails | Correct Approach |
|-------------|-------------|-----------------|
| Store wallet object outside transact() | Wallet object only valid inside callback | Always work inside the transact() lambda |
| Pass `account.address` directly to PublicKey() | Address is base64, not base58 | Decode base64 → bytes → PublicKey |
| Fetch blockhash before opening transact() session | Blockhash may expire before user approves | Fetch inside the session callback |
| Call transact() with no timeout | Hangs forever if user ignores prompt | Wrap with 60s timeout |
| Skip getInstalledWallets() check | Generic error if no wallet installed | Check before calling transact() |
| Store auth_token in GDScript memory only | Lost on app restart, forces re-auth every launch | Persist in EncryptedSharedPreferences |
| Call deauthorize() on disconnect | Not always desired | Separate disconnect() and full_logout() |
| Re-use wallet session across transact() calls | Each call creates a new WebSocket session | Treat each transact() as isolated |
| Build fake wallet picker that routes per-wallet | MWA selection is handled by Android OS | One transact() call, let Android pick |
| Skip QUERY_ALL_PACKAGES / queries manifest | queryIntentActivities returns empty on API 30+ | Add queries block to AndroidManifest |

---

## SECTION 3: COMPLETE ERROR HANDLING REFERENCE

### Error Code Constants (define in MWAError.kt)
```kotlin
object MWAErrorCodes {
    const val USER_DECLINED           = 1001
    const val WALLET_NOT_INSTALLED    = 1002
    const val SESSION_ALREADY_ACTIVE  = 1003
    const val AUTH_TOKEN_INVALID      = 1004
    const val AUTH_TOKEN_EXPIRED      = 1005
    const val TRANSACTION_EXPIRED     = 2001
    const val TRANSACTION_FAILED      = 2002
    const val SIMULATION_FAILED       = 2003
    const val INSUFFICIENT_FUNDS      = 2004
    const val BLOCKHASH_NOT_FOUND     = 2005
    const val NETWORK_TIMEOUT         = 3001
    const val RPC_ERROR               = 3002
    const val UNKNOWN                 = 9999
}
```

### Error Mapping from MWA SDK Exceptions
```kotlin
fun mapErrorCode(e: Exception): Int = when {
    e is JsonRpc20Client.IOException                    -> MWAErrorCodes.NETWORK_TIMEOUT
    e.message?.contains("User rejected")  == true      -> MWAErrorCodes.USER_DECLINED
    e.message?.contains("Authorization not valid") == true -> MWAErrorCodes.AUTH_TOKEN_INVALID
    e.message?.contains("Blockhash not found") == true -> MWAErrorCodes.BLOCKHASH_NOT_FOUND
    e.message?.contains("insufficient funds") == true  -> MWAErrorCodes.INSUFFICIENT_FUNDS
    e is ActivityNotFoundException                      -> MWAErrorCodes.WALLET_NOT_INSTALLED
    else                                               -> MWAErrorCodes.UNKNOWN
}
```

### Full Error Table

| Error Code | MWA Exception / Cause | Retryable | User-Facing | Recovery |
|-----------|----------------------|-----------|-------------|---------|
| USER_DECLINED (1001) | User tapped Reject in wallet | No | Yes | Show "Authorization declined" |
| WALLET_NOT_INSTALLED (1002) | ActivityNotFoundException on intent | No | Yes | Deep link to Play Store |
| SESSION_ALREADY_ACTIVE (1003) | Our own guard | No | No | Log + ignore duplicate call |
| AUTH_TOKEN_INVALID (1004) | AuthorizationNotValidException | Yes (full reauth) | No | Clear cache, call authorize() |
| AUTH_TOKEN_EXPIRED (1005) | Token age check | Yes (reauth) | No | Call reauthorize() or authorize() |
| TRANSACTION_EXPIRED (2001) | BlockhashNotFound | Yes (new blockhash) | No | Auto-retry once with fresh blockhash |
| TRANSACTION_FAILED (2002) | On-chain failure | No | Yes | Surface error detail to user |
| SIMULATION_FAILED (2003) | Preflight simulation error | No | Yes | Show simulation log to user |
| INSUFFICIENT_FUNDS (2004) | InsufficientFundsForRentError | No | Yes | Show balance needed |
| BLOCKHASH_NOT_FOUND (2005) | Blockhash expired | Yes (new blockhash) | No | Fetch new blockhash, retry once |
| NETWORK_TIMEOUT (3001) | IOException / timeout | Yes (backoff) | No | Retry 3x with 2s backoff |
| RPC_ERROR (3002) | RPC 5xx or malformed response | Yes (backoff) | No | Retry with fallback RPC |

### Errors Found in Practice NOT in MWA Docs
1. **base64 address encoding** — `account.address` is base64, not base58. Not documented.
2. **Cold start race condition** — `transact()` called too soon after app launch before Android intent system is ready. Add 500ms delay after `_ready()` before allowing first wallet call.
3. **auth_token scope** — token from `wallet.authorize()` in one `transact()` call CANNOT be used in a different `transact()` call for signing. Always re-authorize inside each session.
4. **Android 11 package visibility** — `queryIntentActivities()` silently returns empty without the `<queries>` manifest block. No exception thrown.

---

## SECTION 4: SESSION LIFECYCLE — Authoritative State Machine

```
                    ┌─────────────────────────────┐
                    │           IDLE              │
                    │  (no session, no token)     │
                    └──────────┬──────────────────┘
                               │ authorize() called
                               ▼
                    ┌─────────────────────────────┐
                    │        CONNECTING           │◄──── retry after
                    │  (transact() in flight)     │      BLOCKHASH_NOT_FOUND
                    └──────────┬──────────────────┘
                 success ──────┤──────── failure
                               │                  \
                               ▼                   ▼
              ┌────────────────────────┐   ┌───────────────────┐
              │       AUTHORIZED       │   │      ERROR        │
              │ (token valid, account  │   │ (code + message   │
              │  set, cache populated) │   │  + is_retryable)  │
              └────────┬───────────────┘   └───────────────────┘
          ┌────────────┼──────────────────┐
          │            │                  │
          ▼            ▼                  ▼
  reauthorize()   token expired      disconnect()
     needed       or invalid         called
          │            │                  │
          ▼            ▼                  ▼
  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
  │REAUTHORIZING │  │REAUTHORIZING │  │     IDLE     │
  │(silent bg    │  │→ fail → full │  │(token kept   │
  │ reauth call) │  │  IDLE+auth() │  │ in cache)    │
  └──────┬───────┘  └──────────────┘  └──────────────┘
         │ success
         ▼
    AUTHORIZED (token refreshed)

full_logout():
    AUTHORIZED → deauthorize() called → cache cleared → IDLE
```

### State Exposed to GDScript
```gdscript
enum MWAState {
    IDLE,
    CONNECTING,
    AUTHORIZED,
    REAUTHORIZING,
    ERROR
}

# In MobileWalletAdapter.gd
var _state: MWAState = MWAState.IDLE

func get_state() -> MWAState: return _state
func is_connected() -> bool: return _state == MWAState.AUTHORIZED
```

---

## SECTION 5: AUTH TOKEN — Storage & Reauth Flow

### Storage Implementation (Kotlin)
```kotlin
class AuthCacheImpl(private val context: Context) {
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs = EncryptedSharedPreferences.create(
        context, "invoke_mwa_session", masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun save(walletPackage: String, authToken: String, address: String) {
        prefs.edit()
            .putString("${walletPackage}_auth_token", authToken)
            .putString("${walletPackage}_address", address)
            .putLong("${walletPackage}_timestamp", System.currentTimeMillis())
            .apply()
    }

    fun load(walletPackage: String): CachedAuth? {
        val token = prefs.getString("${walletPackage}_auth_token", null)
            ?: return null
        val timestamp = prefs.getLong("${walletPackage}_timestamp", 0L)
        return CachedAuth(
            authToken = token,
            address = prefs.getString("${walletPackage}_address", "") ?: "",
            ageMs = System.currentTimeMillis() - timestamp
        )
    }

    fun clear(walletPackage: String) {
        prefs.edit()
            .remove("${walletPackage}_auth_token")
            .remove("${walletPackage}_address")
            .remove("${walletPackage}_timestamp")
            .apply()
    }

    fun clearAll() = prefs.edit().clear().apply()
}

data class CachedAuth(val authToken: String, val address: String, val ageMs: Long)
```

### Reauthorize Decision Flow
```kotlin
// Called at start of every transact() session
suspend fun resolveAuth(wallet: MobileWallet, identity: AppIdentity): String {
    val cached = authCache.load(activeWalletPackage)
    
    return when {
        cached == null -> {
            // No token — full authorize
            val auth = wallet.authorize(identity.toParams())
            authCache.save(activeWalletPackage, auth.authToken,
                           Base58.encode(Base64.decode(auth.accounts[0].address)))
            auth.authToken
        }
        cached.ageMs < REAUTH_THRESHOLD_MS -> {
            // Token fresh — reuse without any wallet call
            cached.authToken
        }
        else -> {
            // Token stale — try silent reauthorize
            try {
                val reauth = wallet.reauthorize(
                    identityUri = identity.uri,
                    iconRelativeUri = identity.icon,
                    identityName = identity.name,
                    authToken = cached.authToken
                )
                authCache.save(activeWalletPackage, reauth.authToken, cached.address)
                reauth.authToken
            } catch (e: AuthorizationNotValidException) {
                // Token expired — full authorize
                authCache.clear(activeWalletPackage)
                val auth = wallet.authorize(identity.toParams())
                authCache.save(activeWalletPackage, auth.authToken,
                               Base58.encode(Base64.decode(auth.accounts[0].address)))
                auth.authToken
            }
        }
    }
}

private const val REAUTH_THRESHOLD_MS = 30 * 60 * 1000L  // 30 minutes
```

### GDScript Cache Status Exposure
```gdscript
# What the game layer sees
func get_cache_status() -> Dictionary:
    var plugin = Engine.get_singleton("InvokeMWA")
    return {
        "has_token": plugin.cacheHasToken(),
        "token_age_seconds": plugin.cacheGetAgeSeconds(),
        "wallet_address": plugin.cacheGetAddress(),
        "is_stale": plugin.cacheIsStale()
    }
```

---

## SECTION 6: BACKEND INTEGRATION NOTES (Fastify on Railway)

### What MAGMA does vs. what GodotMWA needs

MAGMA has no RPC proxy — calls Helius RPC directly from the RN client.
For GodotMWA backend, the recommended architecture adds:

**POST /v1/blockhash** — return fresh blockhash to Godot client:
```typescript
fastify.get('/v1/blockhash', async (req, reply) => {
    const { blockhash, lastValidBlockHeight } =
        await connection.getLatestBlockhash('confirmed');
    reply.send({ blockhash, lastValidBlockHeight });
});
```

**POST /v1/relay** — Godot client signs via MWA, posts serialized tx:
```typescript
fastify.post<{ Body: { transaction: string; network: string } }>
('/v1/relay', async (req, reply) => {
    const txBytes = Buffer.from(req.body.transaction, 'base64');
    const tx = Transaction.from(txBytes);
    
    try {
        const sig = await connection.sendRawTransaction(tx.serialize());
        const { blockhash, lastValidBlockHeight } =
            await connection.getLatestBlockhash();
        const confirmation = await connection.confirmTransaction(
            { signature: sig, blockhash, lastValidBlockHeight },
            'confirmed'
        );
        if (confirmation.value.err) throw new Error('Transaction failed');
        reply.send({ signature: sig, status: 'confirmed' });
    } catch (e: any) {
        const isExpired = e.message?.includes('Blockhash not found');
        reply.status(400).send({
            error: isExpired ? 'BLOCKHASH_EXPIRED' : 'TRANSACTION_FAILED',
            message: e.message,
            retryable: isExpired
        });
    }
});
```

### Machine-Readable Error Codes (critical for Godot client)
Always return structured errors — Godot client parses the `error` field:
```json
{ "error": "BLOCKHASH_EXPIRED",    "message": "...", "retryable": true  }
{ "error": "INSUFFICIENT_FUNDS",   "message": "...", "retryable": false }
{ "error": "SIMULATION_FAILED",    "message": "...", "retryable": false }
{ "error": "WALLET_REJECTED",      "message": "...", "retryable": false }
{ "error": "NETWORK_TIMEOUT",      "message": "...", "retryable": true  }
```

### Rate Limiting (carry over from MAGMA exactly)
```typescript
// Global: 100/min per IP — use x-forwarded-for (Railway sets this)
rateLimit({ max: 100, timeWindow: '1 minute',
    keyGenerator: (req) =>
        req.headers['x-forwarded-for']?.split(',')[0].trim() || req.ip
})
// Per relay route: 20/min per wallet address
// Per blockhash route: 200/min per IP (cheap read)
```

### Devnet / Mainnet Discrimination (carry from MAGMA)
```typescript
const isDevnet = (process.env.HELIUS_RPC_URL || '').includes('devnet')
              || !process.env.HELIUS_RPC_URL;
// Use 'sim_' prefix on any simulated/devnet operation receipts
```

### Health Check (MAGMA pattern — keep exactly)
```typescript
fastify.get('/health', async () => ({ ok: true }))
```
Godot client polls this before opening any MWA session.

---

## SECTION 7: PLATFORM TRANSLATION — React Native → Godot/Kotlin

This is the highest-value section. For each RN pattern, the exact
Kotlin/GDScript equivalent.

| Concern | React Native (MAGMA) | Godot/Kotlin (INVOKE) |
|---------|---------------------|-----------------------|
| MWA entry point | `transact()` from npm package | `transact()` from `clientlib-ktx` Kotlin SDK |
| Wallet session scope | JS async callback | Kotlin coroutine lambda inside `lifecycleScope.launch` |
| Intent handling | Handled internally by npm package | Must explicitly register in `AndroidManifest.xml` |
| Wallet detection | Not implemented (silent fail) | `queryIntentActivities()` with `<queries>` manifest block |
| Auth token storage | React state only (in-memory) | `EncryptedSharedPreferences` + Android Keystore |
| App lifecycle | No listener in MAGMA | `onResume`/`onPause` in `GodotPlugin` Activity callbacks |
| Signal/event system | React state + hooks | Godot `emitSignal()` from Kotlin plugin |
| Error propagation | JS throw → catch | `emitSignal("mwa_error", code, message)` — never throw to GDScript |
| Concurrent guard | `isConnecting` boolean | `AtomicBoolean` — thread-safe for coroutines |
| Address format | base64 → need explicit decode | Same: `Base64.decode()` → `PublicKey(bytes)` → `Base58.encode()` |
| Wallet picker UI | Cosmetic only — all call same connect() | Do NOT implement — Android intent chooser handles this |
| reauthorize() | Not implemented — authorizes fresh every time | Implement properly with token age check |
| deauthorize() | Not implemented | Implement for `full_logout()` |
| Timeout | Not implemented | 60s for user-facing, 10s for programmatic |
| Retry on expiry | Not implemented | Auto-retry once on `BLOCKHASH_NOT_FOUND` |
| Transaction relay | Client sends directly to RPC | Optional: relay via Fastify POST /v1/relay |

---

## SECTION 8: ANDROID-SPECIFIC — Everything MAGMA Got for Free

Because MAGMA uses the RN npm package, it never touched any of this.
GodotMWA (Kotlin plugin) must implement all of it explicitly.

### AndroidManifest.xml additions required
```xml
<!-- In android/plugin/src/main/AndroidManifest.xml -->
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <!-- Required for Android 11+ wallet detection (API 30+) -->
    <queries>
        <intent>
            <action android:name=
                "com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO"/>
        </intent>
        <package android:name="app.phantom"/>
        <package android:name="com.backpack.wallet"/>
        <package android:name="com.solflare.mobile"/>
    </queries>
</manifest>
```

### Activity Lifecycle in GodotPlugin
```kotlin
override fun onMainResume() {
    super.onMainResume()
    // App came back to foreground
    // If session was CONNECTING when backgrounded, reset to IDLE
    if (sessionState == SessionState.CONNECTING) {
        sessionState = SessionState.IDLE
        isSessionActive.set(false)
        emitSignal("mwa_error", MWAErrorCodes.NETWORK_TIMEOUT,
            "Session interrupted by app background")
    }
}

override fun onMainPause() {
    super.onMainPause()
    // App going to background — note this but don't cancel yet
    // transact() may still be in wallet; user will return
}
```

### Minimum Tested Android API Levels
Based on MAGMA's Seeker testing + general MWA ecosystem:
- API 28 (Android 9): minimum supported, all features work
- API 30 (Android 11): requires `<queries>` manifest block (see above)
- API 33 (Android 13): no additional changes
- API 34 (Android 14): target SDK, all features work

### Wallet App Version Minimums (from MWA ecosystem testing)
- Phantom: 23.0+ (MWA support added in 23.x)
- Backpack: any current version supports MWA
- Solflare: 4.0+

---

## QUICK REFERENCE: Session Start Checklist

Before every `transact()` call in Kotlin, verify:
```
[ ] isSessionActive == false (concurrency guard)
[ ] getInstalledWallets() returned at least one wallet
[ ] network health check passed (/health endpoint)
[ ] blockhash will be fetched INSIDE the transact() callback
[ ] 60s timeout wrapper is in place
[ ] error handling catches all exception types and emits signals
[ ] auth token: check cache → reauthorize if stale → authorize if missing
```

---

*GODOTMWA_REFERENCE_IMPLEMENTATION.md — Consolidated from MAGMA Protocol*
*ExiDante Corp / Francisco (Franny) · Portugal · March 2026*
*Version 1.0 — Feed at top of every INVOKE SDK Claude Code session*
