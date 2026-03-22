# INVOKE SDK — Agent Handoff Document
**Date:** 2026-03-22 (afternoon session)
**Branch:** develop (merged to main as PR #13)
**Repo:** https://github.com/plinkdev1/invoke-solana-sdk
**Local:** C:\PROJECTS\Invoke_Solana_App
**Last stable commit:** af320ec (main)

---

## Project Overview

INVOKE SDK is a Solana Mobile Wallet Adapter (MWA 2.0.3) plugin for Godot 4 on Android. It lets Godot games/dApps connect to Solana wallets via the MWA protocol.

Stack: Godot 4.2.2 + Kotlin Android Plugin (AAR) + GDScript + MWA clientlib-ktx 2.0.3
Build method: Direct Gradle (NEVER Godot editor export)
Package: dev.invoke.invokequest
Keystore: example/invokequest/invokequest.keystore (alias: invokequest, pass: invokequest123)
Phone: Samsung Galaxy (1080x2340, 480 DPI, Android 14)

---

## Current Working State

- Solflare auth flow working end-to-end
- Jupiter auth flow working end-to-end
- Disconnect working
- Repo clean, merged to main

---

## Tasks Remaining (Priority Order)

### 1. WALLET PICKER REDESIGN (do first)
The current WalletPicker screen shows 3 individual wallet cards (Phantom, Backpack, Solflare).
These serve no purpose — when you tap any card, Android shows its own system MWA wallet picker anyway, and the user has to pick again from the system picker.
REDESIGN: Replace the entire wallet cards UI with a single "Connect Wallet" button that directly triggers the MWA wallet picker. Remove all individual wallet card nodes from the .tscn. Keep the loading overlay and status label.

### 2. CACHE NOT PERSISTING
When user closes app and reopens, they must connect again instead of auto-reconnecting.
The auth token cache exists in AuthCacheImpl.kt but the isSessionActive AtomicBoolean gets stuck after failed sign operations, which also blocks the reauthorize flow.
Fix: Ensure finally { isSessionActive.set(false) } in every coroutine in MWABridge.kt.

### 3. SIGN TRANSACTION / SIGN & SEND / SIGN MESSAGE
All return error 9999 because demo app sends dummy/empty transaction bytes.
Need a real minimal Solana devnet transaction — a simple memo transaction or self-transfer of 0 SOL.
Build it in Kotlin using the Solana transaction format before passing to signTransactions().

### 4. UI SIZING
Content fills only top ~35% of screen. Black bars top and bottom.
Many fixes were attempted and FAILED (do not retry these):
- viewport_width/height changes
- fullscreen=true, mode=3, mode=4
- windowLayoutInDisplayCutoutMode
These all failed. The issue is likely at the scene layout level. Each screen's root Control node needs proper anchor/size settings to fill the full display area on high-DPI Samsung devices.

### 5. BACKPACK
Session connects then immediately disconnects. Believed to be Backpack MWA 2.0 incompatibility. Document as known limitation in README. Do not spend time debugging.

### 6. PHANTOM
Rejects with "authorization request failed" because invoke.dev is not verified with Phantom. Normal behavior for unverified dApps. Document this. Use Solflare/Jupiter for all testing.

---

## MVP Requirements for Grant Submission

- Wallet picker redesigned to single Connect Wallet button
- Cache persistence working (reopen app = auto reconnect)
- isSessionActive bug fixed
- Real Solana devnet transaction working for Sign Transaction demo
- Full flow tested: auth → sign tx → sign & send → sign message → disconnect → cache
- UI sizing fixed
- Demo video recorded on real device
- 3x feature images for docs (512x512, use Recraft): feature-plugin.png, feature-cache.png, feature-api.png → docs/static/img/
- Update docs/src/components/HomepageFeatures/index.tsx
- README professional treatment
- Docusaurus docs complete with install guide + API reference
- Airtable grant application submitted

---

## Full Build Command (memorize this)

From C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build\:

.\gradlew.bat clean assembleRelease; python patch_apk_icons.py; $bt = Get-ChildItem "C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk\build-tools\" | Sort-Object Name -Descending | Select-Object -First 1; & "$($bt.FullName)\apksigner.bat" sign --ks "C:\PROJECTS\Invoke_Solana_App\example\invokequest\invokequest.keystore" --ks-key-alias invokequest --ks-pass pass:invokequest123 --key-pass pass:invokequest123 --out build\outputs\apk\release\android_release_signed.apk build\outputs\apk\release\android_release_patched.apk; adb uninstall dev.invoke.invokequest; adb install build\outputs\apk\release\android_release_signed.apk

After Kotlin changes: build AAR first, copy to both lib locations, then full APK rebuild.
After scene changes: open Godot editor, Ctrl+S, close, copy .tscn to build assets, rebuild WITHOUT clean.
After project.godot changes: copy to android\build\assets\project.godot then rebuild.

---

## CRITICAL FORBIDDEN COMMANDS

### NEVER DO THIS IN POWERSHELL:
git show HASH:path/file > destination

This creates UTF-16 BOM files that silently corrupt Godot .tscn files, causing:
"Parse Error: Expected '['" in Godot editor
Black screen / splash screen hang on device

### ALWAYS USE PYTHON INSTEAD:
python -c "
import subprocess
result = subprocess.run(['git', '-C', r'C:\PROJECTS\Invoke_Solana_App', 'show', 'HASH:path/to/file'], capture_output=True)
open(r'C:\destination\file', 'wb').write(result.stdout)
print('done, size:', len(result.stdout))
"

### OTHER FORBIDDEN THINGS:
- NEVER write .gd files with PowerShell here-strings (@' '@) — tabs get stripped, GDScript breaks
- NEVER use && as command separator in PowerShell — use ; instead
- NEVER use complex Python inline -c with double quotes in PowerShell — save to .py file and run it
- NEVER call _mwa.setActiveWallet() from GDScript — this method does NOT exist in MWAPlugin.kt
- NEVER rely on headless Godot export to compile WalletPicker.tscn — it skips it every time
- NEVER assume a 1-3 second Gradle build packaged your scene changes — it used cache, verify with aapt

---

## Critical Build Knowledge

### The build assets folder problem:
android\build\assets\ is a SEPARATE COPY from the project source.
Gradle's clean task wipes it completely.
After any clean build, compiled .scn files are gone from assets\.godot\exported\133200997\
Fix: copy them back from example\invokequest\.godot\exported\133200997\

### After clean build, if app shows black screen or splash hang:
1. Check if .scn files exist in build assets:
   Get-ChildItem "android\build\assets\.godot\exported\133200997\"
2. If empty, copy from project:
   Copy-Item -Recurse "example\invokequest\.godot\exported\133200997\*" "android\build\assets\.godot\exported\133200997\" -Force
3. Also copy imported textures:
   Copy-Item -Recurse "example\invokequest\.godot\imported\*" "android\build\assets\.godot\imported\" -Force
4. Rebuild WITHOUT clean:
   .\gradlew.bat assembleRelease (not clean assembleRelease)

### AndroidManifest.xml is NOT in git:
android\build\ is gitignored. The manifest gets wiped by clean builds.
Restore from git when MWA stops working after a clean build:
python -c "
import subprocess
result = subprocess.run(['git', '-C', r'C:\PROJECTS\Invoke_Solana_App', 'show', 'af320ec:example/invokequest/android/build/AndroidManifest.xml'], capture_output=True)
open(r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build\AndroidManifest.xml', 'wb').write(result.stdout)
print('done')
"

### Required AndroidManifest.xml contents:
meta-data tag MUST be inside <application> tag:
<meta-data android:name="org.godotengine.plugin.v2.InvokeMWA" android:value="com.invoke.mwa.MWAPlugin" />

queries block for wallet detection:
<queries>
    <intent><action android:name="com.solana.mobilewalletadapter.walletlib.scenario.ACTION_HELLO"/></intent>
    <package android:name="app.phantom"/>
    <package android:name="com.backpack.wallet"/>
    <package android:name="com.solflare.mobile"/>
    <package android:name="ag.jup.jupiter.android"/>
</queries>

android:exported="true" on GodotApp activity in src\release\AndroidManifest.xml

---

## Key File Locations

C:\PROJECTS\Invoke_Solana_App\
├── android\plugin\src\main\kotlin\com\invoke\mwa\
│   ├── MWABridge.kt          ALL wallet logic (authorize, sign, cache)
│   ├── MWAPlugin.kt          Godot plugin registration + signals
│   ├── AuthCacheImpl.kt      token cache
│   └── MWAError.kt           error codes
├── example\invokequest\
│   ├── project.godot
│   ├── scenes\screens\       all screen tscn + gd files
│   ├── addons\mobile_wallet_adapter\android\InvokeMWA.aar   AAR copy 1
│   └── android\build\
│       ├── build.gradle                runtime deps (add here not plugin)
│       ├── AndroidManifest.xml         NOT in git, must maintain manually
│       └── libs\release\InvokeMWA.aar  AAR copy 2
└── docs\                     Docusaurus docs site

---

## Wallet Status

Solflare (com.solflare.mobile) — WORKING
Jupiter (ag.jup.jupiter.android) — WORKING
Phantom (app.phantom) — rejects unverified dApp, normal behavior
Backpack (com.backpack.wallet) — MWA 2.0 incompatible, known limitation

---

## Environment

Godot editor: cd "C:\Tools\Godot\"; .\Godot_v4.2.2-stable_win64.exe
Android SDK: C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk
JDK 17, Python 3.13, Node.js v22, ADB in PATH
