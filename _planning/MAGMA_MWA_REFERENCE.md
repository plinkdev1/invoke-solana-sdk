# MAGMA_MWA_REFERENCE.md
## MWA Reference Implementation — Extracted from MAGMA Protocol (React Native)
### For GodotMWA SDK — Godot Engine Android Solana Wallet Adapter

---

## Section 1: transact() Wrapper

### The actual pattern used
```typescript
await transact(async (wallet: Web3MobileWallet) => {
  const authResult = await wallet.authorize({
    cluster: 'devnet',
    identity: {
      name: 'MAGMA Protocol',
      uri: 'https://magmaprotocol.xyz',
      icon: 'favicon.ico',
    },
  });
  // do work with wallet here
});
```

### What transact() actually does
transact() is the single entry point for ALL MWA operations. It:
1. Fires an Android intent to find an installed wallet app
2. Establishes a local WebSocket session with the wallet
3. Calls your async callback with a wallet session object
4. Closes the session when your callback resolves or throws

### Critical pattern: authorize() is called INSIDE transact() every time
MAGMA calls wallet.authorize() on every transact() invocation — not just
on first connect. This means every transaction flow re-authorizes.
This is safe and correct. The wallet uses the auth_token to skip the
user approval screen on repeat authorizations if the token is valid.

### What happens when wallet app is NOT in foreground
transact() fires an Android intent. If no MWA-compatible wallet is
installed, the intent finds no receiver and throws immediately.
MAGMA catches this as a generic error — no WalletNotInstalledError
specific handling was implemented. For GodotMWA: catch intent resolution
failures separately from session errors.

### Timeout handling
MAGMA has NO explicit timeout on transact(). In practice if the user
ignores the wallet prompt, it hangs indefinitely. For GodotMWA:
implement a timeout wrapper (recommend 60s for user action, 10s for
programmatic calls).

### Concurrent session guard
MAGMA uses a simple isConnecting boolean guard:
```typescript
if (isConnecting) return;
setIsConnecting(true);
```
This prevents double-invocation but does NOT handle the case where
transact() is called while a previous transact() session is still open
(e.g. user navigates away). For GodotMWA: track an activeSession flag
and await/cancel before opening a new one.

---

## Section 2: Session Lifecycle

### State machine (as implemented)
```
IDLE
  │
  ├─ connect() called
  │
CONNECTING (isConnecting=true)
  │
  ├─ transact() fires intent
  ├─ wallet.authorize() called
  │
  ├─ success → AUTHORIZED (isConnected=true, account set)
  │
  └─ failure → IDLE (isConnected=false, account=null, error set)

AUTHORIZED
  │
  └─ disconnect() called → IDLE (synchronous, no MWA call)
```

### What's missing from this state machine
- No REAUTHORIZING state
- No SUSPENDED state (app backgrounded mid-session)  
- No ERROR_RECOVERABLE vs ERROR_FATAL distinction
- disconnect() is purely local — does NOT call wallet.deauthorize()
  This means the wallet still considers the app authorized until the
  auth_token expires. For GodotMWA: call deauthorize() on explicit
  disconnect if you want clean revocation.

### App backgrounding mid-session
MAGMA has no AppState listener. If the app goes to background while
transact() is running, the session may be left in CONNECTING state
with no recovery path. For GodotMWA: listen to Android onPause/onResume
and handle interrupted sessions explicitly.

### Auth token storage
The auth_token from wallet.authorize() is stored in React state ONLY:
```typescript
setAccount({
  address: publicKey.toBase58(),
  publicKey,
  label: firstAccount.label,
  authToken: authResult.auth_token,  // ← in-memory only
});
```
NO persistent storage (no AsyncStorage, no SecureStore, no Keystore).
This means every app restart requires a full re-authorization.
For GodotMWA: store auth_token in Android EncryptedSharedPreferences
backed by Android Keystore. Re-use token on app resume. Call
reauthorize() before any transaction if token age > threshold.

### Reauthorize() flow
MAGMA does NOT implement reauthorize(). It calls authorize() fresh
every time inside transact(). This works but is suboptimal — it
triggers wallet UI on every transaction if the token expired.
For GodotMWA: implement proper reauth:
```kotlin
// pseudo-code
if (tokenAge > REAUTH_THRESHOLD) {
    wallet.reauthorize(authToken, identity)
} else {
    wallet.authorize(identity)  // fresh auth
}
```

---

## Section 3: Auth Token Storage

### What MAGMA does
In-memory React state only. Auth token is lost on app close/restart.
No expiry tracking. No reauthorize() path.

### Address decoding — this is a real gotcha
The account address from MWA comes as base64, not base58:
```typescript
// MAGMA correctly handles this:
const addressBytes = typeof firstAccount.address === 'string'
  ? Buffer.from(firstAccount.address, 'base64')  // ← base64 decode first
  : firstAccount.address;
const publicKey = new PublicKey(addressBytes);
```
If you try to pass firstAccount.address directly to new PublicKey(),
it will fail. The MWA spec returns addresses as base64-encoded bytes,
not the base58 string you'd expect from Solana tooling.
For GodotMWA: decode base64 → bytes → base58 explicitly.

### Recommended GodotMWA storage pattern
```kotlin
// Android Kotlin — EncryptedSharedPreferences
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val prefs = EncryptedSharedPreferences.create(
    context,
    "mwa_session",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

prefs.edit()
    .putString("auth_token", authToken)
    .putString("wallet_address", walletAddress)
    .putLong("auth_timestamp", System.currentTimeMillis())
    .apply()
```

---

## Section 4: Error Handling Patterns

| Error | How MAGMA catches it | Recovery | User-facing? |
|-------|---------------------|----------|--------------|
| User rejected auth | `err?.message?.includes('User rejected')` or `err?.errorCode === 'USER_DECLINED'` | Set error string, stay disconnected | Yes |
| Generic error | `err?.message` fallback | Set error string | Yes |
| Wallet not installed | NOT HANDLED EXPLICITLY — falls into generic catch | No recovery — shows generic error | Yes (wrong message) |
| Session already active | NOT HANDLED — isConnecting guard only | No recovery | No (silent) |
| Transaction failed (on-chain) | `confirmation.value.err` check | Throw + surface to user | Yes |
| Network timeout | NOT HANDLED explicitly | Unhandled promise rejection | No |
| reauthorize() failed | NOT IMPLEMENTED | N/A | N/A |

### Errors NOT documented in MWA docs but found in practice
1. base64 address encoding — see Section 3. Not in MWA docs.
2. transact() throws if called before Android intent system is ready
   (app cold start race condition) — add a short delay after app mount.
3. wallet.signTransactions() expects the auth_token from the SAME
   transact() session — you cannot store an auth_token from one
   transact() call and use it in a different transact() call.
   MAGMA correctly gets auth_token fresh inside each transact() callback.

### WalletNotInstalledError handling
MAGMA does NOT handle this gracefully. The intent fails silently and
the user sees a generic "Wallet connection failed" error.
For GodotMWA: check for installed MWA wallets before calling transact():
```kotlin
val intent = Intent("com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO")
val resolveInfo = packageManager.queryIntentActivities(intent, 0)
if (resolveInfo.isEmpty()) {
    // No MWA wallet installed — show install prompt
}
```

---

## Section 5: Lessons Learned

- **base64 address is the #1 gotcha.** firstAccount.address is base64,
  not base58. Every new MAGMA dev hits this. Decode explicitly.

- **authorize() inside every transact() is correct.** Do not try to
  cache the session object across transact() calls — it doesn't work.
  The wallet object in the callback is only valid inside that callback.

- **WalletPickerModal is fake.** MAGMA shows 4 wallet logos (Phantom,
  Backpack, Solflare, Jupiter) but they all call the same connect()
  function. There is no per-wallet routing. MWA handles wallet
  selection via the Android intent chooser — the UI is cosmetic.
  For GodotMWA: you do NOT need to implement wallet-specific logic.
  One transact() call handles all MWA-compatible wallets via Android.

- **No auth token persistence = bad UX.** Every app restart forces
  the user back through wallet auth. On Seeker (the primary device)
  this is a noticeable friction point. Implement persistence.

- **disconnect() does not call deauthorize().** The wallet keeps the
  authorization alive. This is fine for beta but means the user's
  wallet will keep showing MAGMA as an authorized app indefinitely.

- **No reauthorize() = unnecessary wallet prompts.** If auth_token
  expires, the user sees a full wallet auth screen instead of a
  seamless background reauth. Implement reauthorize().

- **MainActivity.kt has zero MWA-specific code.** All MWA intent
  handling is done inside the JS layer via the RN MWA package.
  There are no custom AndroidManifest intent-filters for MWA.
  The RN package handles all of this internally.

- **No session state beyond isConnecting/isConnected.** There is no
  SUSPENDED, RECONNECTING, or ERROR_RECOVERABLE state. For a production
  SDK, you need at least 5-6 states.

---

## Section 6: What I'd Do Differently in a New SDK

**Carry over:**
- transact() as the single entry point — correct and clean
- authorize() called fresh inside every transact() — correct
- APP_IDENTITY object with name/uri/icon — required by all wallets
- base64 → bytes → PublicKey address decoding pattern
- isConnecting guard to prevent concurrent sessions

**Redesign:**

1. **Persistent auth token storage** — EncryptedSharedPreferences +
   Android Keystore. Never in-memory only.

2. **Proper reauthorize() flow** — check token age before every
   transact(), reauthorize silently if < 60min old, full authorize
   if expired or missing.

3. **Explicit timeout wrapper** around transact() — 60s user timeout,
   10s for programmatic calls.

4. **6-state session machine:**
   IDLE → CONNECTING → AUTHORIZED → REAUTHORIZING → SUSPENDED → ERROR
   With explicit transitions and recovery paths for each.

5. **WalletNotInstalledError detection** before calling transact() —
   check intent resolvers, show store link if no wallet found.

6. **AppState/lifecycle awareness** — cancel in-flight transact() calls
   on app background, resume cleanly on foreground.

7. **deauthorize() on explicit disconnect** — clean revocation.

8. **Transaction-level error granularity:**
   - SolanaTransactionExpiredError (retry with fresh blockhash)
   - InsufficientFundsError (surface to user with amount needed)
   - SimulationFailedError (show simulation error detail)
   - NetworkTimeoutError (retry with backoff)
   These are not in MAGMA's current implementation.

9. **Do NOT build fake wallet picker UI.** Let Android's intent chooser
   handle wallet selection. It's what users expect on Android and it
   works with all present and future MWA wallets automatically.

---

*Extracted from MAGMA Protocol codebase · ExiDante Corp · 2026-03-20*
*Feed to GodotMWA SDK agent at start of every implementation session*