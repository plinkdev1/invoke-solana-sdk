# Capabilities.gd
# Demonstrates get_capabilities() -- fetches and displays wallet feature support.
# Reference: SOLANAQUEST_ASSET_MAP.md Section 6.

extends Control

@onready var status_label:   Label  = $Scroll/VBox/StatusLabel
@onready var result_card:    PanelContainer = $Scroll/VBox/ResultCard
@onready var clone_label:    Label  = $Scroll/VBox/ResultCard/CardVBox/CloneRow/ValueLabel
@onready var signsend_label: Label  = $Scroll/VBox/ResultCard/CardVBox/SignSendRow/ValueLabel
@onready var max_tx_label:   Label  = $Scroll/VBox/ResultCard/CardVBox/MaxTxRow/ValueLabel
@onready var max_msg_label:  Label  = $Scroll/VBox/ResultCard/CardVBox/MaxMsgRow/ValueLabel
@onready var fetch_btn:      Button = $Scroll/VBox/FetchBtn

var _mwa = null

func _ready() -> void:
result_card.visible = false
status_label.text = "Tap to fetch wallet capabilities"
status_label.modulate = DesignTokens.COLOR_WHITE_60

if Engine.has_singleton("InvokeMWA"):
_mwa = Engine.get_singleton("InvokeMWA")
_mwa.capabilities_received.connect(_on_capabilities_received)
_mwa.mwa_error.connect(_on_mwa_error)

func _on_fetch_btn_pressed() -> void:
status_label.text = "Fetching capabilities..."
status_label.modulate = DesignTokens.COLOR_YELLOW
fetch_btn.disabled = true

if _mwa == null:
# Desktop simulation
await get_tree().create_timer(0.8).timeout
var fake := '{"supports_clone_authorization":true,"supports_sign_and_send_transactions":true,"max_transactions_per_request":10,"max_messages_per_request":10}'
_on_capabilities_received(fake)
return

_mwa.getCapabilities()

func _on_capabilities_received(json_str: String) -> void:
fetch_btn.disabled = false
status_label.text = "Capabilities loaded"
status_label.modulate = DesignTokens.COLOR_GREEN

var parsed: Variant = JSON.parse_string(json_str)
if parsed == null or not parsed is Dictionary:
status_label.text = "Failed to parse capabilities"
status_label.modulate = DesignTokens.COLOR_RED
return

var caps: Dictionary = parsed
clone_label.text    = _bool_str(caps.get("supports_clone_authorization", false))
signsend_label.text = _bool_str(caps.get("supports_sign_and_send_transactions", false))
max_tx_label.text   = str(caps.get("max_transactions_per_request", "—"))
max_msg_label.text  = str(caps.get("max_messages_per_request", "—"))

_color_bool(clone_label,    caps.get("supports_clone_authorization", false))
_color_bool(signsend_label, caps.get("supports_sign_and_send_transactions", false))

result_card.visible = true
result_card.modulate.a = 0.0
var t := create_tween()
t.tween_property(result_card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

func _on_mwa_error(code: int, message: String) -> void:
status_label.text = "Error %d: %s" % [code, message]
status_label.modulate = DesignTokens.COLOR_RED
fetch_btn.disabled = false

func _bool_str(val: bool) -> String:
return "Supported" if val else "Not Supported"

func _color_bool(label: Label, val: bool) -> void:
label.modulate = DesignTokens.COLOR_GREEN if val else DesignTokens.COLOR_RED

func _on_back_btn_pressed() -> void:
SceneManager.pop_scene()
