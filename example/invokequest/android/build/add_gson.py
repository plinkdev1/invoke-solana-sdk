path = "build.gradle"
with open(path, "r") as f:
    content = f.read()

if "gson" in content:
    print("Gson already present - no change needed")
else:
    line = '    implementation "com.google.code.gson:gson:2.10.1"'
    marker = '    implementation "androidx.fragment:fragment:$versions.fragmentVersion"'
    content = content.replace(marker, marker + "\n" + line)
    with open(path, "w") as f:
        f.write(content)
    print("Added Gson to build.gradle")
