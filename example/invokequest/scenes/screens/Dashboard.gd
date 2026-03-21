# Dashboard.gd
extends Control

@onready var address_label:  Label     = $Scroll/VBox/BalanceCard/CardVBox/AddressLabel
@onready var balance_label:  Label     = $Scroll/VBox/BalanceCard/CardVBox/BalanceLabel
@onready var network_label:  Label     = $Scroll/VBox/BalanceCard/CardVBox/NetworkLabel
@onready var cache_dot:      ColorRect = $Scroll/VBox/CacheRow/CacheDot
@onready var cache_status:   Label     = $Scroll/VBox/CacheRow/CacheStatus

var _mwa = null
var _address := ""

func _ready() -> void:
	if Engine.has_singleton("InvokeMWA"):
		_mwa = Engine.get_singleton("InvokeMWA")
		_address = _mwa.cacheGetAddress()
		_mwa.mwa_error.connect(_on_mwa_error)
		_populate_address()
		_populate_cache_status()
		_animate_balance_count_up(0.0)
		await get_tree().process_frame
		_play_enter()

func _populate_address() -> void:
	var display := _address
	if _address.length() > 12:
		display = _address.substr(0, 4) + "..." + _address.substr(_address.length() - 4)
		address_label.text = display if display != "" else "Not connected"
		network_label.text = "Devnet"

func _populate_cache_status() -> void:
	var has_token := false
	if _mwa:
		has_token = _mwa.cacheHasToken()
		cache_dot.color   = DesignTokens.COLOR_GREEN if has_token else DesignTokens.COLOR_YELLOW
		cache_status.text = "Session cached" if has_token else "No cached session"
		cache_status.modulate = DesignTokens.COLOR_GREEN if has_token else DesignTokens.COLOR_YELLOW

func _animate_balance_count_up(target: float) -> void:
	var tween := create_tween()
	tween.tween_method(_set_balance_text, 0.0, target, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _set_balance_text(value: float) -> void:
	balance_label.text = "%.4f SOL" % value

func _play_enter() -> void:
	var card := $Scroll/VBox/BalanceCard
	card.scale = Vector2(0.95, 0.95)
	card.modulate.a = 0.0
	var t := create_tween().set_parallel(true)
	t.tween_property(card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)
	t.tween_property(card, "scale", Vector2(1.0, 1.0), DesignTokens.ANIM_SLOW).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var actions := [
	$Scroll/VBox/ActionsGrid/BtnSignTx,
	$Scroll/VBox/ActionsGrid/BtnSignSend,
	$Scroll/VBox/ActionsGrid/BtnSignMsg,
	$Scroll/VBox/ActionsGrid/BtnCaps,
	]
	for i in actions.size():
		var btn: Control = actions[i]
		btn.modulate.a = 0.0
		btn.position.y += 16.0
		var bt := create_tween().set_parallel(true)
		bt.tween_property(btn, "modulate:a", 1.0, DesignTokens.ANIM_NORMAL).set_delay(DesignTokens.ANIM_SLOW + i * DesignTokens.ANIM_STAGGER_ACTION)
		bt.tween_property(btn, "position:y", btn.position.y - 16.0, DesignTokens.ANIM_NORMAL).set_delay(DesignTokens.ANIM_SLOW + i * DesignTokens.ANIM_STAGGER_ACTION)

func _on_mwa_error(code: int, message: String) -> void:
	print("Dashboard MWA error %d: %s" % [code, message])

func _on_btn_sign_tx_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_SIGN_TX)

func _on_btn_sign_send_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_SIGN_AND_SEND)

func _on_btn_sign_msg_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_SIGN_MESSAGE)

func _on_btn_caps_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_CAPABILITIES)

func _on_cache_btn_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_AUTH_CACHE)

func _on_settings_pressed() -> void:
	SceneManager.push_scene(SceneManager.SCENE_SETTINGS)

func _on_disconnect_btn_pressed() -> void:
	if _mwa:
		_mwa.disconnect_wallet()
		SceneManager.clear_history()
		SceneManager.replace_scene(SceneManager.SCENE_WALLET_PICKER)
