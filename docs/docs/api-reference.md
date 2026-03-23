---
sidebar_position: 3
title: API Reference
description: Complete reference for every Invoke SDK method and signal.
---

# API Reference

## Getting the Singleton

```gdscript
var _mwa = null

func _ready() -> void:
    if Engine.has_singleton("InvokeMWA"):
        _mwa = Engine.get_singleton("InvokeMWA")
```

---

## Signals

### `authorized(auth_token: String, address: String)`
Emitted when `authorize()` succeeds. `address` is the wallet public key in base58.

### `reauthorized(auth_token: String)`
Emitted when `reauthorize()` or `tryReauthorizeFromCache()` succeeds silently.

### `deauthorized()`
Emitted when `deauthorize()` or `disconnectWallet()` completes.

### `transaction_signed(signatures: Array)`
Emitted when `signTransactions()` or `signMemoTransaction()` succeeds.

### `transaction_sent(signatures: Array)`
Emitted when `signAndSendTransactions()` or `signAndSendMemoTransaction()` succeeds. Contains transaction signatures (base58).

### `message_signed(signatures: Array)`
Emitted when `signMessages()` or `signMemoMessage()` succeeds.

### `capabilities_received(json: String)`
Emitted when `getCapabilities()` succeeds. Contains wallet capabilities as JSON string.

### `wallet_apps_detected(json: String)`
Emitted when `getInstalledWallets()` completes. Contains installed wallet list as JSON.

### `mwa_error(code: int, message: String)`
Emitted when any operation fails. See [Error Codes](#error-codes).

---

## Methods

### Authorization

#### `authorize(cluster, name, uri, icon)`
Opens the system wallet picker and requests authorization.

```gdscript
_mwa.authorize("solana:devnet", "My Game", "https://mygame.dev", "https://mygame.dev/icon.png")
```

| Parameter | Type | Description |
|-----------|------|-------------|
| cluster | String | `"solana:devnet"`, `"solana:testnet"`, `"solana:mainnet-beta"` |
| name | String | App name shown in wallet UI |
| uri | String | App URL (must start with https://) |
| icon | String | Full URL to app icon |

---

#### `reauthorize(auth_token, name, uri, icon)`
Refreshes an existing session. May show wallet picker if token is stale.

---

#### `deauthorize(auth_token)`
Tells the wallet to invalidate this token server-side.

---

#### `tryReauthorizeFromCache(name, uri, icon)`
Reads auth token from encrypted cache and reauthorizes automatically. This is the recommended pattern for app startup.

```gdscript
func _ready() -> void:
    if _mwa.cacheHasToken():
        _mwa.tryReauthorizeFromCache("My Game", "https://mygame.dev", "https://mygame.dev/icon.png")
    else:
        show_connect_button()
```

---

#### `disconnectWallet()`
Clears the cached token instantly. Does NOT call the wallet — no popup. Use for your Disconnect button.

```gdscript
_mwa.disconnectWallet()
# Then listen for deauthorized signal
```

---

### Signing

#### `signTransactions(transactions)`
Signs one or more raw transactions (Base64 encoded). Does not broadcast.

```gdscript
_mwa.signTransactions(["BASE64_TX_BYTES"])
```

---

#### `signAndSendTransactions(transactions, min_context_slot)`
Signs and broadcasts transactions to the Solana network.

```gdscript
_mwa.signAndSendTransactions(["BASE64_TX_BYTES"], 0)
```

---

#### `signMessages(messages, addresses)`
Signs arbitrary messages off-chain (no transaction, no network).

```gdscript
_mwa.signMessages(["BASE64_MSG_BYTES"], ["BASE64_ADDRESS_BYTES"])
```

---

### Convenience Methods

These build real Solana transactions internally — no transaction construction needed in GDScript.

#### `signMemoTransaction(memo, rpc_url)`
Builds a real memo transaction, fetches a fresh blockhash from RPC, and requests a signature. Emits `transaction_signed`.

```gdscript
_mwa.signMemoTransaction("Hello Solana", "https://api.devnet.solana.com")
```

---

#### `signAndSendMemoTransaction(memo, rpc_url)`
Builds, signs, and broadcasts a memo transaction. Emits `transaction_sent` with the transaction signature.

```gdscript
_mwa.signAndSendMemoTransaction("Hello Solana", "https://api.devnet.solana.com")
```

---

#### `signMemoMessage(message)`
Signs a plain text message off-chain. Emits `message_signed`.

```gdscript
_mwa.signMemoMessage("Hello Solana")
```

---

### Discovery

#### `getCapabilities()`
Queries the connected wallet for supported MWA features. Emits `capabilities_received`.

#### `getInstalledWallets()`
Detects MWA-compatible wallet apps installed on the device. Emits `wallet_apps_detected`.

---

### Cache Inspection

```gdscript
_mwa.cacheHasToken()       # bool — token exists in cache
_mwa.cacheGetAddress()     # String — cached wallet address
_mwa.cacheGetAgeSeconds()  # int — seconds since token was cached
_mwa.cacheIsStale()        # bool — true if older than 30 minutes
_mwa.cacheClear()          # clear active wallet token
_mwa.cacheClearAll()       # clear all cached tokens
```

---

## Error Codes

| Code | Constant | Retryable | Cause |
|------|----------|-----------|-------|
| 1001 | USER_DECLINED | No | User tapped Reject in wallet |
| 1002 | WALLET_NOT_INSTALLED | No | No MWA wallet found on device |
| 1003 | SESSION_ALREADY_ACTIVE | No | Concurrent session blocked |
| 1004 | AUTH_TOKEN_INVALID | Yes | Token rejected by wallet |
| 1005 | AUTH_TOKEN_EXPIRED | Yes | Token too old, re-auth required |
| 2001 | TRANSACTION_EXPIRED | Yes | Blockhash expired |
| 2002 | TRANSACTION_FAILED | No | On-chain rejection |
| 2003 | SIMULATION_FAILED | No | Preflight simulation failed |
| 2004 | INSUFFICIENT_FUNDS | No | Not enough SOL |
| 2005 | BLOCKHASH_NOT_FOUND | Yes | RPC blockhash fetch failed |
| 3001 | NETWORK_TIMEOUT | Yes | Network request timed out |
| 3002 | RPC_ERROR | Yes | RPC endpoint error |
| 9999 | UNKNOWN | No | Unmapped exception |
