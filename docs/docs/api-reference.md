---
sidebar_position: 3
title: API Reference
description: Complete reference for every MobileWalletAdapter method and signal.
---

# API Reference

## MobileWalletAdapter

The main SDK class. Add as AutoLoad named `MWA` in Project Settings.

---

## Signals

### `authorized(auth_token: String, account: MWAAccount)`
Emitted when `authorize()` succeeds.

| Parameter | Type | Description |
|-----------|------|-------------|
| auth_token | String | Raw auth token from wallet |
| account | MWAAccount | Authorized wallet account |

### `reauthorized(auth_token: String)`
Emitted when `reauthorize()` succeeds silently.

### `deauthorized()`
Emitted when `deauthorize()` completes.

### `disconnected()`
Emitted when `disconnect()` or `full_logout()` is called.

### `transaction_signed(signatures: Array)`
Emitted when `sign_transactions()` succeeds.

| Parameter | Type | Description |
|-----------|------|-------------|
| signatures | Array[PackedByteArray] | Signed transaction bytes |

### `transaction_sent(signatures: Array)`
Emitted when `sign_and_send_transactions()` succeeds.

| Parameter | Type | Description |
|-----------|------|-------------|
| signatures | Array[String] | Transaction signatures (base58) |

### `message_signed(signed_messages: Array)`
Emitted when `sign_messages()` succeeds.

### `capabilities_received(capabilities: MWACapabilities)`
Emitted when `get_capabilities()` succeeds.

### `wallets_detected(wallets: Array)`
Emitted when `get_installed_wallets()` completes.

### `error(code: int, message: String)`
Emitted when any operation fails.

| Parameter | Type | Description |
|-----------|------|-------------|
| code | int | Error code (see MWAError) |
| message | String | Human-readable error message |

### `state_changed(new_state: MobileWalletAdapter.State)`
Emitted whenever the SDK state changes.

---

## Methods

### `authorize(identity: MWAIdentity, cluster: String = "devnet") -> void`
Opens the wallet app and requests authorization.
`gdscript
var identity = MWAIdentity.new("My Game", "https://mygame.dev", "favicon.ico")
MWA.authorize(identity, "devnet")
`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| identity | MWAIdentity | required | App identity shown in wallet |
| cluster | String | "devnet" | "devnet", "testnet", "mainnet-beta" |

---

### `reauthorize(auth_token: String, identity: MWAIdentity) -> void`
Silently refreshes an existing auth token. No wallet popup.
`gdscript
MWA.reauthorize(cached_token, identity)
`

---

### `deauthorize(auth_token: String) -> void`
Tells the wallet to invalidate this token server-side.
`gdscript
MWA.deauthorize(current_token)
`

---

### `disconnect() -> void`
Closes the local session. Does NOT call the wallet. Token remains in cache.
`gdscript
MWA.disconnect()
`

---

### `full_logout() -> void`
Deauthorizes + clears cache + resets to IDLE state.
`gdscript
MWA.full_logout()
`

---

### `sign_transactions(transactions: Array) -> void`
Signs one or more transactions. Does NOT send them to the network.
`gdscript
MWA.sign_transactions([tx_bytes])
`

| Parameter | Type | Description |
|-----------|------|-------------|
| transactions | Array[PackedByteArray] | Serialized transaction bytes |

---

### `sign_and_send_transactions(transactions: Array, options: MWASendOptions = null) -> void`
Signs and broadcasts transactions to the Solana network.
`gdscript
MWA.sign_and_send_transactions([tx_bytes])
# With options:
var opts = MWASendOptions.new(min_context_slot)
MWA.sign_and_send_transactions([tx_bytes], opts)
`

---

### `sign_messages(messages: Array, addresses: Array) -> void`
Signs arbitrary byte messages (off-chain personal sign).
`gdscript
var msg = "Hello Solana".to_utf8_buffer()
MWA.sign_messages([msg], [account.address_bytes])
`

---

### `get_capabilities() -> void`
Queries what features the wallet supports.
Emits `capabilities_received` on success.

---

### `get_installed_wallets() -> void`
Lists MWA-compatible wallet apps installed on the device.
Emits `wallets_detected` on completion.

---

### `is_connected() -> bool`
Returns true if state is AUTHORIZED.

### `get_state() -> MobileWalletAdapter.State`
Returns current state enum value.

### `get_current_account() -> MWAAccount`
Returns the authorized account, or null if not connected.

---

## State Enum
`gdscript
enum State {
    IDLE,          # No session
    CONNECTING,    # Waiting for wallet response
    AUTHORIZED,    # Connected, token valid
    REAUTHORIZING, # Silent reauth in progress
    ERROR          # Last operation failed
}
`

---

## MWAIdentity

App identity passed to `authorize()` and `reauthorize()`.
`gdscript
var identity = MWAIdentity.new(
    "My Game",             # name — shown in wallet UI
    "https://mygame.dev",  # uri  — must start with http(s)://
    "favicon.ico"          # icon — relative to uri
)
`

---

## MWAAccount

Wallet account returned after authorization.

| Field | Type | Description |
|-------|------|-------------|
| address_base58 | String | Public key as base58 string |
| address_bytes | PackedByteArray | Raw 32-byte public key |
| label | String | Optional wallet label |
| chains | Array[String] | Supported chains |
`gdscript
# Display truncated address in UI (first 4...last 4)
label.text = account.get_display_address()
`

---

## MWAAuthToken

| Method | Returns | Description |
|--------|---------|-------------|
| is_valid() | bool | Token string exists and created_at is set |
| should_reuse() | bool | Age under 30 minutes |
| should_reauthorize() | bool | Age under 24 hours |
| is_expired() | bool | Age over 24 hours |
| get_age_seconds() | int | Seconds since token was issued |
| get_status() | String | "FRESH", "STALE", or "EXPIRED" |

---

## MWAError Codes

| Code | Constant | Retryable | Cause |
|------|----------|-----------|-------|
| 1001 | USER_DECLINED | No | User tapped Reject |
| 1002 | WALLET_NOT_INSTALLED | No | No wallet app found |
| 1003 | SESSION_ALREADY_ACTIVE | No | Concurrent call blocked |
| 1004 | AUTH_TOKEN_INVALID | Yes | Token rejected by wallet |
| 1005 | AUTH_TOKEN_EXPIRED | Yes | Token too old |
| 2001 | TRANSACTION_EXPIRED | Yes | Blockhash not found |
| 2002 | TRANSACTION_FAILED | No | On-chain failure |
| 2003 | SIMULATION_FAILED | No | Preflight failed |
| 2004 | INSUFFICIENT_FUNDS | No | Not enough SOL |
| 3001 | NETWORK_TIMEOUT | Yes | 60s timeout exceeded |
| 3002 | RPC_ERROR | Yes | RPC server error |
