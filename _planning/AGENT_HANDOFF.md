# INVOKE SDK — Agent Handoff Document
**Date:** 2026-03-22  
**Session duration:** ~14 hours  
**Branch:** `develop`  
**Repo:** https://github.com/plinkdev1/invoke-solana-sdk  
**Local path:** `C:\PROJECTS\Invoke_Solana_App`

---

## Project Overview

INVOKE SDK is a Solana Mobile Wallet Adapter (MWA) plugin for Godot 4 on Android. It lets Godot games/dApps connect to Solana wallets (Phantom, Solflare, Jupiter, Backpack) via the MWA 2.0.3 protocol.

**Stack:**
- Godot 4.2.2 + Kotlin Android Plugin (AAR) + GDScript
- MWA clientlib-ktx 2.0.3
- Direct Gradle build (NOT Godot editor export)
- Package: `dev.invoke.invokequest`
- Keystore: `example/invokequest/invokequest.keystore` (alias: `invokequest`, pass: `invokequest123`)

---

## What Was Accomplished This Session

### ✅ Fixed and Working
1. `<meta-data>` tag moved inside `<application>` in AndroidManifest.xml
2. `<queries>` block added for Android 11+ wallet detection
3. Gson + all MWA runtime deps added to Godot app's `build.gradle`
4. `ActivityResultSender` created as class property (not lazily per-call)
5. `Integer::class.javaObjectType` used for `mwa_error` signal (fixes Int boxing)
6. MWABridge.kt `transact()` lambda now calls actual MWA 2.0.3 methods
7. `iconUri` fixed to relative path (`favicon.ico`) not absolute URL
8. **Auth flow working end-to-end with Solflare and Jupiter** ✅
9. **Cache / reauthorize working** (silent reconnect on app reopen) ✅
10. **Disconnect working** ✅
11. Jupiter wallet added to WalletPicker (card visible, GDScript updated)
12. `godot-mwa-dapp-dev.skill` created and packaged for Claude skills system

### 🔴 Known Issues / Still Broken
1. **UI sizing** — content fills only top ~35% of screen, large black bars top/bottom. Viewport is 1080x2340, stretch mode canvas_items+expand is set, fullscreen=true mode=4 is set but Samsung still shows bars. Needs deeper investigation — possibly needs Godot `get_viewport().set_embedding_subwindows()` or Android theme fix.
2. **isSessionActive stuck** — after a failed sign transaction, the `isSessionActive` AtomicBoolean flag doesn't reset properly, causing subsequent wallet calls to hang with "session already active"
3. **Backpack not connecting** — session connects then immediately disconnects. Believed to be a Backpack MWA 2.0 compatibility issue (not an SDK bug). Document as known limitation.
4. **Jupiter icon not showing** — wallet_jupiter.png was a JPEG renamed to .png, converted to proper PNG. Scene was saved in Godot editor but needs verification on device.
5. **Phantom rejects unverified dApp** — `invoke.dev` not registered with Phantom. Works once domain is verified. Use Solflare/Jupiter for testing.
6. **Sign Transaction / Sign & Send / Sign Message** — return error 9999 because dummy transaction bytes are invalid. The MWA flow reaches the wallet correctly but wallet rejects invalid tx. Need real Solana transaction construction.

---

## Build Pipeline (CRITICAL — memorize this)

**Never use Godot editor export. Always direct Gradle.**

### Full rebuild + sign + install (one command from `android\build\`):
```powershell
cd "C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build"; .\gradlew.bat clean assembleRelease; python patch_apk_icons.py; $bt = Get-ChildItem "C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk\build-tools\" | Sort-Object Name -Descending | Select-Object -First 1; & "$($bt.FullName)\apksigner.bat" sign --ks "C:\PROJECTS\Invoke_Solana_App\example\invokequest\invokequest.keystore" --ks-key-alias invokequest --ks-pass pass:invokequest123 --key-pass pass:invokequest123 --out build\outputs\apk\release\android_release_signed.apk build\outputs\apk\release\android_release_patched.apk; adb uninstall dev.invoke.invokequest; adb install build\outputs\apk\release\android_release_signed.apk
```

### After changing Kotlin plugin source (MWABridge.kt, MWAPlugin.kt etc):
```powershell
# 1. Build plugin AAR
cd "C:\PROJECTS\Invoke_Solana_App\android"; .\gradlew.bat clean assembleRelease

# 2. Copy AAR to both locations
Copy-Item "plugin\build\outputs\aar\plugin-release.aar" "C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build\libs\release\InvokeMWA.aar" -Force
Copy-Item "plugin\build\outputs\aar\plugin-release.aar" "C:\PROJECTS\Invoke_Solana_App\example\invokequest\addons\mobile_wallet_adapter\android\InvokeMWA.aar" -Force

# 3. Full APK rebuild (command above)
```

### After changing project.godot:
```powershell
copy "C:\PROJECTS\Invoke_Solana_App\example\invokequest\project.godot" "C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build\assets\project.godot"
# Then full APK rebuild
```

### After changing .tscn scene files:
Must open Godot editor (`C:\Tools\Godot\Godot_v4.2.2-stable_win64.exe`), open the scene, Ctrl+S to save, close editor. This recompiles the binary `.scn`. Then full APK rebuild.

### Logcat (filter to plugin only):
```powershell
adb logcat -c
adb logcat --pid=$(adb shell pidof dev.invoke.invokequest) | Select-String -Pattern "InvokeMWA|GodotPlugin|AndroidRuntime"
```

---

## Key File Locations

```
C:\PROJECTS\Invoke_Solana_App\
├── android\plugin\
│   ├── build.gradle.kts                    ← plugin deps (compileOnly godot, implementation MWA)
│   └── src\main\kotlin\com\invoke\mwa\
│       ├── MWABridge.kt                    ← ALL wallet logic (authorize, sign, cache)
│       ├── MWAPlugin.kt                    ← Godot plugin registration + signals
│       ├── AuthCacheImpl.kt                ← token cache
│       └── MWAError.kt                     ← error codes + mapErrorCode()
├── example\invokequest\
│   ├── project.godot                       ← viewport, stretch, fullscreen settings
│   ├── invokequest.keystore                ← signing key (gitignored)
│   ├── scenes\screens\
│   │   ├── WalletPicker.tscn + .gd        ← wallet selection UI
│   │   ├── Dashboard.tscn + .gd           ← post-auth screen
│   │   ├── SignTransaction.tscn + .gd
│   │   ├── SignAndSend.tscn + .gd
│   │   ├── SignMessage.tscn + .gd
│   │   ├── Capabilities.tscn + .gd
│   │   └── AuthResult.tscn + .gd
│   ├── addons\mobile_wallet_adapter\
│   │   ├── MobileWalletAdapter.gd          ← GDScript wrapper
│   │   └── android\InvokeMWA.aar           ← plugin AAR (copy 1)
│   └── android\build\
│       ├── build.gradle                    ← Godot app Gradle (runtime deps added here)
│       ├── AndroidManifest.xml             ← meta-data + queries blocks
│       └── libs\release\InvokeMWA.aar      ← plugin AAR (copy 2)
└── docs\                                   ← Docusaurus docs site
```

---

## Critical Technical Rules

### AndroidManifest.xml
- `<meta-data>` MUST be inside `<application>` tag
- `<queries>` block required for wallet detection

### MWABridge.kt Rules
- `ActivityResultSender` must be class property, created in constructor
- `transact()` lambda must call the actual MWA method (authorize/reauthorize/etc)
- `iconUri` must be relative: `android.net.Uri.parse("favicon.ico")` NOT `https://...`
- Signal registration: use `Integer::class.javaObjectType` NOT `Int::class.java`
- ALL runtime deps must be in Godot app's `build.gradle` (AAR doesn't bundle them)

### PowerShell Rules
- Use `;` not `&&` as statement separator
- Never write `.gd` files via PowerShell here-strings (tabs get stripped)
- Write Python scripts to files, don't use `-c` with complex strings

---

## Wallet Status

| Wallet | Package | Status |
|--------|---------|--------|
| Solflare | `com.solflare.mobile` | ✅ Full auth flow working |
| Jupiter | `ag.jup.jupiter.android` | ✅ Auth working, icon pending |
| Phantom | `app.phantom` | ⚠️ Rejects unverified dApp identity |
| Backpack | `com.backpack.wallet` | ❌ MWA 2.0 incompatible — known limitation |

---

## project.godot Current Settings
```ini
[display]
window/stretch/aspect="expand"
window/size/viewport_width=1080
window/size/viewport_height=2340
window/size/resizable=false
window/stretch/mode="canvas_items"
window/handheld/orientation=1
window/size/fullscreen=true
window/size/mode=4
```

---

## Remaining Tasks (Priority Order)

### Phase 4 — InvokeQuest App (CURRENT)
- [ ] Fix UI sizing / black bars on Samsung (top priority)
- [ ] Fix `isSessionActive` stuck after failed sign
- [ ] Verify Jupiter icon shows correctly on device
- [ ] Build real Solana devnet transaction for Sign Transaction demo
- [ ] Test full flow: auth → sign tx → sign & send → sign message → disconnect
- [ ] Record demo video for grant application
- [ ] Generate 3x feature images for docs (512x512, use Recraft): `feature-plugin.png`, `feature-cache.png`, `feature-api.png` → `docs/static/img/`
- [ ] Update `docs/src/components/HomepageFeatures/index.tsx`
- [ ] Professional README treatment
- [ ] Airtable grant application submission

### Website (Separate Project)
- React/HTML demo page at `/demo` route
- Phone mockup simulator showing full MWA flow animated
- Step-by-step: Splash → WalletPicker → Auth → Connected → Sign → Cache
- Toggles: "With cache" vs "Without cache"
- NOT an embedded Godot web export (MWA doesn't work in browser)
- Docusaurus docs already set up in `docs/`

### MAGMA-APP (Separate Project — `C:\PROJECTS\MAGMA-APP`)
- Phase H remaining: H12 Quick Actions, H13 App.tsx V2, H14 Onboarding
- This is a completely separate React Native Solana app

---

## Environment
- **Godot:** `C:\Tools\Godot\Godot_v4.2.2-stable_win64.exe`
- **Android SDK:** `C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk`
- **JDK 17**, **Python 3.13**, **Node.js v22**, **ADB** in PATH
- **Phone:** Samsung Galaxy (1080x2340, 480 DPI, Android 14)
- **OS:** Windows

---

## Files to Share with Next Agent
1. `_planning/AGENT_HANDOFF.md` (this file, update and place here)
2. `android/plugin/src/main/kotlin/com/invoke/mwa/MWABridge.kt`
3. `android/plugin/src/main/kotlin/com/invoke/mwa/MWAPlugin.kt`
4. `example/invokequest/android/build/AndroidManifest.xml`
5. `example/invokequest/scenes/screens/WalletPicker.gd`
6. `example/invokequest/project.godot`

---

## Skill Available
A custom Claude skill `godot-mwa-dapp-dev.skill` was created this session covering all patterns, bugs, and fixes for Godot + MWA development. Install it via Claude Settings → Skills before starting next session.
