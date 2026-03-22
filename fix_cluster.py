path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

old = """                        authorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = android.net.Uri.parse(icon),
                            identityName = name,
                            cluster      = null
                        )"""

new = """                        authorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = android.net.Uri.parse(icon),
                            identityName = name
                        )"""

if old in content:
    content = content.replace(old, new)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Fixed: removed cluster parameter from authorize()")
else:
    print("Pattern not found")
