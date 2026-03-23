---
sidebar_position: 2
title: Core Concepts
description: Understand how Mobile Wallet Adapter works with Godot Engine.
---

# Core Concepts

## What is Mobile Wallet Adapter?

Mobile Wallet Adapter (MWA) 2.0.3 is a protocol that lets Android apps communicate with locally installed Solana wallet apps. When your game calls `authorize()`, Android opens the wallet app, the user approves, and the wallet returns an auth token your game uses for signing.

No private keys ever leave the wallet app. Your game never sees them.

## How It Works

```
Your Godot Game (GDScript)
        │
        │  _mwa.authorize(...)
        ▼
  MWAPlugin.kt  (@UsedByGodot bridge)
        │
        │  Kotlin coroutine
        ▼
  MWABridge.kt  (MWA 2.0.3 SDK)
        │
        │  Android Intent
        ▼
  Solflare / Jupiter / Phantom
        │
        │  auth_token + public_key
        ▼
  emitSignal("authorized", auth_token, address)
        │
        ▼
  _on_authorized() in your GDScript
```

## Signals — The Only Way to Get Results

Every wallet operation is async. You call a method, and the result arrives via signal. Never expect a return value from any MWA method.

```gdscript
# Call the method
_mwa.authorize("solana:devnet", "My Game", "https://mygame.dev", "https://mygame.dev/icon.png")

# Result arrives here
func _on_authorized(auth_token: String, address: String) -> void:
    print("Connected: ", address)
```

## Auth Token

The auth token is a string the wallet gives you after authorization. It proves your app has permission to request signatures. Invoke SDK stores it in encrypted cache — your GDScript never needs to read or store it directly.

## Token Lifecycle

| Token age | What happens |
|-----------|-------------|
| Under 30 min | Silent reconnect — no wallet interaction |
| 30 min to 24 hrs | `reauthorize()` — wallet picker may appear once |
| Over 24 hrs | Session expired — full `authorize()` required |

## Android Only

The plugin only runs on Android. Always guard calls with `Engine.has_singleton("InvokeMWA")`. In the editor and on desktop, the singleton is absent — your game should handle this gracefully.

## Wallet Compatibility

| Wallet | Status | Notes |
|--------|--------|-------|
| Solflare | ✅ Full support | Best for testing |
| Jupiter | ✅ Full support | |
| Phantom | ❌ Domain not verified | Register at developer.phantom.app |
| Backpack | ❌ MWA 2.0 incompatible | |
