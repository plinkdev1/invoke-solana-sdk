// aurora_background.gdshader
// Animated aurora background for InvokeQuest.
// Reference: SOLANAQUEST_ASSET_MAP.md Section 5B.
// Used by: Splash.tscn (animated), all other screens (time_scale=0.0 to freeze).
//
// Attach to a full-screen ColorRect as a ShaderMaterial.
// On Splash: leave time_scale at default (0.3) for animation.
// On other screens: set time_scale=0.0 and adjust color alphas down for subtlety.

shader_type canvas_item;

uniform float time_scale: hint_range(0.0, 2.0) = 0.3;
uniform vec4 color_a: source_color = vec4(0.600, 0.271, 1.000, 0.15); // #9945FF purple
uniform vec4 color_b: source_color = vec4(0.078, 0.945, 0.596, 0.08); // #14F195 teal
uniform vec4 bg_color: source_color = vec4(0.031, 0.039, 0.055, 1.0);  // #080A0F

void fragment() {
    vec2 uv = UV;
    float t = TIME * time_scale;

    // Two overlapping sine waves for organic aurora movement
    float wave1 = sin(uv.x * 3.0 + t) * 0.5 + 0.5;
    float wave2 = sin(uv.x * 2.0 - t * 0.7 + 1.5) * 0.5 + 0.5;

    // Fade aurora toward screen bottom (top-heavy glow)
    float aurora1 = smoothstep(0.0, 0.6, wave1 * (1.0 - uv.y));
    // Subtle secondary aurora toward screen top
    float aurora2 = smoothstep(0.0, 0.5, wave2 * uv.y * 0.4);

    vec4 col = bg_color;
    col = mix(col, color_a, aurora1 * 0.6);
    col = mix(col, color_b, aurora2 * 0.4);
    COLOR = col;
}
