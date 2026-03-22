import os, re

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest"

gd_files = []
for root, dirs, files in os.walk(base):
    for f in files:
        if f.endswith(".gd"):
            gd_files.append(os.path.join(root, f))

INDENT = "\t"

INDENT_AFTER = re.compile(r":\s*$")
DEDENT_WORDS = ("return", "pass", "break", "continue")

def reindent(lines):
    out = []
    level = 0
    for raw in lines:
        line = raw.rstrip("\n").rstrip()
        stripped = line.lstrip()

        if stripped == "":
            out.append("")
            continue

        # Detect dedent keywords at current level or annotation/func/class/var/const/signal at top
        if stripped.startswith(("func ", "class ", "signal ", "var ", "const ", "static ", "@", "#", "extends", "class_name")):
            # These reset to level 0 unless inside a class
            # Simple heuristic: if level > 1 and not inside nested func, keep
            # For our files: funcs are always top-level (level 0) or one deep
            if stripped.startswith(("func ", "static func ")):
                level = 0
            elif stripped.startswith(("var ", "const ", "signal ", "extends", "class_name", "@onready", "@export", "#")):
                # could be top-level or inside func -- use existing level
                pass

        out.append(INDENT * level + stripped)

        if INDENT_AFTER.search(stripped) and not stripped.startswith("#"):
            level += 1
        elif stripped.split()[0] in DEDENT_WORDS if stripped.split() else False:
            if level > 0:
                level -= 1

    return out

for path in gd_files:
    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()
    fixed = reindent(lines)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(fixed) + "\n")
    print(f"Reindented: {os.path.relpath(path, base)}")

print("Done.")
