---
sidebar_position: 1
title: Getting Started
description: Install Invoke SDK into your Godot 4 project and connect to a Solana wallet on Android.
---

# Getting Started

Invoke SDK is a native Android plugin for Godot 4 that exposes the full Solana Mobile Wallet Adapter 2.0.3 API to GDScript. Connect to Solflare, Jupiter, and other MWA-compatible wallets from any Godot Android game.

## Prerequisites

- Godot Engine 4.2.2+
- JDK 17
- Android SDK (API 28+)
- Android device with a Solana wallet installed ([Solflare](https://play.google.com/store/apps/details?id=com.solflare.mobile) or [Jupiter](https://play.google.com/store/apps/details?id=ag.jup.jupiter.android))

## Installation

### Step 1 — Copy the AAR

Copy `InvokeMWA.aar` into your project:

```
your-game/
└── addons/
    └── mobile_wallet_adapter/
        └── android/
            └── InvokeMWA.aar
```

### Step 2 — Enable the plugin

In Godot editor: **Project → Export → Android → Plugins → InvokeMWA ✅**

### Step 3 — Configure Android export

- Minimum SDK: **28**
- Target SDK: **34**
- Permission: `INTERNET`

### Step 4 — Connect in GDScript

```gdscript
var _mwa = null

func _ready() -> void:
    if Engine.has_singleton("InvokeMWA"):
        _mwa = Engine.get_singleton("InvokeMWA")
        _mwa.authorized.connect(_on_authorized)
        _mwa.mwa_error.connect(_on_mwa_error)

func connect_wallet() -> void:
    _mwa.authorize("solana:devnet", "My Game", "https://mygame.dev", "https://mygame.dev/icon.png")

func _on_authorized(auth_token: String, wallet_address: String) -> void:
    print("Connected: ", wallet_address)

func _on_mwa_error(code: int, message: String) -> void:
    print("Error %d: %s" % [code, message])
```

:::tip
Always check `Engine.has_singleton("InvokeMWA")` before calling any method — the plugin is only available on Android builds, not in the editor.
:::

## Next Steps

- [Core Concepts](./core-concepts) — understand how MWA works
- [API Reference](./api-reference) — every method and signal
- [Auth Cache Guide](./auth-cache) — skip the wallet popup on relaunch
