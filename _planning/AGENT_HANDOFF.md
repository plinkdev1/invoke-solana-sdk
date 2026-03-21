# INVOKE SDK — Agent Handoff v4.0
**Date:** 2026-03-21  
**Phase:** 4 — Android APK Build & MWA Wiring  
**Status:** In Progress — Build pipeline working, MWA not yet firing on device

---

## PROJECT OVERVIEW

**Repo:** https://github.com/plinkdev1/invoke-solana-sdk  
**Local:** C:\PROJECTS\Invoke_Solana_App  
**Current branch:** develop  
**Stack:** Godot 4.2.2 + Kotlin Android Plugin + GDScript

INVOKE is a Solana Mobile Wallet Adapter (MWA) SDK for Godot. It lets Godot games connect to Phantom, Backpack, and Solflare wallets on Android via the MWA protocol. The example app is called **InvokeQuest** — a 10-screen demo showcasing all SDK features.

---

## WHAT WAS COMPLETED THIS SESSION

### Phase 3 (done previously)
All 10 InvokeQuest screens built and verified on desktop:
- Splash, WalletPicker, AuthResult, Dashboard, SignTransaction, SignAndSend, SignMessage, Capabilities, AuthCache, Settings

### Phase 4 — This Session

**Completed:**
- Android export templates installed in Godot 4.2.2
- Android Gradle build working (`assembleRelease` via `gradlew.bat`)
- APK installs on device via ADB
- App icon (our logo) baked into APK via Python PIL patching
- APK signed with `invokequest.keystore`
- `MobileWalletAdapter.gd` fixed — renamed `is_connected()` → `is_wallet_connected()` and `disconnect()` → `disconnect_wallet()` to avoid Godot 4 Node method conflicts
- Plugin AAR (`InvokeMWA.aar`) copied to `android/build/libs/release/`
- `InvokeMWA.gdap` created at `addons/mobile_wallet_adapter/android/`
- `<meta-data>` tag added to AndroidManifest.xml for plugin registration
- `minSdk` bumped to 28 in config.gradle
- `export_package_name=dev.invoke.invokequest` set in gradle.properties
- `permissions/internet=true` set in export_presets.cfg
- `.gitignore` updated to exclude build outputs and keystores

**NOT yet working:**
- MWA wallet picker does NOT fire when tapping Phantom/Backpack/Solflare
- Viewport scaling — content renders too small on phone (not filling screen)
- Disconnect button — works on Android only when plugin is loaded (expected)
- Network dropdown in Settings — empty (plugin not loading = no singleton)

---

## ROOT CAUSE OF REMAINING ISSUES

**Everything broken on Android comes down to one thing: the Kotlin plugin (InvokeMWA.aar) is not being loaded by Godot at runtime.**

Godot 4's plugin system requires the plugin to be registered via:
1. A `.gdap` file in the project ✅ (done)
2. The AAR in `libs/release/` ✅ (done)  
3. The `<meta-data>` tag in AndroidManifest ✅ (done)
4. **The plugin class name in the meta-data must exactly match what the Kotlin class registers as**

The meta-data currently says:
```xml
<meta-data android:name="org.godotengine.plugin.v2.InvokeMWA" android:value="com.invoke.mwa.MWAPlugin" />
```

**This needs to be verified against the actual Kotlin plugin class.** Check:
- `C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWAPlugin.kt`
- Confirm the class name and the exact string passed to `GodotPlugin` constructor

---

## BUILD PIPELINE (CURRENT WORKING METHOD)

Godot's built-in export is broken (crashes or hangs). Use direct Gradle:

```powershell
# 1. Build
cd "C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build"
.\gradlew.bat clean assembleRelease

# 2. Patch icons (Python script at android/build/patch_apk_icons.py)
python patch_apk_icons.py

# 3. Sign
$apksigner = Get-ChildItem "C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk\build-tools\" | Sort-Object Name -Descending | Select-Object -First 1
$signerPath = "$($apksigner.FullName)\apksigner.bat"
$patched = "build\outputs\apk\release\android_release_patched.apk"
$signed  = "build\outputs\apk\release\android_release_signed.apk"
& $signerPath sign --ks "C:\PROJECTS\Invoke_Solana_App\example\invokequest\invokequest.keystore" --ks-key-alias invokequest --ks-pass pass:invokequest123 --key-pass pass:invokequest123 --out $signed $patched

# 4. Install
adb uninstall dev.invoke.invokequest   # may fail if not installed, that's ok
adb install $signed
```

**Why Godot export crashes:** Godot 4.2.2 on Windows has a known issue where the `copyAndRenameDebugApk` Gradle task fails with an MD5 hash error when the export output path is inside the project directory. Headless export hangs because Godot calls Gradle while Gradle is already running. Solution: either fix the Godot export pipeline properly (investigate) or continue with the direct Gradle approach.

---

## VIEWPORT SCALING FIX NEEDED

The app content is too small on the phone. The fix was applied to `project.godot` but wasn't in the build that was tested. Verify this is in `project.godot`:

```ini
[display]
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

Or try `mode="viewport"`. This needs to be in the APK that gets installed.

---

## KEY FILE LOCATIONS

```
C:\PROJECTS\Invoke_Solana_App\
├── android/plugin/                          ← Kotlin MWA plugin source
│   └── src/main/kotlin/com/invoke/mwa/
│       └── MWAPlugin.kt                     ← VERIFY class name here
├── example/invokequest/                     ← Godot project
│   ├── project.godot                        ← stretch mode settings here
│   ├── export_presets.cfg                   ← Android export config
│   ├── invokequest.keystore                 ← signing key (gitignored)
│   ├── addons/mobile_wallet_adapter/
│   │   ├── MobileWalletAdapter.gd           ← GDScript wrapper (fixed)
│   │   ├── android/InvokeMWA.gdap           ← plugin config
│   │   └── plugin.cfg
│   └── android/build/
│       ├── AndroidManifest.xml              ← meta-data tag here
│       ├── config.gradle                    ← minSdk=28 here
│       ├── gradle.properties                ← package name + signing here
│       ├── build.gradle                     ← AAR dependency here
│       └── patch_apk_icons.py               ← icon patcher
```

---

## ENVIRONMENT

- **Godot:** `C:\Tools\Godot\Godot_v4.2.2-stable_win64.exe`
- **Android SDK:** `C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk`
- **JDK 17** installed
- **Python 3.13** with Pillow + NumPy
- **Node.js v22.22.1**
- **ADB** available in PATH

**Open Godot:**
```powershell
& "C:\Tools\Godot\Godot_v4.2.2-stable_win64.exe" --editor --path "C:\PROJECTS\Invoke_Solana_App\example\invokequest"
```

---

## CRITICAL NOTES

### PowerShell Tab Stripping — PERMANENT WORKAROUND
NEVER write `.gd` files via PowerShell here-strings. Always use Python scripts with explicit `\t` characters. Use `create_file` tool → download → run with Python.

### Kotlin Plugin Class Name
The `<meta-data>` `android:value` must exactly match the Kotlin class registered with Godot's plugin system. Open `MWAPlugin.kt` and find the string passed to the `GodotPlugin` super constructor. It is likely `"InvokeMWA"` but must be verified.

### SceneManager Fade
`SceneManager.replace_scene()` uses a fade tween overlay that hangs on desktop (no plugin). All disconnect/back navigation uses `get_tree().change_scene_to_file()` directly as a workaround. This is intentional for desktop. On Android with plugin loaded, restore SceneManager after MWA is confirmed working.

### Wallet Icon Rendering
Wallet PNG icons have transparent rounded corners baked in via Python (PIL). The Godot desktop renderer shows them as squares due to scaling artifacts — they will render correctly on Android at native resolution.

---

## IMMEDIATE NEXT TASKS

### Priority 1 — Make MWA fire on device
1. Open `MWAPlugin.kt` — find exact plugin name string
2. Update `<meta-data>` android:value in AndroidManifest.xml to match exactly
3. Rebuild, sign, install, test Phantom tap
4. Check `adb logcat` for plugin load messages: `adb logcat | Select-String "InvokeMWA"`

### Priority 2 — Fix viewport scaling
1. Verify `project.godot` has correct stretch settings
2. Confirm the Godot assets in `android/build/assets/` are up to date
3. Rebuild and test on device

### Priority 3 — Full MWA flow test
Once plugin loads:
- Phantom auth → real wallet popup
- Auth token cache (kill app, reopen → auto-reconnect)
- Sign transaction
- Sign & send
- Sign message
- Capabilities
- Disconnect → back to WalletPicker

### Priority 4 — Demo video (Android, real device)
Record: fresh install → Phantom auth → cache demo → kill/reopen → auto-reconnect → sign tx → sign & send → sign message. This video goes in README and grant submission.

---

## GRANT SUBMISSION REMAINING TASKS

After Android MWA fully working:
1. Demo video (Android device, real wallets)
2. Docs homepage images (Recraft, 512x512): feature-plugin.png, feature-cache.png, feature-api.png → `docs/static/img/`
3. Update `docs/src/components/HomepageFeatures/index.tsx` with new images
4. README full professional treatment (ref: https://github.com/plinkdev1/SMWA-InjectionTool)
5. Fill Airtable grant application

---

## GIT STATE

- **main:** Phase 4 Task 4.1 merged (desktop QA complete)
- **develop:** ahead with Android build work
- Last meaningful commit: Android build setup, plugin wiring, icon, .gitignore

Push develop → create PR → merge to main after MWA confirmed working on device.
