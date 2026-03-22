path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWABridge.kt"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Fix both occurrences - just pass null for iconUri
old1 = '                iconUri      = if (icon.isNotEmpty() && !icon.contains("://")) android.net.Uri.parse(icon) else null,'
old2 = '                            iconUri      = if (icon.isNotEmpty() && !icon.contains("://")) android.net.Uri.parse(icon) else null,'

new1 = '                iconUri      = null,'
new2 = '                            iconUri      = null,'

count = 0
if old1 in content:
    content = content.replace(old1, new1)
    count += 1
if old2 in content:
    content = content.replace(old2, new2)
    count += 1

with open(path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"Fixed {count} iconUri occurrences to null")
