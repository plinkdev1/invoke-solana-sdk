import re

path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8", errors="replace") as f:
    lines = f.readlines()

print("=== Lines 24-35 (current state) ===")
for i, line in enumerate(lines[23:35], start=24):
    print(f"{i}: {repr(line)}")

# Fix repeated private: "    private private val sender" -> "    private val sender"
fixed = []
for line in lines:
    fixed_line = re.sub(r'\bprivate\s+private\b', 'private', line)
    fixed.append(fixed_line)

with open(path, "w", encoding="utf-8") as f:
    f.writelines(fixed)

print("\nFixed repeated 'private' keyword")
print("Done")
