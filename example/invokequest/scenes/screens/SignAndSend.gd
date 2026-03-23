# SignAndSend.gd
extends Control

# SOLSCAN_BASE is now built dynamically from settings
const CONFIG_PATH := "user://invokequest_settings.cfg"
const RPC_ENDPOINTS := [
	"https://api.devnet.solana.com",
	"https://api.testnet.solana.com",
	"https://api.mainnet-beta.solana.com"
]

@onready var status_label: Label          = $Scroll/VBox/StatusCard/CardVBox/StatusLabel
@onready var sig_label:    Label          = $Scroll/VBox/ResultCard/CardVBox/SigLabel
@onready var solscan_btn:  Button         = $Scroll/VBox/ResultCard/CardVBox/SolscanBtn
@onready var result_card:  PanelContainer = $Scroll/VBox/ResultCard
@onready var sign_btn:     Button         = $Scroll/VBox/SignBtn

var _mwa = null
var _full_signature := ""

func _ready() -> void:
	result_card.visible = false
	status_label.text = "Ready to sign and send"
	status_label.modulate = DesignTokens.COLOR_WHITE_60
	if Engine.has_singleton("InvokeMWA"):
		_mwa = Engine.get_singleton("InvokeMWA")
		_mwa.transaction_sent.connect(_on_transaction_sent)
		_mwa.mwa_error.connect(_on_mwa_error)

func _get_rpc_url() -> String:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	var override: String = config.get_value("settings", "rpc_override", "")
	if override.strip_edges() != "":
		return override.strip_edges()
	var network_index: int = config.get_value("settings", "network", 0)
	network_index = clamp(network_index, 0, RPC_ENDPOINTS.size() - 1)
	return RPC_ENDPOINTS[network_index]

func _on_sign_btn_pressed() -> void:
	status_label.text = "Fetching blockhash and waiting for wallet..."
	status_label.modulate = DesignTokens.COLOR_YELLOW
	sign_btn.disabled = true
	if _mwa == null:
		await get_tree().create_timer(1.2).timeout
		var fake_sig := "5J3mBbAH6QkYLRFLsim" + str(Time.get_ticks_msec())
		_show_result(fake_sig)
		return
	var rpc_url := _get_rpc_url()
	_mwa.signAndSendMemoTransaction("InvokeQuest memo tx", rpc_url)

func _on_transaction_sent(signatures: Array) -> void:
	var sig: String = str(signatures[0]) if signatures.size() > 0 else "no signature"
	_show_result(str(sig))

func _on_mwa_error(code: int, message: String) -> void:
	status_label.text = "Error %d: %s" % [code, message]
	status_label.modulate = DesignTokens.COLOR_RED
	sign_btn.disabled = false

func _show_result(sig: String) -> void:
	_full_signature = sig
	status_label.text = "Broadcast successful"
	status_label.modulate = DesignTokens.COLOR_GREEN
	sign_btn.disabled = false
	var display := sig
	if sig.length() > 20:
		display = sig.substr(0, 8) + "..." + sig.substr(sig.length() - 8)
	sig_label.text = display
	result_card.visible = true
	result_card.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(result_card, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

func _get_solscan_url(sig: String) -> String:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	var idx: int = config.get_value("settings", "network", 0)
	idx = clamp(idx, 0, 2)
	var cluster: String = ["devnet", "testnet", ""][idx]
	if cluster == "":
		return "https://solscan.io/tx/%s" % sig
	return "https://solscan.io/tx/%s?cluster=%s" % [sig, cluster]

func _on_solscan_btn_pressed() -> void:
	if _full_signature != "":
		OS.shell_open(_get_solscan_url(_full_signature))

func _on_back_btn_pressed() -> void:
	SceneManager.pop_scene()
