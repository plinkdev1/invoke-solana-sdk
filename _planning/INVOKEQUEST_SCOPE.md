# INVOKE SDK — PHASE 3 INVOKEQUEST SCOPE
## Example App Full Specification
## Francisco (Franny) · Portugal · 2026

---

## WHAT INVOKEQUEST IS

InvokeQuest is the third grant deliverable — a complete open source
Godot 4.x Android app that demonstrates every Invoke SDK feature.

It serves two purposes:
1. PROOF — shows the grant committee every SDK method works on a real device
2. REFERENCE — game developers clone it to learn how to integrate Invoke

Package: dev.invoke.invokequest
Min SDK: 28 (Android 9)
Target SDK: 34 (Android 14)
Godot version: 4.2+

---

## DESIGN LANGUAGE

Neobrutalism + Glassmorphism hybrid.
Reference: Phantom Wallet, Jupiter, Meteora UI aesthetic.

### Colors (from DesignTokens.gd)
- COLOR_BG:           #080A0F (near-black)
- COLOR_SURFACE:      rgba(255,255,255,0.05) — frosted glass
- COLOR_SURFACE_2:    rgba(255,255,255,0.08) — brighter glass
- COLOR_GLASS_BORDER: rgba(255,255,255,0.10) — card borders
- COLOR_PURPLE:       #9945FF (Solana Purple)
- COLOR_PURPLE_DIM:   #9945FF @ 15%
- COLOR_GREEN:        #14F195 (Solana Green/Teal)
- COLOR_GREEN_DIM:    #14F195 @ 12%
- COLOR_YELLOW:       #FFB938
- COLOR_RED:          #FF4F4F
- COLOR_WHITE:        #FFFFFF
- COLOR_WHITE_60:     rgba(255,255,255,0.6)
- COLOR_WHITE_30:     rgba(255,255,255,0.3)

### Fonts
- Display Bold:   SpaceGrotesk-Bold.ttf     — screen titles, wallet name
- Display Semi:   SpaceGrotesk-SemiBold.ttf — card labels, buttons
- Body Regular:   DMSans-Regular.ttf        — body text (default)
- Body Medium:    DMSans-Medium.ttf         — body text emphasis
- Mono Regular:   JetBrainsMono-Regular.ttf — addresses, hashes
- Mono Semi:      JetBrainsMono-SemiBold.ttf — amounts

### Font Sizes (DesignTokens.gd constants)
- FONT_SIZE_XL:  36  — balance, hero titles
- FONT_SIZE_LG:  24  — section titles
- FONT_SIZE_MD:  18  — card titles, buttons
- FONT_SIZE_SM:  14  — body text
- FONT_SIZE_XS:  12  — labels, badges
- FONT_SIZE_XXS: 10  — addresses, hashes

---

## DIRECTORY STRUCTURE

example/invokequest/
├── project.godot
├── assets/
│   ├── fonts/          (Space Grotesk, DM Sans, JetBrains Mono .ttf files)
│   ├── icons/
│   │   ├── ui/         (ic_home, ic_sign, ic_cache, ic_settings, etc.)
│   │   ├── wallets/    (wallet_phantom.png, wallet_backpack.png, wallet_solflare.png)
│   │   └── status/     (ic_status_success, ic_status_pending, ic_status_error)
│   ├── images/
│   │   ├── splash/     (splash_bg_aurora.png 1080x1920)
│   │   └── misc/       (solana_logo_white.png, godot_logo_white.png)
│   ├── textures/       (noise_subtle.png, glass_gradient.png, grid_dots.png)
│   └── themes/
│       ├── SolanaQuestTheme.tres
│       └── StyleBoxes/ (StyleGlassCard, StylePrimaryBtn, StyleSecondaryBtn, etc.)
├── scenes/
│   ├── components/     (GlassCard, WalletBadge, AddressChip, TxStatusRing, etc.)
│   └── screens/        (Splash, WalletPicker, AuthResult, Dashboard, etc.)
├── scripts/
│   ├── autoloads/      (SceneManager.gd, DesignTokens.gd)
│   └── screens/        (one .gd per screen)
└── shaders/
    ├── glass_card.gdshader
    ├── aurora_background.gdshader
    ├── glow_pulse.gdshader
    └── noise_gradient.gdshader

---

## 10 SCREENS (BUILD ORDER)

### Screen 1 — Splash.tscn
- Aurora animated background (shader)
- InvokeQuest logo centered
- Floating particle system (Solana coins)
- Auto-advance after 2.5s
- On advance: check auth cache → navigate accordingly

### Screen 2 — WalletPicker.tscn
- "Connect Your Wallet" heading
- Three GlassCard components: Phantom, Backpack, Solflare
- Each card: wallet icon + name + installed/not installed badge
- Stagger animation on enter (cards fade + slide up, 80ms apart)
- Select wallet → trigger MWA.authorize()
- Loading spinner overlay on selected card

### Screen 3 — AuthResult.tscn
- Show: connected wallet name + icon
- Show: truncated public address (AddressChip component)
- Show: "Session cached ✓" or "New session" badge
- Continue button → Dashboard

### Screen 4 — Dashboard.tscn
- Header: wallet name + truncated address
- Balance card: SOL balance from devnet RPC
- Quick actions grid (2x2):
  - Sign Transaction
  - Sign & Send
  - Sign Message
  - Get Capabilities
- Auth cache status widget at bottom
- Settings icon (top right)
- Disconnect button

### Screen 5 — SignTransaction.tscn
- Build dummy devnet tx (transfer 0 SOL to self)
- Show raw tx bytes (hex, truncated)
- "Request Signature" button → MWA.sign_transactions()
- Loading state with spinner
- Success: show signed bytes + copy button
- Error: show error card with code + message

### Screen 6 — SignAndSend.tscn
- Same as Sign Transaction but calls sign_and_send_transactions()
- Show returned signature (base58)
- "View on Solscan" deep link button
- Success/error states

### Screen 7 — SignMessage.tscn
- Text input for custom message
- Pre-filled: "Invoke SDK Demo — {timestamp}"
- "Sign Message" button → MWA.sign_messages()
- Show signed bytes in mono font
- Copy button

### Screen 8 — Capabilities.tscn
- "Get Capabilities" button → MWA.get_capabilities()
- Display result as formatted table:
  - supports_clone_authorization: yes/no badge
  - supports_sign_and_send: yes/no badge
  - max_transactions_per_request: number
  - max_messages_per_request: number

### Screen 9 — AuthCache.tscn
- Live cache status panel:
  - Token present: yes/no
  - Token age: X seconds/minutes
  - Token status: FRESH / STALE / EXPIRED
  - Wallet address: truncated
- Buttons: "Clear Cache" / "Force Reconnect" / "Test Reauthorize"
- Animated flow diagram showing cache → reauthorize path
- Console log panel showing last 5 cache operations

### Screen 10 — Settings.tscn
- Network: Devnet / Testnet / Mainnet (radio buttons)
- Cache backend: Memory / File / Secure Keystore
- RPC endpoint: default + custom input
- App version + SDK version
- "Disconnect & Clear All" danger zone button (red)

---

## REUSABLE COMPONENTS (build before screens)

### GlassCard.tscn
PanelContainer with glass_card.gdshader applied.
StyleBox: border_radius 16, border 1px, border_color white@10%
Use for all card containers.

### WalletBadge.tscn
HBoxContainer: wallet icon (44x44) + name label + installed badge

### AddressChip.tscn
HBoxContainer: mono address label (first4...last4) + copy button
On copy: OS.clipboard = full_address, play check animation

### TxStatusRing.tscn
48x48 Control with custom _draw() arc.
States: pending (spinning) / confirming (fills) / confirmed (green) / failed (red)

### BottomSheet.tscn
Slide-up panel with backdrop overlay.
Animations: sheet_open (0.3s ease_out_quart) / sheet_close (0.22s ease_in_quart)

### LoadingSpinner.tscn
Three dots pulse OR rotating arc (270° sweep, 1.2s per revolution)

---

## AUTOLOADS NEEDED

### DesignTokens.gd
All color constants, font size constants.
Autoload name: DesignTokens

### SceneManager.gd
push_scene(path), pop_scene(), replace_scene(path)
Navigation stack with back button support.
Transition animations: slide-left push, slide-right pop, fade replace.
Autoload name: SceneManager

---

## SHADERS NEEDED

### glass_card.gdshader
shader_type canvas_item
Inputs: blur_amount (0-20), tint_color (rgba), border_opacity (0-1)
Effect: frosted glass with blur + tint + thin border

### aurora_background.gdshader
Animated gradient flow (purple → green → purple)
Used at full intensity on Splash only.
Other screens: time_scale = 0.0 (frozen, very dim)

### glow_pulse.gdshader
Pulsing glow effect for connected indicator dot.

---

## SCENE BACKGROUND LAYER ORDER

Every screen (bottom to top):
1. ColorRect — full screen, COLOR_BG (#080A0F)
2. ShaderMaterial (aurora_background) — frozen + dim on most screens
3. TextureRect (noise_subtle.png) — white@4%, tiled
4. [Screen content]
5. CanvasLayer — overlays (BottomSheet, LoadingOverlay)

---

## BUILD ORDER FOR PHASE 3

1. project.godot — Godot project config
2. DesignTokens.gd — all color + font constants
3. SceneManager.gd — navigation system
4. glass_card.gdshader — needed by all screens
5. aurora_background.gdshader — needed by Splash
6. GlassCard.tscn — base component
7. AddressChip.tscn — needed by AuthResult + Dashboard
8. WalletBadge.tscn — needed by WalletPicker
9. LoadingSpinner.tscn — needed by WalletPicker + others
10. Splash.tscn + script
11. WalletPicker.tscn + script
12. AuthResult.tscn + script
13. Dashboard.tscn + script
14. SignTransaction.tscn + script
15. SignAndSend.tscn + script
16. SignMessage.tscn + script
17. Capabilities.tscn + script
18. AuthCache.tscn + script
19. Settings.tscn + script
20. TxStatusRing.tscn (advanced component, build with SignTx screens)
21. BottomSheet.tscn (advanced, build when needed)

---

## AGENT PROMPT FOR PHASE 3
```
CONTEXT: Continuing INVOKE SDK development — Phase 3 InvokeQuest example app.
REPO: C:\PROJECTS\Invoke_Solana_App
BRANCH: develop
REFERENCE DOCS: _planning/SOLANAQUEST_ASSET_MAP.md (asset names + specs)
                _planning/GODOTMWA_REFERENCE_IMPLEMENTATION.md (MWA patterns)

DESIGN SYSTEM:
- Colors: see DesignTokens.gd (already built)
- Fonts: Space Grotesk (display), DM Sans (body), JetBrains Mono (mono)
- Glass effect: glass_card.gdshader (already built)
- All scenes in: example/invokequest/scenes/

CONSTRAINTS:
- GDScript 4.x syntax only
- All signals snake_case
- All errors via MWA.error signal
- Use DesignTokens.gd constants for all colors/sizes
- Use SceneManager.gd for all navigation
- Plugin available check before any MWA call
- One task at a time, verify + commit after each

CURRENT TASK: [state the specific task]
```

---

*Invoke SDK — InvokeQuest Scope v1.0 · Francisco (Franny) · 2026*
