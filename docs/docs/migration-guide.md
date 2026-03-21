---
sidebar_position: 6
title: Migration Guide
description: Upgrading from the old Godot MWA SDK to Invoke.
---

# Migration Guide

## Old SDK → Invoke

This guide covers migrating from the previous Godot MWA SDK to Invoke.

## What Changed

| Feature | Old SDK | Invoke |
|---------|---------|--------|
| authorize() | Partial — missing params | Full MWA 2.0 spec |
| reauthorize() | Missing | Added |
| deauthorize() | Missing | Added |
| signMessages() | Missing | Added |
| getCapabilities() | Missing | Added |
| Auth token cache | Missing | Built-in (3 backends) |
| Session state machine | None | Full state machine |
| Error codes | Generic | Typed MWAError codes |
| Wallet detection | None | getInstalledWallets() |
| Desktop fallback | Crashes | Graceful stub mode |

## Step 1 — Replace the addon folder

Remove the old addon folder and replace with Invoke:
```
# Remove old
rm -rf addons/mobile_wallet_adapter/

# Add Invoke
# Copy addons/mobile_wallet_adapter/ from the Invoke release zip
```

## Step 2 — Update authorize() calls

Old SDK:
```gdscript
# Old — incomplete params
mwa_plugin.authorize("devnet", "My Game", "https://mygame.dev", "icon.png")
```

Invoke:
```gdscript
# New — use MWAIdentity object
var identity = MWAIdentity.new("My Game", "https://mygame.dev", "favicon.ico")
MWA.authorize(identity, "devnet")
```

## Step 3 — Update signal connections

Old SDK signals (if any) were inconsistent. Invoke uses:
```gdscript
# Connect all signals in _ready()
MWA.authorized.connect(_on_authorized)
MWA.reauthorized.connect(_on_reauthorized)
MWA.deauthorized.connect(_on_deauthorized)
MWA.disconnected.connect(_on_disconnected)
MWA.transaction_signed.connect(_on_transaction_signed)
MWA.transaction_sent.connect(_on_transaction_sent)
MWA.message_signed.connect(_on_message_signed)
MWA.capabilities_received.connect(_on_capabilities_received)
MWA.error.connect(_on_error)
```

## Step 4 — Add auth cache (new feature)

The old SDK had no caching — users saw wallet popups on every launch.
Invoke adds this automatically. No code changes needed for the default.

For manual control:
```gdscript
# On app start — try silent reconnect first
var key = MWAAuthCache.make_key("app.phantom")
if cache_manager.has_reauthorizable_token(key):
    var token = cache_manager.load_auth_token(key)
    MWA.reauthorize(token.token, identity)
else:
    MWA.authorize(identity, "devnet")
```

## Step 5 — Update error handling

Old SDK used generic errors. Invoke uses typed codes:
```gdscript
# Old
func _on_error(message: String) -> void:
    print("Error: ", message)

# New
func _on_error(code: int, message: String) -> void:
    match code:
        MWAError.Code.USER_DECLINED:
            show_declined_message()
        MWAError.Code.WALLET_NOT_INSTALLED:
            show_install_prompt()
        MWAError.Code.AUTH_TOKEN_INVALID:
            cache_manager.clear_all()
            MWA.authorize(identity, "devnet")
        _:
            print("Error %d: %s" % [code, message])
```

## Step 6 — Add disconnect/logout (new)
```gdscript
# Soft disconnect — token kept in cache
MWA.disconnect()

# Full logout — token cleared
MWA.full_logout()
```

## Breaking Changes Summary

1. ``authorize()`` now takes ``MWAIdentity`` object instead of raw strings
2. Error signal now has two params: ``(code: int, message: String)``
3. Plugin singleton name is now ``InvokeMWA`` (was ``GodotMWA``)
4. All GDScript class names are now typed (MWAAccount, MWAAuthToken, etc.)
