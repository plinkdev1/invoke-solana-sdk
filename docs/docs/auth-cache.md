---
sidebar_position: 4
title: Auth Cache
description: How Invoke SDK stores and reuses auth tokens to skip wallet popups.
---

# Auth Cache

## Why It Matters

Without caching, every app launch shows the wallet approval popup — even if the user connected yesterday. With Invoke's encrypted cache, the first launch asks for approval. Every subsequent launch reconnects silently in the background.

## How It Works

Invoke stores the auth token in Android `EncryptedSharedPreferences` using AES256-GCM key encryption and AES256-SIV value encryption. Tokens are keyed by wallet package name so multiple wallets can be cached simultaneously.

Tokens are **never logged** and **never exposed to GDScript** — all cache reads happen in Kotlin inside `AuthCacheImpl.kt`.

## Three-Tier Reconnect Strategy

```
App opens → tryReauthorizeFromCache()
  │
  ├─ Token age < 30 min  → Silent reconnect. No wallet interaction. ✅
  │                         Emits: reauthorized
  │
  ├─ Token age < 24 hrs  → reauthorize(). Wallet picker may appear once. ✅
  │                         Emits: reauthorized
  │
  └─ Token age > 24 hrs  → Session expired. Full authorize() required.
                            Emits: mwa_error (code 1005)
```

## Recommended Startup Pattern

```gdscript
func _ready() -> void:
    if Engine.has_singleton("InvokeMWA"):
        _mwa = Engine.get_singleton("InvokeMWA")
        _mwa.reauthorized.connect(_on_reauthorized)
        _mwa.mwa_error.connect(_on_mwa_error)

        if _mwa.cacheHasToken():
            _show_loading("Reconnecting...")
            _mwa.tryReauthorizeFromCache("My Game", "https://mygame.dev", "https://mygame.dev/icon.png")
        else:
            _show_connect_button()

func _on_reauthorized(_auth_token: String) -> void:
    _hide_loading()
    # Navigate to main screen

func _on_mwa_error(code: int, _message: String) -> void:
    _hide_loading()
    if code == 1005:  # AUTH_TOKEN_EXPIRED — no valid cache
        _show_connect_button()
    else:
        _show_error(code)
```

## Cache Inspection

```gdscript
_mwa.cacheHasToken()       # bool — any token cached?
_mwa.cacheGetAddress()     # String — cached wallet public key
_mwa.cacheGetAgeSeconds()  # int — how old is the token?
_mwa.cacheIsStale()        # bool — older than 30 minutes?
```

## Clearing the Cache

```gdscript
# Clear active wallet only
_mwa.cacheClear()

# Clear all wallets (full logout)
_mwa.cacheClearAll()
```

## Security Notes

- Tokens stored with AES256-GCM + AES256-SIV via `EncryptedSharedPreferences`
- Never log auth tokens — not even partial characters
- Cache is app-private — inaccessible to other apps
- On `AUTH_TOKEN_INVALID` (code 1004): call `cacheClear()` then `authorize()` again

## Storage Backends

Invoke SDK supports three storage backends for the auth token cache. The backend is configurable — useful for development, testing, and production scenarios.

| Backend | Persistence | Security | Use Case |
|---------|-------------|----------|----------|
| **Keystore** | ✅ Persists across launches | Hardware-backed (TEE) | Production — recommended for all shipped apps |
| **File** | ✅ Persists across launches | Software encryption | Testing on emulators or devices without full Keystore support |
| **Memory** | ❌ Cleared on app close | In-memory only | Development — forces full re-auth on every launch for flow testing |

### Keystore
Uses Android's hardware-backed Keystore system (TEE — Trusted Execution Environment). The encryption key lives in secure hardware and cannot be extracted, even with root access. This is the default and recommended backend for production.

### File
Stores the encrypted token as a file in the app's private storage directory. The token is still encrypted, but the key is stored in software rather than hardware. Useful for emulators and older devices that lack full Keystore support.

### Memory
Stores the token in RAM only. The token is lost when the app closes, forcing a full `authorize()` on every launch. Ideal during development when you want to repeatedly test the full wallet connection flow without manually clearing cached tokens.

### Switching Backends (GDScript)

```gdscript
# Set before calling authorize() or tryReauthorizeFromCache()
_mwa.setCacheBackend("keystore")  # "keystore" | "file" | "memory"
```

> **Note:** Switching backends at runtime clears the existing cache. Always set your backend once at startup before any auth calls.
