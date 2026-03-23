---
sidebar_position: 6
title: Wallet Compatibility
description: Tested wallet compatibility for Invoke SDK on Android.
---

# Wallet Compatibility

Tested on Samsung Galaxy Android 14, March 2026.

## Compatibility Table

| Wallet | Package | authorize | signTx | signAndSend | signMessage | Notes |
|--------|---------|-----------|--------|-------------|-------------|-------|
| **Solflare** | com.solflare.mobile | ✅ | ✅ | ✅ | ✅ | Best for testing |
| **Jupiter** | ag.jup.jupiter.android | ✅ | ✅ | ✅ | ✅ | |
| **Phantom** | app.phantom | ❌ | — | — | — | Domain not verified |
| **Backpack** | com.backpack.wallet | ❌ | — | — | — | MWA 2.0 incompatible |

## Solflare

Full MWA 2.0.3 support. Recommended for development and testing. All operations work correctly across Devnet, Testnet, and Mainnet.

## Jupiter

Full MWA 2.0.3 support. All operations work correctly.

## Phantom

Phantom rejects authorization requests from unverified dApp domains. To use Phantom, register your dApp domain at [developer.phantom.app](https://developer.phantom.app). Until then, Phantom will return `USER_DECLINED` on every authorize attempt.

## Backpack

Backpack does not implement MWA 2.0 and is not compatible with Invoke SDK. Connection attempts will fail with `WALLET_NOT_INSTALLED` or `UNKNOWN`.

## Detecting Installed Wallets

```gdscript
_mwa.wallet_apps_detected.connect(_on_wallets_detected)
_mwa.getInstalledWallets()

func _on_wallets_detected(json: String) -> void:
    var wallets = JSON.parse_string(json)
    for wallet in wallets:
        print("Found: ", wallet)
```

## Known Limitations

- MWA always opens the system wallet picker on every sign operation — by design
- Silent reconnect only works within the 30-minute cache window
- Solscan transaction links only work on Testnet and Mainnet (devnet not supported by Solscan)
