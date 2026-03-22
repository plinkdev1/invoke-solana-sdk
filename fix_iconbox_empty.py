import os

path = r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\scenes\screens\WalletPicker.tscn'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add StyleBoxEmpty sub_resource after the existing sub_resources
empty_style = '[sub_resource type="StyleBoxEmpty" id="StyleBoxEmpty_1"]\n\n'

# Insert before first [node] declaration
content = content.replace('[node name="WalletPicker"', empty_style + '[node name="WalletPicker"', 1)

# Replace all IconBox nodes to use StyleBoxEmpty
for wallet in ['CardPhantom/BtnPhantom', 'CardBackpack/BtnBackpack', 'CardSolflare/BtnSolflare']:
    old = f'[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/{wallet}/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\nclip_contents = true'
    new = f'[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/{wallet}/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\nclip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxEmpty_1")'
    content = content.replace(old, new)

# Fix load_steps count (increment by 1 for the new sub_resource)
content = content.replace('[gd_scene load_steps=10 format=3]', '[gd_scene load_steps=11 format=3]')

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('IconBox set to StyleBoxEmpty -- PNG transparency will now show.')
