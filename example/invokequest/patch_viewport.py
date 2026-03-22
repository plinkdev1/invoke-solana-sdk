import re, shutil, os

path = "project.godot"
assets = os.path.join("android", "build", "assets", "project.godot")

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

if "[display]" not in content:
    content += "\n[display]\n"

changes = [
    ("window/stretch/mode",   '"canvas_items"'),
    ("window/stretch/aspect", '"expand"'),
]

for key, val in changes:
    p = re.compile(r"^" + re.escape(key) + r"\s*=.*$", re.MULTILINE)
    repl = key + "=" + val
    if p.search(content):
        content = p.sub(repl, content)
        print("updated:", repl)
    else:
        content = content.replace("[display]", "[display]\n" + repl, 1)
        print("added:", repl)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

assets_dir = os.path.dirname(assets)
if os.path.isdir(assets_dir):
    shutil.copy2(path, assets)
    print("synced to:", assets)
else:
    print("WARNING: assets/ dir not found -", assets_dir)
    print("project.godot patched but NOT synced to APK assets yet.")
    print("Run gradlew generateGodotResources once, then re-run this script.")
