path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Fix authorize() call - iconUri must be relative or null
old = """                        authorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = android.net.Uri.parse(icon),
                            identityName = name
                        )"""

new = """                        authorize(
                            identityUri  = android.net.Uri.parse(uri),
                            iconUri      = if (icon.isNotEmpty() && !icon.contains("://")) android.net.Uri.parse(icon) else null,
                            identityName = name
                        )"""

# Also fix buildAdapter to use relative iconUri
old2 = """    private fun buildAdapter(name: String, uri: String, icon: String): MobileWalletAdapter {
        return MobileWalletAdapter(
            connectionIdentity = ConnectionIdentity(
                identityUri  = android.net.Uri.parse(uri),
                iconUri      = android.net.Uri.parse(icon),
                identityName = name
            )
        )
    }"""

new2 = """    private fun buildAdapter(name: String, uri: String, icon: String): MobileWalletAdapter {
        return MobileWalletAdapter(
            connectionIdentity = ConnectionIdentity(
                identityUri  = android.net.Uri.parse(uri),
                iconUri      = if (icon.isNotEmpty() && !icon.contains("://")) android.net.Uri.parse(icon) else null,
                identityName = name
            )
        )
    }"""

fixed = 0
if old in content:
    content = content.replace(old, new)
    fixed += 1
    print("Fixed authorize() iconUri")

if old2 in content:
    content = content.replace(old2, new2)
    fixed += 1
    print("Fixed buildAdapter() iconUri")

if fixed > 0:
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Done - {fixed} fixes applied")
else:
    print("Patterns not found")
