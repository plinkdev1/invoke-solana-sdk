path = "build.gradle"
with open(path, "r") as f:
    content = f.read()

deps_to_add = [
    'implementation "com.google.code.gson:gson:2.10.1"',
    'implementation "com.solanamobile:mobile-wallet-adapter-clientlib-ktx:2.0.3"',
    'implementation "androidx.security:security-crypto:1.1.0-alpha06"',
    'implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3"',
    'implementation "io.github.funkatronics:multimult:0.2.3"',
    'implementation "androidx.activity:activity-ktx:1.8.2"',
    'implementation "androidx.fragment:fragment-ktx:1.6.2"',
]

marker = '    implementation "androidx.fragment:fragment:$versions.fragmentVersion"'

added = []
skipped = []
for dep in deps_to_add:
    # extract just the artifact id for the check
    artifact = dep.split('"')[1]
    short_id = artifact.split(":")[1]  # e.g. "gson", "mobile-wallet-adapter-clientlib-ktx"
    if short_id in content:
        skipped.append(short_id)
    else:
        content = content.replace(marker, marker + "\n    " + dep)
        added.append(short_id)

with open(path, "w") as f:
    f.write(content)

if added:
    print("Added:")
    for a in added:
        print(f"  + {a}")
if skipped:
    print("Already present (skipped):")
    for s in skipped:
        print(f"  = {s}")
