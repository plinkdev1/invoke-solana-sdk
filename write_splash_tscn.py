content = """[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://scenes/screens/Splash.gd" id="1"]
[ext_resource type="Shader" path="res://shaders/aurora_background.gdshader" id="2"]
[ext_resource type="Texture2D" path="res://assets/images/splash/splash_logo_mark.png" id="3"]

[sub_resource type="ShaderMaterial" id="ShaderMaterial_1"]
shader = ExtResource("2")
shader_parameter/time_scale = 0.3
shader_parameter/color_a = Color(0.6, 0.271, 1, 0.15)
shader_parameter/color_b = Color(0.078, 0.945, 0.596, 0.08)
shader_parameter/bg_color = Color(0.031, 0.039, 0.055, 1)

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_1"]
bg_color = Color(0.06, 0.06, 0.10, 1.0)
corner_radius_top_left = 32
corner_radius_top_right = 32
corner_radius_bottom_right = 32
corner_radius_bottom_left = 32
border_width_left = 1
border_width_top = 1
border_width_right = 1
border_width_bottom = 1
border_color = Color(1, 1, 1, 0.10)

[node name="Splash" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="BgColor" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(0.031, 0.039, 0.055, 1)

[node name="Aurora" type="ColorRect" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
color = Color(1, 1, 1, 1)
material = SubResource("ShaderMaterial_1")

[node name="Center" type="CenterContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2

[node name="VBox" type="VBoxContainer" parent="Center"]
layout_mode = 2
custom_minimum_size = Vector2(800, 0)
theme_override_constants/separation = 32

[node name="IconContainer" type="PanelContainer" parent="Center/VBox"]
layout_mode = 2
custom_minimum_size = Vector2(256, 256)
size_flags_horizontal = 4
pivot_offset = Vector2(128, 128)
theme_override_styles/panel = SubResource("StyleBoxFlat_1")

[node name="SplashIcon" type="TextureRect" parent="Center/VBox/IconContainer"]
layout_mode = 2
custom_minimum_size = Vector2(256, 256)
scale = Vector2(0.7, 0.7)
modulate = Color(1, 1, 1, 0)
texture = ExtResource("3")
expand_mode = 1
stretch_mode = 5

[node name="SplashLogo" type="Label" parent="Center/VBox"]
layout_mode = 2
modulate = Color(1, 1, 1, 0)
text = "InvokeQuest"
horizontal_alignment = 1
theme_override_font_sizes/font_size = 36

[node name="SplashSub" type="Label" parent="Center/VBox"]
layout_mode = 2
modulate = Color(1, 1, 1, 0)
text = "Solana Wallet SDK for Godot"
horizontal_alignment = 1
theme_override_colors/font_color = Color(1, 1, 1, 0.6)
theme_override_font_sizes/font_size = 14

[node name="SplashDots" type="HBoxContainer" parent="Center/VBox"]
layout_mode = 2
size_flags_horizontal = 3
alignment = 1
modulate = Color(1, 1, 1, 0)
theme_override_constants/separation = 8

[node name="Dot1" type="ColorRect" parent="Center/VBox/SplashDots"]
layout_mode = 2
custom_minimum_size = Vector2(8, 8)
color = Color(0.6, 0.271, 1, 1)

[node name="Dot2" type="ColorRect" parent="Center/VBox/SplashDots"]
layout_mode = 2
custom_minimum_size = Vector2(8, 8)
color = Color(0.349, 0.608, 0.847, 1)

[node name="Dot3" type="ColorRect" parent="Center/VBox/SplashDots"]
layout_mode = 2
custom_minimum_size = Vector2(8, 8)
color = Color(0.078, 0.945, 0.596, 1)
"""

with open(r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\scenes\screens\Splash.tscn', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('Splash.tscn written.')
