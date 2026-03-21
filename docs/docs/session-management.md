---
sidebar_position: 5
title: Session Management
description: Connect, disconnect, and reconnect patterns for Invoke SDK.
---

# Session Management

## Session States

The SDK is always in one of these states:
```gdscript
enum State {
    IDLE,          # No session, no token
    CONNECTING,    # Waiting for wallet response
    AUTHORIZED,    # Connected, token valid
    REAUTHORIZING, # Silent reauth in progress
    ERROR          # Last operation failed
}
```

Listen for state changes:
```gdscript
MWA.state_changed.connect(func(state):
    match state:
        MWA.State.AUTHORIZED:    show_dashboard()
        MWA.State.CONNECTING:    show_loading()
        MWA.State.ERROR:         show_error()
)
```

## Connect Flow

### First-Time User

App launches → No token in cache → MWA.authorize() → Wallet opens → User approves → authorized signal → Token saved to cache

### Returning User

App launches → Token found in cache:
- Fresh (under 30 min) → Reuse directly, no wallet call
- Stale (30min-24h) → MWA.reauthorize() silent background call
- Expired (over 24h) → MWA.authorize() wallet popup

## Disconnect vs Deauthorize

### MWA.disconnect()
Local only — no wallet call. Token stays in cache. Use when user navigates away.
```gdscript
MWA.disconnect()
```

### MWA.deauthorize(auth_token)
Calls wallet to invalidate token server-side. Use when user explicitly logs out.
```gdscript
MWA.deauthorize(current_token)
```

### MWA.full_logout()
Deauthorizes + clears cache + resets state. Use for the Disconnect Wallet button.
```gdscript
MWA.full_logout()
```

## Handling Wallet Not Installed
```gdscript
MWA.error.connect(func(code, message):
    if code == MWAError.Code.WALLET_NOT_INSTALLED:
        OS.shell_open("https://play.google.com/store/apps/details?id=app.phantom")
)
```

## Handling Timeout

All wallet operations have a 60-second timeout. On timeout you get NETWORK_TIMEOUT (3001). Reset your UI and let the user try again.

## Handling Token Invalidation
```gdscript
MWA.error.connect(func(code, message):
    if code == MWAError.Code.AUTH_TOKEN_INVALID:
        cache_manager.clear_all()
        MWA.authorize(identity, "devnet")
)
```

## One Session at a Time

Invoke blocks concurrent wallet sessions. Always wait for a signal before calling another wallet method. Concurrent calls return SESSION_ALREADY_ACTIVE (1003).

## App Lifecycle
```gdscript
func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_IN:
        if not MWA.is_connected():
            try_reconnect()
```
