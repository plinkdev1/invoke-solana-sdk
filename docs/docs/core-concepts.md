---
sidebar_position: 2
title: Core Concepts
description: Understand how Mobile Wallet Adapter works with Godot Engine.
---

# Core Concepts

## What is Mobile Wallet Adapter?

Mobile Wallet Adapter (MWA) is a protocol that lets Android apps communicate
with locally installed Solana wallet apps (Phantom, Backpack, Solflare).
When your game calls `MWA.authorize()`, Android opens the wallet app,
the user approves, and the wallet sends back an auth token your game can
use for signing transactions.

No private keys ever leave the wallet app. Your game never sees them.

## How it Works
`
Your Godot Game
      │
      │ MWA.authorize()
      ▼
Invoke SDK (GDScript)
      │
      │ Kotlin plugin bridge
      ▼
Android MWA SDK
      │
      │ Android Intent
      ▼
Phantom / Backpack / Solflare
      │
      │ Auth token + public key
      ▼
Your game receives: authorized signal
`

## Authorization vs Reauthorization

**First connect (authorize):**
- Opens the wallet app
- User sees your app name and approves
- Wallet returns an auth token
- Invoke saves the token to cache

**Subsequent connects (reauthorize):**
- No wallet popup
- Invoke sends the cached token silently
- Wallet validates and refreshes the token
- User experience: instant, invisible reconnect

This is why the auth cache matters — without it, users see the
wallet approval popup every single time the app launches.

## The Auth Token

The auth token is a string the wallet gives you after authorization.
It proves your app has been approved. You use it to:

- Skip the approval popup on relaunch (reauthorize)
- Sign transactions
- Sign messages

Tokens can expire. Invoke handles this automatically:

| Token age | Action |
|-----------|--------|
| Under 30 minutes | Reuse directly — no wallet call |
| 30 min to 24 hours | Silent reauthorize — no popup |
| Over 24 hours | Full authorize — wallet popup |
| Invalid exception | Clear cache, full authorize |

## Signals vs Callbacks

Invoke uses Godot's signal system for all wallet responses.
Every operation is async — you call a method, connect to a signal,
and the result arrives in your signal handler.
`gdscript
# Call the method
MWA.authorize(identity, "devnet")

# Handle the result via signal
func _on_authorized(auth_token: String, account: MWAAccount) -> void:
    print("Connected: ", account.get_display_address())
`

Never try to get a return value directly from MWA methods —
they are all fire-and-forget. Results always come via signals.

## Supported Wallets

| Wallet | Package | Minimum Version |
|--------|---------|-----------------|
| Phantom | app.phantom | 23.0+ |
| Backpack | com.backpack.wallet | Any current |
| Solflare | com.solflare.mobile | 4.0+ |

## Android Only

The Kotlin plugin only runs on Android. On desktop (Windows, macOS, Linux),
the plugin is not available and all wallet calls are gracefully ignored
with a warning. This lets you develop your game on desktop and only
test wallet features on a real Android device.
