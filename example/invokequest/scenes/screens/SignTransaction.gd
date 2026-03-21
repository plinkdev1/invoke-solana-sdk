# SignTransaction.gd
# Demonstrates sign_transactions() -- builds a dummy tx, signs it, shows result.
# Reference: SOLANAQUEST_ASSET_MAP.md Section 6E.

extends Control

@onready var status_label:  Label  = $Scroll/VBox/StatusCard/CardVBox/StatusLabel
@onready var hash_label:    Label  = $Scroll/VBox/ResultCard/CardVBox/HashLabel
@onready var result_card:   PanelContainer = $Scroll/VBox/ResultCard
@onready var sign_btn:      Button = $Scroll/VBox/SignBtn
@onready var back_btn:      Button = $Scroll/VBox/BackBtn

var _mwa = null

func _ready() -> void:
result_card.visible = false
status_label.text = "Ready to sign"
status_label.modulate = DesignTokens.COLOR_WHITE_60

if Engine.has_singleton("InvokeMWA"):
_mwa = Engine.get_singleton("InvokeMWA")
_mwa.transaction_signed.connect(_on_transaction_signed)
_mwa.mwa_error.connect(_on_mwa_error)

func _on_sign_btn_pressed() -> void:
status_label.text = "Waiting for wallet approval..."
status_label.modulate = DesignTokens.COLOR_YELLOW
sign_btn.disabled = true

if _mwa == null:
# Desktop simulation
await get_tree().create_timer(1.2).timeout
_show_result("SimulatedSignedTxBytes_" + str(Time.get_ticks_msec()))
return

# Build a minimal dummy transaction (32 zero bytes = placeholder)
# In a real app this would be a properly serialized Solana transaction
var dummy_tx := PackedByteArray()
dummy_tx.resize(32)
dummy_tx.fill(0)
_mwa.signTransactions([dummy_tx.hex_encode()])

func _on_transaction_signed(signatures: Array) -> void:
var sig := signatures[0] if signatures.size() > 0 else "no signature"
_show_result(str(sig))

func _on_mwa_error(code: int, message: String) -> void:
status_label.text = "Error %d: %s" % [code, message]
status_label.modulate = DesignTokens.COLOR_RED
sign_btn.disabled = false

func _show_result(sig: String) -> void:
status_label.text = "Signed successfully"
status_label.modulate = DesignTokens.COLOR_GREEN
sign_btn.disabled = false

# Truncate for display
var display := sig
if sig.length() > 20:
display = sig.substr(0, 8) + "..." + sig.substr(sig.length() - 8)
hash_label.text = display

result_card.visible = true
result_card.modulate.a = 0.0
var t := create_tween()
t.tween_property(result_card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

func _on_back_btn_pressed() -> void:
SceneManager.pop_scene()
