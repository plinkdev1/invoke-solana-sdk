// glass_card.gdshader
// Glassmorphism card effect for InvokeQuest.
// Reference: SOLANAQUEST_ASSET_MAP.md Section 5A.
// Used by: GlassCard.tscn, WalletBadge.tscn, CacheStatusCard.tscn, BottomSheet.tscn
//
// Attach to a PanelContainer or ColorRect as a ShaderMaterial.
// Defaults match DesignTokens: GLASS_BLUR_STRENGTH, GLASS_TINT_ALPHA, GLASS_BORDER_ALPHA.

shader_type canvas_item;

uniform float blur_strength: hint_range(0.0, 10.0) = 3.0;
uniform vec4 tint_color: source_color = vec4(1.0, 1.0, 1.0, 0.06);
uniform float border_alpha: hint_range(0.0, 1.0) = 0.10;
uniform float border_width: hint_range(0.0, 0.05) = 0.008;
uniform vec4 border_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // Sample the screen behind this element with a blur LOD approximation
    vec4 screen_sample = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_strength);

    // Blend frosted tint over the blurred screen
    COLOR = mix(screen_sample, tint_color, tint_color.a);
    COLOR.a = 1.0;

    // Thin border glow on all four edges
    float edge_x = step(1.0 - border_width, UV.x) + step(UV.x, border_width);
    float edge_y = step(1.0 - border_width, UV.y) + step(UV.y, border_width);
    float border = clamp(edge_x + edge_y, 0.0, 1.0);
    COLOR.rgb = mix(COLOR.rgb, border_color.rgb, border * border_alpha);
}
