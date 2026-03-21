from PIL import Image
import os, zipfile, glob

src = r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\assets\images\splash\splash_logo_mark.png'
img = Image.open(src).convert('RGBA')

icons = {
    '7j.png': 48,
    '_J.png': 72,
    'mS.png': 96,
    'ly.png': 144,
    'vI.png': 192,
    'hW.png': 192,
    'U2.png': 108,
    'mI.png': 162,
    'Qi.png': 216,
    'Tq.png': 324,
    'fK.png': 432,
}

tmp = r'C:\PROJECTS\icon_tmp'
os.makedirs(tmp, exist_ok=True)

for fname, size in icons.items():
    bg = Image.new('RGBA', (size, size), (8, 10, 15, 255))
    resized = img.resize((size, size), Image.LANCZOS)
    bg.paste(resized, (0, 0), resized)
    bg.convert('RGBA').save(os.path.join(tmp, fname), 'PNG')
    print(f'Generated {fname} ({size}x{size})')

apks = glob.glob(r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\android\build\build\outputs\apk\release\*.apk')
apks = [a for a in apks if '_patched' not in a]
apk = apks[0]
patched = apk.replace('.apk', '_patched.apk')

with zipfile.ZipFile(apk, 'r') as zin:
    with zipfile.ZipFile(patched, 'w', zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            fname = os.path.basename(item.filename)
            if fname in icons:
                zout.write(os.path.join(tmp, fname), item.filename)
                print(f'Replaced: {item.filename}')
            else:
                zout.writestr(item, zin.read(item.filename))

print('Patched APK:', patched)
