import os

path = r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\scenes\screens\WalletPicker.tscn'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the colored panel style from IconBox nodes -- let PNG transparency show through
content = content.replace(
    'clip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxFlat_phantom")',
    'clip_contents = true'
)
content = content.replace(
    'clip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxFlat_backpack")',
    'clip_contents = true'
)
content = content.replace(
    'clip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxFlat_solflare")',
    'clip_contents = true'
)

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('IconBox color backgrounds removed -- PNG transparency will show through.')
