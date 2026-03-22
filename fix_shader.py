content = """// glass_card.gdshader
// Glassmorphism card effect for InvokeQuest.
// Fixed for Godot 4.2 -- uses hint_screen_texture instead of deprecated SCREEN_TEXTURE.

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blur_strength: hint_range(0.0, 10.0) = 3.0;
uniform vec4 tint_color: source_color = vec4(1.0, 1.0, 1.0, 0.06);
uniform float border_alpha: hint_range(0.0, 1.0) = 0.10;
uniform float border_width: hint_range(0.0, 0.05) = 0.008;
uniform vec4 border_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 screen_sample = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_strength);
    COLOR = mix(screen_sample, tint_color, tint_color.a);
    COLOR.a = 1.0;

    float edge_x = step(1.0 - border_width, UV.x) + step(UV.x, border_width);
    float edge_y = step(1.0 - border_width, UV.y) + step(UV.y, border_width);
    float border = clamp(edge_x + edge_y, 0.0, 1.0);
    COLOR.rgb = mix(COLOR.rgb, border_color.rgb, border * border_alpha);
}
"""

with open(r'C:\PROJECTS\Invoke_Solana_App\example\invokequest\shaders\glass_card.gdshader', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
print('glass_card.gdshader fixed.')
