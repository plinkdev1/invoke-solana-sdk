from PIL import Image
import os

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest\assets\icons\wallets"
wallets = ["wallet_phantom.png", "wallet_backpack.png", "wallet_solflare.png"]

for w in wallets:
    path = os.path.join(base, w)
    img = Image.open(path).convert("RGBA")
    width, height = img.size
    # Check corner pixel transparency
    top_left     = img.getpixel((0, 0))
    top_right    = img.getpixel((width-1, 0))
    bottom_left  = img.getpixel((0, height-1))
    bottom_right = img.getpixel((width-1, height-1))
    center       = img.getpixel((width//2, height//2))
    print(f"\n{w}:")
    print(f"  Size: {width}x{height}")
    print(f"  Top-left RGBA:     {top_left}  (alpha should be 0 if rounded)")
    print(f"  Top-right RGBA:    {top_right}")
    print(f"  Bottom-left RGBA:  {bottom_left}")
    print(f"  Bottom-right RGBA: {bottom_right}")
    print(f"  Center RGBA:       {center}  (alpha should be 255)")
