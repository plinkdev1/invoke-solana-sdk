---
sidebar_position: 1
title: Getting Started
description: Install Invoke SDK into your Godot project and connect to Phantom in under 5 minutes.
---

# Getting Started

Invoke is a Godot Engine Android SDK for Solana Mobile Wallet Adapter (MWA).
It lets your Godot game connect to Phantom, Backpack, and Solflare wallets
on Android with a clean GDScript API.

## Prerequisites

- Godot Engine 4.2+
- Android Studio (Giraffe or newer)
- Android device or emulator with API 28+
- A Solana wallet installed on the device (Phantom, Backpack, or Solflare)

## Installation

### Step 1 — Download the plugin

Download the latest release from GitHub:
`
https://github.com/plinkdev1/invoke-solana-sdk/releases/latest
`

Download `invoke-sdk-vX.X.X.zip` and extract it.

### Step 2 — Copy into your Godot project

Copy the `addons/mobile_wallet_adapter/` folder into your Godot project root.

Your project should look like:
`
your-game/
├── addons/
│   └── mobile_wallet_adapter/
│       ├── plugin.cfg
│       ├── MobileWalletAdapter.gd
│       ├── MWAAuthToken.gd
│       └── ... (other SDK files)
├── scenes/
└── project.godot
`

### Step 3 — Enable the plugin

1. Open your project in Godot
2. Go to **Project → Project Settings → Plugins**
3. Find **InvokeMWA** and set it to **Enabled**

### Step 4 — Add as AutoLoad

1. Go to **Project → Project Settings → AutoLoad**
2. Add `addons/mobile_wallet_adapter/MobileWalletAdapter.gd`
3. Set the name to `MWA`

### Step 5 — Configure Android export

1. Go to **Project → Export → Add → Android**
2. Set minimum SDK to **28**, target SDK to **34**
3. Under **Plugins**, enable **InvokeMWA**
4. Add permission: `INTERNET`

## Your First Connection
`gdscript
extends Node

func _ready() -> void:
    # Connect to wallet signals
    MWA.authorized.connect(_on_authorized)
    MWA.error.connect(_on_error)

func connect_wallet() -> void:
    var identity = MWAIdentity.new(
        "My Game",                    # App name shown in wallet
        "https://mygame.dev",         # App URL
        "favicon.ico"                 # App icon
    )
    MWA.authorize(identity, "devnet")

func _on_authorized(auth_token: String, account: MWAAccount) -> void:
    print("Connected! Address: ", account.get_display_address())

func _on_error(code: int, message: String) -> void:
    print("Error %d: %s" % [code, message])
`

## Next Steps

- [Core Concepts](./core-concepts) — understand how MWA works
- [API Reference](./api-reference) — every method and signal
- [Auth Cache Guide](./auth-cache) — skip the wallet popup on relaunch
