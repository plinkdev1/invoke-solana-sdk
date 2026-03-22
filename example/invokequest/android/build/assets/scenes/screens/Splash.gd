# Splash.gd
extends Control

const AUTO_ADVANCE_DELAY := 2.5

@onready var icon_container: PanelContainer = $Center/VBox/IconContainer
@onready var splash_logo:    Label          = $Center/VBox/SplashLogo
@onready var splash_sub:     Label          = $Center/VBox/SplashSub
@onready var splash_dots:    HBoxContainer  = $Center/VBox/SplashDots

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_play_enter_animations()
	await get_tree().create_timer(AUTO_ADVANCE_DELAY).timeout
	_navigate()

func _play_enter_animations() -> void:
	# Container: scale up from 0.7 + fade in
	icon_container.pivot_offset = Vector2(128, 128)
	icon_container.scale = Vector2(0.7, 0.7)
	var t_icon := create_tween().set_parallel(true)
	t_icon.tween_property(icon_container, "modulate:a", 1.0, DesignTokens.ANIM_XSLOW).set_delay(0.1)
	t_icon.tween_property(icon_container, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Logo: slide up + fade in
	var logo_rest_y := splash_logo.position.y
	splash_logo.position.y = logo_rest_y + 40.0
	var t_logo := create_tween().set_parallel(true)
	t_logo.tween_property(splash_logo, "modulate:a", 1.0, 0.5).set_delay(0.2)
	t_logo.tween_property(splash_logo, "position:y", logo_rest_y, 0.6).set_delay(0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# Subtitle: fade in
	var t_sub := create_tween()
	t_sub.tween_interval(0.6)
	t_sub.tween_property(splash_sub, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

	# Dots: fade in
	var t_dots := create_tween()
	t_dots.tween_interval(0.8)
	t_dots.tween_property(splash_dots, "modulate:a", 1.0, DesignTokens.ANIM_FAST * 2.0)

func _navigate() -> void:
	get_tree().change_scene_to_file("res://scenes/screens/WalletPicker.tscn")
