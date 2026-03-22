import os

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest"

fixes = {
"scenes/screens/SignTransaction.gd": (
    'var sig := signatures[0] if signatures.size() > 0 else "no signature"',
    'var sig: String = str(signatures[0]) if signatures.size() > 0 else "no signature"'
),
"scenes/screens/SignAndSend.gd": (
    'var sig := signatures[0] if signatures.size() > 0 else "no signature"',
    'var sig: String = str(signatures[0]) if signatures.size() > 0 else "no signature"'
),
"scenes/screens/SignMessage.gd": (
    'var result := signed_messages[0] if signed_messages.size() > 0 else "no result"',
    'var result: String = str(signed_messages[0]) if signed_messages.size() > 0 else "no result"'
),
}

for rel_path, (old, new) in fixes.items():
    full = os.path.join(base, rel_path.replace("/", os.sep))
    with open(full, "r", encoding="utf-8") as f:
        content = f.read()
    if old in content:
        content = content.replace(old, new)
        with open(full, "w", encoding="utf-8", newline="\n") as f:
            f.write(content)
        print(f"Fixed: {rel_path}")
    else:
        print(f"Pattern not found in: {rel_path}")

# Fix AuthCache.gd - the else clause indentation issue
ac_path = os.path.join(base, "scenes", "screens", "AuthCache.gd")
with open(ac_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

out = []
i = 0
while i < len(lines):
    line = lines[i]
    stripped = line.strip()
    # Fix standalone else/elif that lost its indentation context
    if stripped.startswith("else:") or stripped.startswith("elif "):
        # Find the indent level of the preceding if block
        indent = "\t"
        for j in range(len(out)-1, -1, -1):
            prev = out[j].rstrip()
            if prev.strip().startswith("if ") or prev.strip().startswith("elif "):
                indent = "\t" * (len(prev) - len(prev.lstrip()))
                break
        out.append(indent + stripped + "\n")
    else:
        out.append(line)
    i += 1

with open(ac_path, "w", encoding="utf-8", newline="\n") as f:
    f.writelines(out)
print("Fixed: scenes/screens/AuthCache.gd")
print("Done.")
