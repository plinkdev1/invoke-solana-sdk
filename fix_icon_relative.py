import subprocess, re

path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace both null iconUri with a valid relative URI
content = content.replace(
    '                iconUri      = null,',
    '                iconUri      = android.net.Uri.parse("favicon.ico"),'
)
content = content.replace(
    '                            iconUri      = null,',
    '                            iconUri      = android.net.Uri.parse("favicon.ico"),'
)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print("Replaced null iconUri with relative favicon.ico")
