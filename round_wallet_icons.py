from PIL import Image, ImageDraw
import os

def add_rounded_corners(img_path, radius=32):
    img = Image.open(img_path).convert("RGBA")
    w, h = img.size

    # Create rounded mask
    mask = Image.new("L", (w, h), 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (w-1, h-1)], radius=radius, fill=255)

    # Apply mask to alpha channel
    r, g, b, a = img.split()
    new_a = Image.fromarray(__import__('numpy').minimum(
        __import__('numpy').array(a),
        __import__('numpy').array(mask)
    ))
    result = Image.merge("RGBA", (r, g, b, new_a))
    result.save(img_path, "PNG")
    print(f"Rounded: {os.path.basename(img_path)}")

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest\assets\icons\wallets"
wallets = ["wallet_phantom.png", "wallet_backpack.png", "wallet_solflare.png"]

for w in wallets:
    add_rounded_corners(os.path.join(base, w), radius=24)

print("Done.")
