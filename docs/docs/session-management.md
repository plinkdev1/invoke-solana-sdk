---
sidebar_position: 5
title: Session Management
description: Connect, disconnect, and reconnect patterns for Invoke SDK.
---

# Session Management

## Connect Flow

### First-Time User

```
App opens
  → No token in cache
  → Show Connect Wallet button
  → User taps Connect
  → _mwa.authorize(...)
  → System wallet picker opens
  → User selects wallet and approves
  → authorized signal fires
  → Token saved to encrypted cache
  → Navigate to dashboard
```

### Returning User (within 30 min)

```
App opens
  → Token found in cache, age < 30 min
  → _mwa.tryReauthorizeFromCache(...)
  → Silent reconnect — no wallet interaction
  → reauthorized signal fires
  → Navigate to dashboard
```

### Returning User (30 min to 24 hrs)

```
App opens
  → Token found in cache, age < 24 hrs
  → _mwa.tryReauthorizeFromCache(...)
  → reauthorize() called internally
  → Wallet picker may appear once
  → reauthorized signal fires
  → Navigate to dashboard
```

## Disconnect

Invoke SDK uses **instant disconnect** — no wallet popup required.

```gdscript
func disconnect() -> void:
    _mwa.disconnectWallet()
    # deauthorized signal fires immediately
    # Navigate back to wallet picker
```

This clears the encrypted cache and emits `deauthorized`. The wallet app is never opened.

## Handling Errors

```gdscript
func _on_mwa_error(code: int, message: String) -> void:
    match code:
        1001:  # USER_DECLINED
            show_message("Connection cancelled.")
        1002:  # WALLET_NOT_INSTALLED
            OS.shell_open("https://play.google.com/store/apps/details?id=com.solflare.mobile")
        1004:  # AUTH_TOKEN_INVALID
            _mwa.cacheClear()
            _mwa.authorize("solana:devnet", "My Game", "https://mygame.dev", "https://mygame.dev/icon.png")
        1005:  # AUTH_TOKEN_EXPIRED
            show_connect_button()
        _:
            show_message("Error %d: %s" % [code, message])
```

## One Operation at a Time

The wallet picker can only be open once. Do not call another wallet method while a previous operation is pending. Wait for either a success signal or `mwa_error` before proceeding.

## Wallet Picker Behavior

MWA always opens the system wallet picker on every sign operation — this is a protocol requirement, not a limitation of Invoke SDK. The only exception is `tryReauthorizeFromCache()` within the 30-minute window, which is completely silent.
