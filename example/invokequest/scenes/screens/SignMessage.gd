# SignMessage.gd
extends Control

@onready var message_input: TextEdit       = $Scroll/VBox/InputCard/CardVBox/MessageInput
@onready var status_label:  Label          = $Scroll/VBox/StatusCard/CardVBox/StatusLabel
@onready var result_label:  Label          = $Scroll/VBox/ResultCard/CardVBox/ResultLabel
@onready var result_card:   PanelContainer = $Scroll/VBox/ResultCard
@onready var sign_btn:      Button         = $Scroll/VBox/SignBtn

var _mwa = null

func _ready() -> void:
	result_card.visible = false
	status_label.text = "Enter a message and sign it"
	status_label.modulate = DesignTokens.COLOR_WHITE_60
	var ts := Time.get_datetime_string_from_system()
	message_input.text = "InvokeQuest SDK Demo -- " + ts
	if Engine.has_singleton("InvokeMWA"):
		_mwa = Engine.get_singleton("InvokeMWA")
		_mwa.message_signed.connect(_on_message_signed)
		_mwa.mwa_error.connect(_on_mwa_error)

func _on_sign_btn_pressed() -> void:
	var msg := message_input.text.strip_edges()
	if msg.is_empty():
		status_label.text = "Message cannot be empty"
		status_label.modulate = DesignTokens.COLOR_RED
		return
	status_label.text = "Waiting for wallet approval..."
	status_label.modulate = DesignTokens.COLOR_YELLOW
	sign_btn.disabled = true
	if _mwa == null:
		await get_tree().create_timer(1.0).timeout
		_show_result("SimulatedSignedBytes_" + msg.substr(0, 8))
		return
	var msg_bytes: PackedByteArray = msg.to_utf8_buffer()
	var addr_bytes := PackedByteArray()
	_mwa.signMessages([msg_bytes.hex_encode()], [addr_bytes.hex_encode()])

func _on_message_signed(signed_messages: Array) -> void:
	var result: String = str(signed_messages[0]) if signed_messages.size() > 0 else "no result"
	_show_result(str(result))

func _on_mwa_error(code: int, message: String) -> void:
	status_label.text = "Error %d: %s" % [code, message]
	status_label.modulate = DesignTokens.COLOR_RED
	sign_btn.disabled = false

func _show_result(signed: String) -> void:
	status_label.text = "Message signed successfully"
	status_label.modulate = DesignTokens.COLOR_GREEN
	sign_btn.disabled = false
	var display := signed
	if signed.length() > 24:
		display = signed.substr(0, 10) + "..." + signed.substr(signed.length() - 10)
		result_label.text = display
		result_card.visible = true
		result_card.modulate.a = 0.0
		var t := create_tween()
		t.tween_property(result_card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

func _on_back_btn_pressed() -> void:
	SceneManager.pop_scene()
