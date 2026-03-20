# API Parity Matrix
## Invoke SDK — React Native MWA vs Godot SDK
### Reference: `@solana-mobile/mobile-wallet-adapter-protocol-web3js`

---

## Core Session Methods

| RN Method | GDScript Method | Kotlin Bridge | Status | Complexity | Notes |
|-----------|----------------|---------------|--------|------------|-------|
| `transact(callback)` | `authorize(identity)` | `authorize()` | ⬜ TODO | M | Kotlin transact() wraps every call |
| `wallet.authorize()` | `authorize(identity: MWAIdentity)` | `authorize()` | ⬜ TODO | M | Emits `authorized` signal |
| `wallet.reauthorize()` | `reauthorize(auth_token, identity)` | `reauthorize()` | ⬜ TODO | M | Silent bg call, no wallet popup |
| `wallet.deauthorize()` | `deauthorize(auth_token)` | `deauthorize()` | ⬜ TODO | S | Clears session server-side |
| `wallet.getCapabilities()` | `get_capabilities()` | `getCapabilities()` | ⬜ TODO | S | Emits `capabilities_received` |
| `wallet.cloneAuthorization()` | `clone_authorization(auth_token)` | `cloneAuthorization()` | ⬜ TODO | L | Advanced — Phase 1 end |
| N/A | `disconnect()` | N/A | ⬜ TODO | S | Local only — no wallet call |
| N/A | `full_logout()` | `deauthorize()` | ⬜ TODO | S | deauthorize + clear cache + IDLE |

---

## Transaction Methods

| RN Method | GDScript Method | Kotlin Bridge | Status | Complexity | Notes |
|-----------|----------------|---------------|--------|------------|-------|
| `wallet.signTransactions()` | `sign_transactions(txs: Array[PackedByteArray])` | `signTransactions()` | ⬜ TODO | M | Emits `transaction_signed` |
| `wallet.signAndSendTransactions()` | `sign_and_send_transactions(txs, opts)` | `signAndSendTransactions()` | ⬜ TODO | M | Emits `transaction_sent` |
| `wallet.signMessages()` | `sign_messages(messages, addresses)` | `signMessages()` | ⬜ TODO | M | Emits `message_signed` |

---

## Auth Cache (No RN Equivalent — New in Invoke)

| Feature | GDScript Class | Kotlin Class | Status | Complexity | Notes |
|---------|---------------|--------------|--------|------------|-------|
| Cache base interface | `MWAAuthCache.gd` | N/A | ⬜ TODO | S | Abstract base class |
| In-memory cache | `MWAMemoryCache.gd` | N/A | ⬜ TODO | S | Dev/testing use |
| File cache | `MWAFileCache.gd` | N/A | ⬜ TODO | M | Default, Godot user:// |
| Secure cache | `MWASecureCache.gd` | `AuthCacheImpl.kt` | ⬜ TODO | L | EncryptedSharedPreferences |
| Keystore cache | N/A | `KeystoreCacheImpl.kt` | ⬜ TODO | L | Android Keystore hardware |
| Cache manager | `MWACacheManager.gd` | N/A | ⬜ TODO | M | Auto-select backend |

---

## Wallet Detection (No RN Equivalent — New in Invoke)

| Feature | GDScript Method | Kotlin Bridge | Status | Complexity | Notes |
|---------|----------------|---------------|--------|------------|-------|
| List installed wallets | `get_installed_wallets()` | `getInstalledWallets()` | ⬜ TODO | M | queryIntentActivities |
| Phantom installed? | `is_phantom_installed()` | `getInstalledWallets()` | ⬜ TODO | S | Helper wrapper |
| Backpack installed? | `is_backpack_installed()` | `getInstalledWallets()` | ⬜ TODO | S | Helper wrapper |
| Solflare installed? | `is_solflare_installed()` | `getInstalledWallets()` | ⬜ TODO | S | Helper wrapper |

---

## Error Codes

| Code | Constant | Trigger | Retryable |
|------|----------|---------|-----------|
| 1001 | `USER_DECLINED` | User tapped Reject in wallet | No |
| 1002 | `WALLET_NOT_INSTALLED` | No wallet app found | No |
| 1003 | `SESSION_ALREADY_ACTIVE` | Concurrent transact() call | No |
| 1004 | `AUTH_TOKEN_INVALID` | AuthorizationNotValidException | Yes — full reauth |
| 1005 | `AUTH_TOKEN_EXPIRED` | Token age exceeded threshold | Yes — reauthorize |
| 2001 | `TRANSACTION_EXPIRED` | BlockhashNotFound | Yes — new blockhash |
| 2002 | `TRANSACTION_FAILED` | On-chain failure | No |
| 2003 | `SIMULATION_FAILED` | Preflight simulation error | No |
| 2004 | `INSUFFICIENT_FUNDS` | InsufficientFundsForRentError | No |
| 2005 | `BLOCKHASH_NOT_FOUND` | Blockhash expired | Yes — retry once |
| 3001 | `NETWORK_TIMEOUT` | IOException / timeout | Yes — backoff |
| 3002 | `RPC_ERROR` | RPC 5xx or malformed response | Yes — fallback RPC |

---

## Signals

| Signal | Parameters | Emitted When |
|--------|------------|--------------|
| `authorized` | `auth_token: String, account: MWAAccount` | authorize() succeeds |
| `reauthorized` | `auth_token: String` | reauthorize() succeeds |
| `deauthorized` | — | deauthorize() completes |
| `disconnected` | — | disconnect() called |
| `transaction_signed` | `signatures: Array[PackedByteArray]` | signTransactions() succeeds |
| `transaction_sent` | `signatures: Array[String]` | signAndSendTransactions() succeeds |
| `message_signed` | `signed: Array[PackedByteArray]` | signMessages() succeeds |
| `capabilities_received` | `capabilities: Dictionary` | getCapabilities() succeeds |
| `error` | `code: int, message: String` | Any operation fails |

---

## Complexity Key

| Symbol | Meaning |
|--------|---------|
| S | Small — under 1 hour |
| M | Medium — half day |
| L | Large — full day |
| XL | Extra large — multiple days |

## Status Key

| Symbol | Meaning |
|--------|---------|
| ⬜ TODO | Not started |
| 🔄 IN PROGRESS | Active development |
| ✅ DONE | Implemented + tested |

---

*Invoke SDK API Parity Matrix v1.0 · Francisco (Franny) · Portugal · 2026*
