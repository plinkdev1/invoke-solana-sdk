# SOLANAQUEST — COMPLETE ASSET MAP
## Recraft · AnimationPlayer · Fonts · Shaders · Everything Named
### GodotMWA Example App · Design & Build Reference

---

## OVERVIEW

This document is the **single source of truth** for every visual asset in SolanaQuest.
Every asset has: a canonical name, a source tool, exact Recraft prompt or Godot config, 
file path, dimensions, and usage context. Feed this doc to any agent building UI scenes.

---

## 1. DIRECTORY STRUCTURE

```
example/solanaquest/
├── assets/
│   ├── fonts/
│   │   ├── SpaceGrotesk-Bold.ttf
│   │   ├── SpaceGrotesk-SemiBold.ttf
│   │   ├── SpaceGrotesk-Regular.ttf
│   │   ├── DMSans-Regular.ttf
│   │   ├── DMSans-Medium.ttf
│   │   ├── DMSans-Italic.ttf
│   │   └── JetBrainsMono-Regular.ttf
│   │   └── JetBrainsMono-SemiBold.ttf
│   │
│   ├── icons/
│   │   ├── ui/
│   │   │   ├── ic_home.svg
│   │   │   ├── ic_sign.svg
│   │   │   ├── ic_cache.svg
│   │   │   ├── ic_settings.svg
│   │   │   ├── ic_back.svg
│   │   │   ├── ic_close.svg
│   │   │   ├── ic_copy.svg
│   │   │   ├── ic_check.svg
│   │   │   ├── ic_warning.svg
│   │   │   ├── ic_external_link.svg
│   │   │   ├── ic_refresh.svg
│   │   │   └── ic_trash.svg
│   │   ├── wallets/
│   │   │   ├── wallet_phantom.png      (512×512)
│   │   │   ├── wallet_backpack.png     (512×512)
│   │   │   └── wallet_solflare.png     (512×512)
│   │   └── status/
│   │       ├── ic_status_success.svg
│   │       ├── ic_status_pending.svg
│   │       ├── ic_status_error.svg
│   │       └── ic_status_cached.svg
│   │
│   ├── images/
│   │   ├── splash/
│   │   │   ├── splash_bg_aurora.png    (1080×1920)
│   │   │   └── splash_logo_mark.png    (256×256)
│   │   ├── onboarding/
│   │   │   ├── onboard_bg_1.png        (1080×1920)
│   │   │   └── onboard_illustration.png (800×600)
│   │   ├── empty_states/
│   │   │   ├── empty_transactions.png  (600×400)
│   │   │   ├── empty_wallet.png        (600×400)
│   │   │   └── empty_capabilities.png  (600×400)
│   │   └── misc/
│   │       ├── solana_logo_white.png   (256×64)
│   │       └── godot_logo_white.png    (256×64)
│   │
│   ├── textures/
│   │   ├── noise_subtle.png            (512×512, tileable)
│   │   ├── glass_gradient.png          (1×256, vertical gradient)
│   │   └── grid_dots.png               (64×64, tileable dot pattern)
│   │
│   └── themes/
│       ├── SolanaQuestTheme.tres       (Godot Theme resource)
│       └── StyleBoxes/
│           ├── StyleGlassCard.tres
│           ├── StylePrimaryBtn.tres
│           ├── StyleSecondaryBtn.tres
│           ├── StyleDangerBtn.tres
│           ├── StyleGreenBtn.tres
│           ├── StyleInputField.tres
│           └── StyleBottomNav.tres
│
├── scenes/
│   ├── components/
│   │   ├── GlassCard.tscn
│   │   ├── WalletBadge.tscn
│   │   ├── AddressChip.tscn
│   │   ├── TxStatusRing.tscn
│   │   ├── BottomSheet.tscn
│   │   ├── HashChip.tscn
│   │   ├── TagPill.tscn
│   │   ├── NetworkBadge.tscn
│   │   ├── CacheStatusCard.tscn
│   │   └── LoadingSpinner.tscn
│   └── screens/
│       ├── Splash.tscn
│       ├── WalletPicker.tscn
│       ├── AuthResult.tscn
│       ├── Dashboard.tscn
│       ├── SignTransaction.tscn
│       ├── SignAndSend.tscn
│       ├── SignMessage.tscn
│       ├── Capabilities.tscn
│       ├── AuthCache.tscn
│       ├── Settings.tscn
│       └── Deauthorize.tscn
│
└── shaders/
    ├── glass_card.gdshader
    ├── aurora_background.gdshader
    ├── glow_pulse.gdshader
    └── noise_gradient.gdshader
```

---

## 2. FONTS

### Import Instructions (Godot 4.x)
Download all fonts from Google Fonts. Import as `.ttf` into Godot.
In `Project Settings > General > Fonts` set default font to `DMSans-Regular.ttf`.

| Godot Reference Name | File | Use Case | Size Range |
|---------------------|------|----------|------------|
| `font_display_bold` | SpaceGrotesk-Bold.ttf | Screen titles, wallet name, balance | 22–40px |
| `font_display_semi` | SpaceGrotesk-SemiBold.ttf | Card labels, action buttons | 14–20px |
| `font_display_reg` | SpaceGrotesk-Regular.ttf | Sub-labels, secondary headings | 12–16px |
| `font_body_med` | DMSans-Medium.ttf | Body text, descriptions | 12–15px |
| `font_body_reg` | DMSans-Regular.ttf | Default body, placeholder text | 11–14px |
| `font_body_italic` | DMSans-Italic.ttf | Status messages, helper text | 11–13px |
| `font_mono_semi` | JetBrainsMono-SemiBold.ttf | Wallet addresses, tx hashes, amounts | 10–13px |
| `font_mono_reg` | JetBrainsMono-Regular.ttf | Raw bytes, hex values | 10–12px |

### Font Size System (GDScript Constants)
```gdscript
# In theme/DesignTokens.gd autoload
const FONT_SIZE_XL   = 36  # Balance amount, screen hero titles
const FONT_SIZE_LG   = 24  # Section titles, wallet name
const FONT_SIZE_MD   = 18  # Card titles, button labels
const FONT_SIZE_SM   = 14  # Body text, descriptions
const FONT_SIZE_XS   = 12  # Labels, badges, sub-text
const FONT_SIZE_XXS  = 10  # Addresses, hashes, metadata
```

---

## 3. COLOR TOKENS

```gdscript
# In theme/DesignTokens.gd
const COLOR_BG              = Color(0.031, 0.039, 0.055, 1.0)   # #080A0F
const COLOR_SURFACE         = Color(1, 1, 1, 0.05)              # rgba glass
const COLOR_SURFACE_2       = Color(1, 1, 1, 0.08)              # brighter glass
const COLOR_GLASS_BORDER    = Color(1, 1, 1, 0.10)              # card borders
const COLOR_PURPLE          = Color(0.600, 0.271, 1.000, 1.0)   # #9945FF
const COLOR_PURPLE_DIM      = Color(0.600, 0.271, 1.000, 0.15)  # #9945FF @ 15%
const COLOR_GREEN           = Color(0.078, 0.945, 0.596, 1.0)   # #14F195
const COLOR_GREEN_DIM       = Color(0.078, 0.945, 0.596, 0.12)  # #14F195 @ 12%
const COLOR_YELLOW          = Color(1.000, 0.725, 0.220, 1.0)   # #FFB938
const COLOR_RED             = Color(1.000, 0.310, 0.310, 1.0)   # #FF4F4F
const COLOR_WHITE           = Color(1, 1, 1, 1.0)
const COLOR_WHITE_60        = Color(1, 1, 1, 0.6)
const COLOR_WHITE_30        = Color(1, 1, 1, 0.3)
const COLOR_WHITE_10        = Color(1, 1, 1, 0.1)
```

---

## 4. RECRAFT ASSETS — COMPLETE GENERATION LIST

### HOW TO USE THESE PROMPTS
1. Go to recraft.ai
2. For SVG icons: select "Vector Icon" style
3. For PNG backgrounds/illustrations: select "Digital Illustration" or "Realistic"
4. Download at specified resolution
5. Place in exact path listed below

---

### 4A. UI ICONS (SVG — Vector)

**Batch 1: Navigation & Core Actions**
Generate all as a set for visual consistency. Style: thin line, monochrome white, 24×24 viewBox.

| Asset Name | File Path | Recraft Prompt |
|-----------|-----------|----------------|
| `ic_home` | `assets/icons/ui/ic_home.svg` | "Simple home house icon, thin line style, single color white, 24x24, minimal, clean paths, no fill" |
| `ic_sign` | `assets/icons/ui/ic_sign.svg` | "Pen signature writing icon, thin line style, single color white, 24x24, minimal" |
| `ic_cache` | `assets/icons/ui/ic_cache.svg` | "Database cache storage icon, cylinder shape, thin line, single color white, 24x24" |
| `ic_settings` | `assets/icons/ui/ic_settings.svg` | "Settings gear cog icon, thin line, single color white, 24x24, minimal clean" |
| `ic_back` | `assets/icons/ui/ic_back.svg` | "Left arrow back navigation, thin line, white, 24x24, simple chevron left" |
| `ic_close` | `assets/icons/ui/ic_close.svg` | "X close dismiss icon, thin line, white, 24x24, two diagonal lines" |
| `ic_copy` | `assets/icons/ui/ic_copy.svg` | "Copy clipboard duplicate icon, thin line, white, 24x24, two overlapping rectangles" |
| `ic_check` | `assets/icons/ui/ic_check.svg` | "Checkmark tick icon, thin line, white, 24x24, simple clean check" |
| `ic_warning` | `assets/icons/ui/ic_warning.svg` | "Warning triangle exclamation icon, thin line, white, 24x24" |
| `ic_external_link` | `assets/icons/ui/ic_external_link.svg` | "External link open in new tab icon, thin line, white, 24x24, arrow leaving box" |
| `ic_refresh` | `assets/icons/ui/ic_refresh.svg` | "Refresh reload circular arrow icon, thin line, white, 24x24" |
| `ic_trash` | `assets/icons/ui/ic_trash.svg` | "Trash delete bin icon, thin line, white, 24x24" |

**Batch 2: Status Icons**
Style: filled circle with symbol inside, colored — these ARE colored unlike batch 1.

| Asset Name | File Path | Recraft Prompt |
|-----------|-----------|----------------|
| `ic_status_success` | `assets/icons/status/ic_status_success.svg` | "Success checkmark in filled circle, green #14F195 color, 24x24, clean vector icon" |
| `ic_status_pending` | `assets/icons/status/ic_status_pending.svg` | "Pending clock hourglass in filled circle, yellow #FFB938 color, 24x24, clean vector icon" |
| `ic_status_error` | `assets/icons/status/ic_status_error.svg` | "Error X in filled circle, red #FF4F4F color, 24x24, clean vector icon" |
| `ic_status_cached` | `assets/icons/status/ic_status_cached.svg` | "Cache shield lock in filled circle, purple #9945FF color, 24x24, clean vector icon" |

---

### 4B. WALLET BRAND ICONS (PNG 512×512)

These are brand assets — use official wallet logos from each project's press kit rather than generating in Recraft. Links:
- **Phantom**: https://phantom.app/media-kit — download `phantom-icon.png`
- **Backpack**: https://github.com/coral-xyz/backpack — get from repo assets
- **Solflare**: https://solflare.com/press-kit — download brand assets

Place at:
```
assets/icons/wallets/wallet_phantom.png    (resize to 512×512)
assets/icons/wallets/wallet_backpack.png   (resize to 512×512)
assets/icons/wallets/wallet_solflare.png   (resize to 512×512)
```

In Godot: import each as `Texture2D`, compression: `Lossless`.

---

### 4C. SPLASH & BACKGROUND IMAGES (PNG)

| Asset Name | File Path | Size | Recraft Prompt |
|-----------|-----------|------|----------------|
| `splash_bg_aurora` | `assets/images/splash/splash_bg_aurora.png` | 1080×1920 | "Abstract dark space aurora background, deep black base #080A0F, flowing aurora borealis streaks in purple #9945FF and teal #14F195, very subtle, minimal light, high quality digital art, no text, no objects, pure atmospheric gradient" |
| `splash_logo_mark` | `assets/images/splash/splash_logo_mark.png` | 256×256 | "Stylized lightning bolt S logo mark, purple to teal gradient #9945FF to #14F195, glowing neon effect, dark transparent background, clean geometric shape, crypto/blockchain aesthetic, high quality icon" |
| `onboard_illustration` | `assets/images/onboarding/onboard_illustration.png` | 800×600 | "Abstract 3D illustration of a smartphone with floating holographic Solana coins around it, purple and teal color scheme, dark background, premium crypto app aesthetic, glowing elements, depth of field" |

---

### 4D. EMPTY STATE ILLUSTRATIONS (PNG)

| Asset Name | File Path | Size | Recraft Prompt |
|-----------|-----------|------|----------------|
| `empty_transactions` | `assets/images/empty_states/empty_transactions.png` | 600×400 | "Minimal illustration of an empty inbox tray with a small ghost/specter emoji style above it, purple tones, dark background, friendly and simple, crypto app style empty state" |
| `empty_wallet` | `assets/images/empty_states/empty_wallet.png` | 600×400 | "Minimal illustration of an empty wallet with Solana symbol, muted purple and grey tones, dark background, app empty state illustration, clean and simple" |
| `empty_capabilities` | `assets/images/empty_states/empty_capabilities.png` | 600×400 | "Minimal illustration of a magnifying glass with question mark, muted purple tones, dark background, app empty state, simple vector style" |

---

### 4E. TEXTURES (PNG, Tileable)

| Asset Name | File Path | Size | Recraft Prompt |
|-----------|-----------|------|----------------|
| `noise_subtle` | `assets/textures/noise_subtle.png` | 512×512 | "Seamlessly tileable subtle film grain noise texture, very fine grain, almost invisible, dark neutral background, for use as overlay texture in UI design" |
| `grid_dots` | `assets/textures/grid_dots.png` | 64×64 | "Seamlessly tileable dot grid pattern, tiny white dots on transparent/black background, dots spaced 8px apart, very subtle, for use as UI texture overlay" |

---

## 5. GODOT SHADERS

These are written in Godot Shader Language (`.gdshader`). No external tools needed.

### 5A. `glass_card.gdshader`
Used by: `GlassCard.tscn`, `WalletBadge.tscn`, `CacheStatusCard.tscn`, `BottomSheet.tscn`

```glsl
// glass_card.gdshader
shader_type canvas_item;

uniform float blur_strength: hint_range(0.0, 10.0) = 3.0;
uniform vec4 tint_color: source_color = vec4(1.0, 1.0, 1.0, 0.06);
uniform float border_alpha: hint_range(0.0, 1.0) = 0.10;
uniform float border_width: hint_range(0.0, 0.05) = 0.008;
uniform vec4 border_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float corner_radius: hint_range(0.0, 0.5) = 0.08;

void fragment() {
    vec4 screen_sample = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_strength);
    COLOR = mix(screen_sample, tint_color, tint_color.a);
    COLOR.a = 1.0;
    
    // Border glow
    float edge_x = step(1.0 - border_width, UV.x) + step(UV.x, border_width);
    float edge_y = step(1.0 - border_width, UV.y) + step(UV.y, border_width);
    float border = clamp(edge_x + edge_y, 0.0, 1.0);
    COLOR.rgb = mix(COLOR.rgb, border_color.rgb, border * border_alpha);
}
```

### 5B. `aurora_background.gdshader`
Used by: `Splash.tscn` background layer

```glsl
// aurora_background.gdshader
shader_type canvas_item;

uniform float time_scale: hint_range(0.01, 2.0) = 0.3;
uniform vec4 color_a: source_color = vec4(0.600, 0.271, 1.000, 0.15); // purple
uniform vec4 color_b: source_color = vec4(0.078, 0.945, 0.596, 0.08); // teal
uniform vec4 bg_color: source_color = vec4(0.031, 0.039, 0.055, 1.0); // #080A0F

void fragment() {
    vec2 uv = UV;
    float t = TIME * time_scale;
    
    float wave1 = sin(uv.x * 3.0 + t) * 0.5 + 0.5;
    float wave2 = sin(uv.x * 2.0 - t * 0.7 + 1.5) * 0.5 + 0.5;
    
    float aurora1 = smoothstep(0.0, 0.6, wave1 * (1.0 - uv.y));
    float aurora2 = smoothstep(0.0, 0.5, wave2 * uv.y * 0.4);
    
    vec4 col = bg_color;
    col = mix(col, color_a, aurora1 * 0.6);
    col = mix(col, color_b, aurora2 * 0.4);
    COLOR = col;
}
```

### 5C. `glow_pulse.gdshader`
Used by: `TxStatusRing.tscn`, cache active indicator, connected wallet badge

```glsl
// glow_pulse.gdshader
shader_type canvas_item;

uniform vec4 glow_color: source_color = vec4(0.078, 0.945, 0.596, 1.0); // teal
uniform float pulse_speed: hint_range(0.1, 5.0) = 1.5;
uniform float glow_radius: hint_range(0.0, 1.0) = 0.3;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    float dist = distance(UV, vec2(0.5));
    float glow = smoothstep(glow_radius, 0.0, dist) * pulse;
    COLOR = mix(tex, glow_color, glow * glow_color.a * 0.6);
    COLOR.a = tex.a;
}
```

---

## 6. ANIMATIONPLAYER DEFINITIONS

Every screen transition and component animation defined here.
In Godot 4.x, create these in each scene's `AnimationPlayer` node.

---

### 6A. SCREEN TRANSITIONS
Applied to: `SceneManager.gd` via `AnimationPlayer` on a `CanvasLayer` overlay

| Animation Name | Duration | Curve | Description |
|---------------|----------|-------|-------------|
| `screen_push_out` | 0.25s | ease_in | Current screen slides left off screen (translate X: 0 → -300) + fade to 0 |
| `screen_push_in` | 0.25s | ease_out | New screen slides in from right (translate X: +300 → 0) + fade from 0 to 1 |
| `screen_pop_out` | 0.25s | ease_in | Current screen slides right off screen (translate X: 0 → +300) + fade to 0 |
| `screen_pop_in` | 0.25s | ease_out | Previous screen slides in from left (translate X: -300 → 0) + fade from 0 to 1 |
| `screen_fade_in` | 0.3s | ease_out | Replace transition — fade in from black |
| `screen_fade_out` | 0.2s | ease_in | Replace transition — fade out to black |

**GDScript for SceneManager transitions:**
```gdscript
func push_scene(path: String) -> void:
    await _play_and_wait("screen_push_out")
    get_tree().change_scene_to_file(path)
    await get_tree().process_frame
    _play("screen_push_in")
```

---

### 6B. SPLASH SCREEN ANIMATIONS

| Animation Name | Node | Property | From | To | Duration | Delay |
|---------------|------|----------|------|----|----------|-------|
| `splash_logo_enter` | SplashLogo | position:y | +40 | 0 | 0.6s | 0.2s |
| `splash_logo_enter` | SplashLogo | modulate:a | 0 | 1 | 0.5s | 0.2s |
| `splash_icon_scale` | SplashIcon | scale | (0.7, 0.7) | (1.0, 1.0) | 0.5s | 0.1s — ease_out_back |
| `splash_sub_enter` | SplashSub | modulate:a | 0 | 1 | 0.4s | 0.6s |
| `splash_dots_enter` | SplashDots | modulate:a | 0 | 1 | 0.3s | 0.8s |
| `particle_float_1` | Particle1 | position:y | 0 | -14 | 2.5s | 0s — ease_in_out, loop |
| `particle_float_2` | Particle2 | position:y | 0 | -14 | 3.1s | 0.6s — ease_in_out, loop |
| `particle_float_3` | Particle3 | position:y | 0 | -10 | 2.8s | 1.2s — ease_in_out, loop |

---

### 6C. WALLET PICKER ANIMATIONS

| Animation Name | Node | Property | From | To | Duration | Notes |
|---------------|------|----------|------|----|----------|-------|
| `cards_stagger_in` | WalletCard1 | position:y | +20 | 0 | 0.3s | delay 0.0s |
| `cards_stagger_in` | WalletCard1 | modulate:a | 0 | 1 | 0.25s | delay 0.0s |
| `cards_stagger_in` | WalletCard2 | position:y | +20 | 0 | 0.3s | delay 0.08s |
| `cards_stagger_in` | WalletCard2 | modulate:a | 0 | 1 | 0.25s | delay 0.08s |
| `cards_stagger_in` | WalletCard3 | position:y | +20 | 0 | 0.3s | delay 0.16s |
| `cards_stagger_in` | WalletCard3 | modulate:a | 0 | 1 | 0.25s | delay 0.16s |
| `card_press` | WalletCard (any) | scale | (1,1) | (0.97, 0.97) | 0.1s | on button_down |
| `card_release` | WalletCard (any) | scale | (0.97,0.97) | (1,1) | 0.15s | on button_up — ease_out_back |
| `card_selected` | SelectedCard | modulate | white | purple tint | 0.2s | border flashes purple |
| `loading_spinner` | LoadingOverlay | rotation | 0 | 360° | 1.0s | loop, linear |

---

### 6D. DASHBOARD ANIMATIONS

| Animation Name | Node | Property | From | To | Duration | Notes |
|---------------|------|----------|------|----|----------|-------|
| `balance_count_up` | BalanceLabel | — | — | — | 0.8s | Tween in GDScript: 0 → actual_balance, ease_out |
| `balance_card_enter` | BalanceCard | scale | (0.95, 0.95) | (1.0, 1.0) | 0.35s | ease_out_back |
| `balance_card_enter` | BalanceCard | modulate:a | 0 | 1 | 0.25s | — |
| `actions_stagger_in` | ActionBtn[0..3] | position:y | +16 | 0 | 0.25s | 0.05s stagger each |
| `actions_stagger_in` | ActionBtn[0..3] | modulate:a | 0 | 1 | 0.2s | 0.05s stagger each |
| `connected_pulse` | ConnectedDot | scale | (1,1) | (1.3, 1.3) | 0.8s | loop, ease_in_out, ping-pong |
| `connected_pulse` | ConnectedDot | modulate:a | 1.0 | 0.5 | 0.8s | loop, ping-pong |
| `tx_item_enter` | TxItem[n] | position:x | +20 | 0 | 0.2s | stagger 0.04s |
| `tx_item_enter` | TxItem[n] | modulate:a | 0 | 1 | 0.18s | stagger 0.04s |

---

### 6E. SIGN TRANSACTION ANIMATIONS

| Animation Name | Node | Property | Notes |
|---------------|------|----------|-------|
| `step_progress` | StepIndicator[n] | modulate color | Grey → Purple on step complete, 0.2s |
| `hash_reveal` | HashChip | — | Typewriter effect in GDScript: reveal chars one by one at 8ms each |
| `request_btn_press` | RequestBtn | scale | (1,1) → (0.97,0.97) → (1,1), 0.15s |
| `wallet_opening` | LoadingOverlay | modulate:a | Fade in 0.2s, show spinner |
| `success_flash` | SuccessIcon | scale | (0,0) → (1.2,1.2) → (1.0,1.0), 0.4s, ease_out_back |

---

### 6F. TX STATUS RING (Component Animation)
Scene: `TxStatusRing.tscn` — uses `Arc2D` or custom drawing with `_draw()`

| Animation Name | Property | Notes |
|---------------|----------|-------|
| `ring_pending` | Arc sweep angle | 0° → 360°, 1.5s, loop, ease_linear |
| `ring_confirming` | Arc sweep + color | Purple, fills to percentage, updates on each block |
| `ring_confirmed` | Full ring + color shift | Purple → Green, 0.3s, then success_flash |
| `ring_failed` | Color shift | Purple → Red, 0.2s, shake effect |

**Shake effect (GDScript):**
```gdscript
func play_shake(node: Node2D) -> void:
    var tween = create_tween()
    for i in 4:
        tween.tween_property(node, "position:x", randf_range(-6, 6), 0.05)
    tween.tween_property(node, "position:x", 0.0, 0.05)
```

---

### 6G. AUTH CACHE SCREEN ANIMATIONS

| Animation Name | Node | Notes |
|---------------|------|-------|
| `cache_dot_pulse` | CacheIndicatorDot | scale (1,1)→(1.4,1.4)→(1,1), 2s loop, green when active |
| `flow_steps_reveal` | FlowStep[1..3] | Stagger reveal top→bottom, 0.15s each, 0.1s delay between |
| `cache_clear_anim` | CacheStatusCard | shake + fade modulate to 0.3 + back, 0.4s |
| `reconnect_spin` | ReconnectIcon | rotation 0→360, 1s, once on button press |

---

### 6H. BOTTOM SHEET COMPONENT

| Animation Name | Node | Property | From | To | Duration |
|---------------|------|----------|------|----|----------|
| `sheet_open` | BottomSheetPanel | position:y | +400 | 0 | 0.3s | ease_out_quart |
| `sheet_open` | BackdropOverlay | modulate:a | 0 | 0.7 | 0.25s | |
| `sheet_close` | BottomSheetPanel | position:y | 0 | +400 | 0.22s | ease_in_quart |
| `sheet_close` | BackdropOverlay | modulate:a | 0.7 | 0 | 0.2s | |

---

### 6I. LOADING SPINNER COMPONENT
Scene: `LoadingSpinner.tscn` — three dots or rotating arc

| Animation Name | Notes |
|---------------|-------|
| `dots_pulse` | Three dots, each scale (0.6)→(1.0)→(0.6), 0.6s loop, staggered 0.2s |
| `arc_spin` | Single arc (270° sweep), rotates 360° continuously at 1.2s per rev |

---

## 7. COMPONENT SCENE SPECS

Quick reference for each reusable component scene.

### `GlassCard.tscn`
```
PanelContainer (root)
  └── shader: glass_card.gdshader
  └── custom_minimum_size: (0, 0) — resizes to content
  └── StyleBox: StyleGlassCard.tres
      (border_radius: 16, border_width: 1, border_color: white@10%)
```

### `WalletBadge.tscn`
```
HBoxContainer
  ├── TextureRect (wallet_icon) — size: 44×44, expand_mode: FIT
  ├── VBoxContainer
  │   ├── Label (wallet_name) — font: font_display_semi, size: 15
  │   └── Label (wallet_sub) — font: font_body_reg, size: 10, color: white@60%
  └── PanelContainer (badge) — conditional: installed/not installed
      └── Label (badge_text) — font: font_display_semi, size: 10
```

### `AddressChip.tscn`
```
HBoxContainer
  ├── Label (address_text) — font: font_mono_reg, size: 11
  │   └── shows first 4...last 4 chars, full address in tooltip
  └── Button (copy_btn) — icon: ic_copy.svg, size: 16×16
      └── on_pressed: OS.clipboard = full_address + play check animation
```

### `TxStatusRing.tscn`
```
Control (root) — size: 48×48
  ├── Node2D (ring_node) — custom _draw() method draws arc
  └── AnimationPlayer (anim) — plays ring_pending / ring_confirmed etc.
```

---

## 8. SCENE BACKGROUND LAYERS

Each screen follows this layer stack (bottom to top):

```
1. ColorRect (full screen) — color: #080A0F
2. ShaderMaterial (aurora_background.gdshader) — opacity varies per screen
3. TextureRect (noise_subtle.png) — modulate: white@4%, tile, covers full screen
4. [Screen content nodes]
5. CanvasLayer (UI overlays — BottomSheet, LoadingOverlay)
```

Only `Splash.tscn` uses the animated aurora shader at full intensity.
Other screens use a very dim static version (time_scale: 0.0 to freeze it).

---

## 9. ASSET NAMING CONVENTIONS

| Convention | Rule | Example |
|------------|------|---------|
| Icons (SVG) | `ic_[noun]` | `ic_home`, `ic_copy`, `ic_wallet` |
| Status icons | `ic_status_[state]` | `ic_status_success`, `ic_status_pending` |
| Wallet icons | `wallet_[name]` | `wallet_phantom`, `wallet_backpack` |
| Background images | `[screen]_bg_[variant]` | `splash_bg_aurora`, `dashboard_bg_main` |
| Illustrations | `[context]_illustration` | `onboard_illustration`, `empty_transactions` |
| Textures | `[type]_[quality]` | `noise_subtle`, `grid_dots` |
| Shaders | `[effect]_[type]` | `glass_card`, `aurora_background`, `glow_pulse` |
| Animations | `[subject]_[action]` | `cards_stagger_in`, `balance_count_up`, `sheet_open` |
| Components | `PascalCase.tscn` | `GlassCard.tscn`, `WalletBadge.tscn` |
| Screens | `PascalCase.tscn` | `Dashboard.tscn`, `WalletPicker.tscn` |
| Scripts | `snake_case.gd` | `mobile_wallet_adapter.gd`, `scene_manager.gd` |
| Themes | `PascalCaseTheme.tres` | `SolanaQuestTheme.tres` |
| StyleBoxes | `Style[Use].tres` | `StyleGlassCard.tres`, `StylePrimaryBtn.tres` |

---

## 10. AGENT HANDOFF NOTES

When feeding this doc to Claude Code, prefix the session with:

```
ASSET CONTEXT: All assets in this project follow SOLANAQUEST_ASSET_MAP.md.
- Use ONLY asset names from this document
- All shader code is in /shaders/*.gdshader — reference by filename
- All animations are defined in Section 6 — reference by animation name exactly
- Font references use the Godot Reference Names from Section 2
- Color references use the GDScript constant names from Section 3
- Do NOT create new assets without noting them here first
```

---

*SolanaQuest Asset Map v1.0 · GodotMWA Grant · Francisco (Franny) · Portugal*
