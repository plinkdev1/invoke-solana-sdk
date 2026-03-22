import re

path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8", errors="replace") as f:
    content = f.read()

old_fields = "    private val isSessionActive = AtomicBoolean(false)"
new_fields = (
    "    private val sender = ActivityResultSender(activity)\n"
    "    private val isSessionActive = AtomicBoolean(false)"
)

if "private val sender = ActivityResultSender" in content:
    print("sender field already exists - skipping field addition")
else:
    content = content.replace(old_fields, new_fields)
    print("Added sender field to class")

pattern = r"[ \t]+val sender\s*=\s*ActivityResultSender\(activity\)\n"
count = len(re.findall(pattern, content))
content = re.sub(pattern, "", content)
print(f"Removed {count} local sender instantiations")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("Done - MWABridge.kt patched")
