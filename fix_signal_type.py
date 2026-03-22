path = r"C:\PROJECTS\Invoke_Solana_App\android\plugin\src\main\kotlin\com\invoke\mwa\MWAPlugin.kt"

with open(path, "r", encoding="utf-8", errors="replace") as f:
    content = f.read()

old = 'SignalInfo("mwa_error",             Int::class.java, String::class.java)'
new = 'SignalInfo("mwa_error",             Integer::class.javaObjectType, String::class.java)'

if old in content:
    content = content.replace(old, new)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Fixed: mwa_error signal now uses Integer::class.javaObjectType")
else:
    print("Pattern not found - checking current state:")
    for line in content.splitlines():
        if "mwa_error" in line and "SignalInfo" in line:
            print(repr(line))
