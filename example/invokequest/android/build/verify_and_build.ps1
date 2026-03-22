# verify_and_build.ps1  —  INVOKE SDK Phase 4
# Run from: C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build
# Usage: .\verify_and_build.ps1
#
# Checks that the AndroidManifest fix is correctly applied, then runs the
# full build → sign → install pipeline.

$ErrorActionPreference = "Stop"

$ProjectRoot  = "C:\PROJECTS\Invoke_Solana_App\example\invokequest"
$BuildDir     = "$ProjectRoot\android\build"
$Manifest     = "$BuildDir\AndroidManifest.xml"
$ApkRelease   = "$BuildDir\build\outputs\apk\release\android_release.apk"
$ApkPatched   = "$BuildDir\build\outputs\apk\release\android_release_patched.apk"
$ApkSigned    = "$BuildDir\build\outputs\apk\release\android_release_signed.apk"
$Keystore     = "$ProjectRoot\invokequest.keystore"

Write-Host "`n=== Step 0: Verify AndroidManifest.xml fix ===" -ForegroundColor Cyan

$manifestContent = Get-Content $Manifest -Raw

# Check meta-data is inside <application>
$appIdx  = $manifestContent.IndexOf("<application")
$metaIdx = $manifestContent.IndexOf("org.godotengine.plugin.v2.InvokeMWA")

if ($metaIdx -lt 0) {
    Write-Host "  ERROR: meta-data tag not found in manifest!" -ForegroundColor Red
    exit 1
}
if ($metaIdx -lt $appIdx) {
    Write-Host "  ERROR: meta-data is BEFORE <application> — Bug 1 still present!" -ForegroundColor Red
    Write-Host "  Replace AndroidManifest.xml with the fixed version first." -ForegroundColor Red
    exit 1
}
Write-Host "  OK: meta-data is inside <application>" -ForegroundColor Green

# Check queries block
if ($manifestContent -notmatch "<queries>") {
    Write-Host "  WARNING: <queries> block missing — getInstalledWallets() will return empty on Android 11+" -ForegroundColor Yellow
} else {
    Write-Host "  OK: <queries> block present" -ForegroundColor Green
}

Write-Host "`n=== Step 1: Sync project.godot viewport settings ===" -ForegroundColor Cyan
Push-Location $ProjectRoot
python fix_viewport.py
Pop-Location

Write-Host "`n=== Step 2: Gradle clean + assembleRelease ===" -ForegroundColor Cyan
Push-Location $BuildDir
.\gradlew.bat clean assembleRelease
if ($LASTEXITCODE -ne 0) { Write-Host "Gradle build failed." -ForegroundColor Red; exit 1 }
Pop-Location
Write-Host "  Build OK" -ForegroundColor Green

Write-Host "`n=== Step 3: Patch icons ===" -ForegroundColor Cyan
Push-Location $BuildDir
python patch_apk_icons.py
Pop-Location

Write-Host "`n=== Step 4: Sign APK ===" -ForegroundColor Cyan
$BuildTools = Get-ChildItem "C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk\build-tools\" |
    Sort-Object Name -Descending | Select-Object -First 1
$ApkSigner = "$($BuildTools.FullName)\apksigner.bat"

& $ApkSigner sign `
    --ks $Keystore `
    --ks-key-alias invokequest `
    --ks-pass pass:invokequest123 `
    --key-pass pass:invokequest123 `
    --out $ApkSigned `
    $ApkPatched

if ($LASTEXITCODE -ne 0) { Write-Host "Signing failed." -ForegroundColor Red; exit 1 }
Write-Host "  Signed: $ApkSigned" -ForegroundColor Green

Write-Host "`n=== Step 5: Install on device ===" -ForegroundColor Cyan
adb uninstall dev.invoke.invokequest 2>$null
adb install $ApkSigned
if ($LASTEXITCODE -ne 0) { Write-Host "ADB install failed." -ForegroundColor Red; exit 1 }
Write-Host "  Installed OK" -ForegroundColor Green

Write-Host "`n=== Step 6: Verify plugin loads (Ctrl+C to stop) ===" -ForegroundColor Cyan
Write-Host "  Watching logcat for InvokeMWA..." -ForegroundColor Yellow
Write-Host "  You should see: 'MWAPlugin onMainCreate' within 3 seconds of app launch`n"
adb logcat -c
adb logcat | Select-String -Pattern "InvokeMWA|GodotPlugin|invoke" -CaseSensitive:$false
