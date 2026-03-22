import os

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest"
wallets = ["wallet_phantom", "wallet_backpack", "wallet_solflare"]

for w in wallets:
    src = os.path.join(base, "assets", "icons", "wallets", f"{w}.png")
    import_path = src + ".import"

    content = f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid=""
path.s3tc="res://.godot/imported/{w}.png.ctex"
metadata={{"vram_texture": false}}

[deps]

source_file="res://assets/icons/wallets/{w}.png"
dest_files=["res://.godot/imported/{w}.png.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
svg/scale=1.0
editor/scale_with_editor_scale=false
editor/convert_colors_with_editor_theme=false
"""
    with open(import_path, 'w', encoding='utf-8', newline='\n') as f:
        f.write(content)
    print(f"Fixed import: {w}.png.import")

print("Done. Delete .godot/imported/wallet_* cache and reimport in Godot.")
