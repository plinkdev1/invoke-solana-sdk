---
sidebar_position: 4
title: Auth Cache Guide
description: Configure the authorization token cache to skip wallet popups on relaunch.
---

# Auth Cache Guide

## Why the Cache Matters

Without caching, every app launch shows the wallet approval popup.
With caching, the first launch asks for approval — every subsequent
launch reconnects silently in the background.

This is the difference between a polished app and an annoying one.

## Default Behavior

Invoke automatically uses the best cache backend for the platform:

| Platform | Default Backend | Storage |
|----------|----------------|---------|
| Android | MWASecureCache | EncryptedSharedPreferences |
| Desktop (dev) | MWAFileCache | JSON file in user:// |

You don't need to configure anything for the default to work.

## Cache Backends

### MWAMemoryCache — Development / Testing

Tokens live in RAM only. Lost when the app closes.
Use this during development when you want a fresh auth every run.
`gdscript
var cache = MWACacheManager.new(MWACacheManager.Backend.MEMORY)
MWA.set_cache_manager(cache)
`

### MWAFileCache — Default (non-Android)

Tokens stored as JSON in `user://mwa_auth/tokens.dat`.
Survives app restarts. Not encrypted — fine for desktop development.
`gdscript
var cache = MWACacheManager.new(MWACacheManager.Backend.FILE)
MWA.set_cache_manager(cache)
`

### MWASecureCache — Production (Android)

Tokens stored in Android EncryptedSharedPreferences.
AES256-GCM encryption at rest. Default on Android.
`gdscript
var cache = MWACacheManager.new(MWACacheManager.Backend.SECURE)
MWA.set_cache_manager(cache)
`

## Token Expiry

Invoke uses a two-tier expiry system:
`
Token age < 30 minutes  →  Reuse directly (no wallet call at all)
Token age 30min–24h     →  Silent reauthorize (background call, no popup)
Token age > 24h         →  Full authorize (wallet popup required)
Token invalid exception →  Clear cache + full authorize
`

## Auto-Reconnect Pattern

The recommended pattern for app startup:
`gdscript
extends Node

var identity: MWAIdentity
var cache_manager: MWACacheManager

func _ready() -> void:
    identity = MWAIdentity.new(
        "My Game", "https://mygame.dev", "favicon.ico")
    cache_manager = MWACacheManager.create_best()

    MWA.authorized.connect(_on_authorized)
    MWA.reauthorized.connect(_on_reauthorized)
    MWA.error.connect(_on_error)

    # Try to reconnect from cache on startup
    try_reconnect()

func try_reconnect() -> void:
    var key = MWAAuthCache.make_key("app.phantom")

    if cache_manager.has_fresh_token(key):
        # Token is fresh — reuse directly, no wallet call
        var token = cache_manager.load_auth_token(key)
        _on_authorized(token.token, token.account)

    elif cache_manager.has_reauthorizable_token(key):
        # Token is stale — silent reauth (no popup)
        var token = cache_manager.load_auth_token(key)
        MWA.reauthorize(token.token, identity)

    else:
        # No token or expired — full authorize (wallet popup)
        MWA.authorize(identity, "devnet")

func _on_authorized(auth_token: String, account: MWAAccount) -> void:
    print("Connected: ", account.get_display_address())

func _on_reauthorized(auth_token: String) -> void:
    print("Silently reconnected.")

func _on_error(code: int, message: String) -> void:
    if code == MWAError.Code.AUTH_TOKEN_INVALID:
        # Token rejected — clear cache and do full authorize
        cache_manager.clear_all()
        MWA.authorize(identity, "devnet")
`

## Clearing the Cache
`gdscript
# Clear one wallet
cache_manager.clear_auth_token(MWAAuthCache.make_key("app.phantom"))

# Clear everything (full logout)
cache_manager.clear_all()
MWA.full_logout()
`

## Custom Cache Backend

Extend `MWAAuthCache` to implement your own storage:
`gdscript
class_name MyCustomCache
extends MWAAuthCache

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    # Your storage logic here
    return true

func load_auth_token(key: String) -> MWAAuthToken:
    # Your retrieval logic here
    return null

func clear_auth_token(key: String) -> bool:
    return true

func clear_all() -> bool:
    return true
`

## Security Notes

1. Never log auth tokens — not even the first/last few characters
2. `MWAFileCache` is NOT encrypted — do not use in production Android builds
3. `MWASecureCache` uses AES256-GCM — suitable for production
4. Token expiry is enforced app-side — the wallet may invalidate earlier
5. On `AUTH_TOKEN_INVALID`: always clear cache before retrying
