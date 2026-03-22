#!/usr/bin/env python3
"""
fix_viewport.py  —  INVOKE SDK / InvokeQuest
Patches project.godot with the correct Android viewport stretch settings,
then copies the updated file into android/build/assets/ so the next
Gradle assembleRelease picks it up.

Run from: C:\PROJECTS\Invoke_Solana_App\example\invokequest\
    python fix_viewport.py
"""

import os, shutil, sys, re

PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
GODOT_FILE   = os.path.join(PROJECT_ROOT, "project.godot")
ASSETS_DIR   = os.path.join(PROJECT_ROOT, "android", "build", "assets")
ASSETS_FILE  = os.path.join(ASSETS_DIR, "project.godot")

STRETCH_SETTINGS = {
    "window/stretch/mode":   '"canvas_items"',
    "window/stretch/aspect": '"expand"',
}

def patch_project_godot(path: str) -> bool:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    original = content

    # Ensure [display] section exists
    if "[display]" not in content:
        content += "\n[display]\n"

    # Insert or update each setting
    for key, value in STRETCH_SETTINGS.items():
        pattern = re.compile(r"^" + re.escape(key) + r"\s*=.*$", re.MULTILINE)
        replacement = f"{key}={value}"
        if pattern.search(content):
            content = pattern.sub(replacement, content)
            print(f"  updated: {key}={value}")
        else:
            # Append under [display] section
            content = content.replace("[display]", f"[display]\n{replacement}", 1)
            print(f"  added:   {key}={value}")

    if content == original:
        print("  (no changes needed — settings already present)")
        return False

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    return True


def sync_to_assets(src: str, dst_dir: str, dst: str) -> None:
    if not os.path.isdir(dst_dir):
        print(f"\n  WARNING: assets dir not found: {dst_dir}")
        print("  Run a Godot export or `gradlew generateGodotResources` first to create it,")
        print("  then re-run this script.")
        return
    shutil.copy2(src, dst)
    print(f"\n  Synced to assets: {dst}")


def main():
    print("=== InvokeQuest viewport fix ===\n")

    if not os.path.isfile(GODOT_FILE):
        print(f"ERROR: project.godot not found at {GODOT_FILE}")
        print("Run this script from C:\\PROJECTS\\Invoke_Solana_App\\example\\invokequest\\")
        sys.exit(1)

    print(f"Patching: {GODOT_FILE}")
    changed = patch_project_godot(GODOT_FILE)

    sync_to_assets(GODOT_FILE, ASSETS_DIR, ASSETS_FILE)

    print("\n=== Next steps ===")
    print("1.  cd android\\build")
    print("2.  .\\gradlew.bat clean assembleRelease")
    print("3.  python patch_apk_icons.py")
    print("4.  Sign with apksigner (see AGENT_HANDOFF.md)")
    print("5.  adb install build\\outputs\\apk\\release\\android_release_signed.apk")
    print("6.  adb logcat | findstr InvokeMWA   <- verify plugin loads")


if __name__ == "__main__":
    main()
