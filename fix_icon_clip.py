import os

path = r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\scenes\screens\WalletPicker.tscn'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add clip_contents = true to each IconBox node
content = content.replace(
    '[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/CardPhantom/BtnPhantom/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\ntheme_override_styles/panel = SubResource("StyleBoxFlat_phantom")',
    '[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/CardPhantom/BtnPhantom/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\nclip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxFlat_phantom")'
)

content = content.replace(
    '[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/CardBackpack/BtnBackpack/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\ntheme_override_styles/panel = SubResource("StyleBoxFlat_backpack")',
    '[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/CardBackpack/BtnBackpack/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\nclip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxFlat_backpack")'
)

content = content.replace(
    '[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/CardSolflare/BtnSolflare/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\ntheme_override_styles/panel = SubResource("StyleBoxFlat_solflare")',
    '[node name="IconBox" type="PanelContainer" parent="Scroll/VBox/CardSolflare/BtnSolflare/Row"]\nlayout_mode = 2\ncustom_minimum_size = Vector2(60, 60)\nsize_flags_vertical = 4\nclip_contents = true\ntheme_override_styles/panel = SubResource("StyleBoxFlat_solflare")'
)

with open(path, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('WalletPicker.tscn - clip_contents added to all icon boxes.')
