# AuthResult.gd
extends Control

@onready var wallet_label:  Label          = $Center/VBox/Card/CardVBox/WalletLabel
@onready var address_label: Label          = $Center/VBox/Card/CardVBox/AddressLabel
@onready var cache_label:   Label          = $Center/VBox/Card/CardVBox/CacheLabel
@onready var continue_btn:  Button         = $Center/VBox/ContinueBtn
@onready var card:          PanelContainer = $Center/VBox/Card

func _ready() -> void:
	var address := ""
	var from_cache := false
	if Engine.has_singleton("InvokeMWA"):
		var plugin = Engine.get_singleton("InvokeMWA")
		address    = plugin.cacheGetAddress()
		from_cache = plugin.cacheHasToken()
	var display_address := address
	if address.length() > 12:
		display_address = address.substr(0, 4) + "..." + address.substr(address.length() - 4)
	wallet_label.text  = "Connected"
	address_label.text = display_address if display_address != "" else "No address"
	cache_label.text   = "Session cached" if from_cache else "New session"
	cache_label.modulate = DesignTokens.COLOR_GREEN if from_cache else DesignTokens.COLOR_YELLOW
	await get_tree().process_frame
	_play_enter()

func _play_enter() -> void:
	card.modulate.a = 0.0
	card.scale = Vector2(0.95, 0.95)
	var t := create_tween().set_parallel(true)
	t.tween_property(card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)
	t.tween_property(card, "scale", Vector2(1.0, 1.0), DesignTokens.ANIM_SLOW).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_continue_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_DASHBOARD)

func _on_continue_btn_button_down() -> void:
	var t := create_tween()
	t.tween_property(continue_btn, "scale", Vector2(0.97, 0.97), DesignTokens.ANIM_FAST)

func _on_continue_btn_button_up() -> void:
	var t := create_tween()
	t.tween_property(continue_btn, "scale", Vector2(1.0, 1.0), DesignTokens.ANIM_FAST).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
