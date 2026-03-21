# Splash.gd
# Splash screen -- InvokeQuest entry point.
# Animates logo in, then navigates to WalletPicker or Dashboard after 2.5s.
# Reference: SOLANAQUEST_ASSET_MAP.md Section 6B.

extends Control

const AUTO_ADVANCE_DELAY := 2.5

@onready var splash_icon: TextureRect    = $Center/VBox/SplashIcon
@onready var splash_logo: Label          = $Center/VBox/SplashLogo
@onready var splash_sub:  Label          = $Center/VBox/SplashSub
@onready var splash_dots: HBoxContainer  = $Center/VBox/SplashDots

func _ready() -> void:
# Wait two frames for VBoxContainer to finish initial layout
# before reading positions or starting tweens.
await get_tree().process_frame
await get_tree().process_frame
_play_enter_animations()
await get_tree().create_timer(AUTO_ADVANCE_DELAY).timeout
_navigate()

func _play_enter_animations() -> void:
# Icon: scale up from 0.7 + fade in (delay 0.1s, ease_out_back)
var t_icon := create_tween().set_parallel(true)
t_icon.tween_property(splash_icon, "modulate:a", 1.0, DesignTokens.ANIM_XSLOW) \
.set_delay(0.1)
t_icon.tween_property(splash_icon, "scale", Vector2(1.0, 1.0), 0.5) \
.set_delay(0.1) \
.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Logo: slide up from +40px + fade in (delay 0.2s)
var logo_rest_y := splash_logo.position.y
splash_logo.position.y = logo_rest_y + 40.0
var t_logo := create_tween().set_parallel(true)
t_logo.tween_property(splash_logo, "modulate:a", 1.0, 0.5).set_delay(0.2)
t_logo.tween_property(splash_logo, "position:y", logo_rest_y, 0.6) \
.set_delay(0.2) \
.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# Subtitle: fade in (delay 0.6s)
var t_sub := create_tween()
t_sub.tween_interval(0.6)
t_sub.tween_property(splash_sub, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

# Dots: fade in (delay 0.8s)
var t_dots := create_tween()
t_dots.tween_interval(0.8)
t_dots.tween_property(splash_dots, "modulate:a", 1.0, DesignTokens.ANIM_FAST * 2.0)

func _navigate() -> void:
# If plugin is loaded and a cached token exists, skip wallet picker
if Engine.has_singleton("InvokeMWA"):
var plugin = Engine.get_singleton("InvokeMWA")
if plugin.cacheHasToken():
SceneManager.replace_scene(SceneManager.SCENE_DASHBOARD)
return
SceneManager.replace_scene(SceneManager.SCENE_WALLET_PICKER)
