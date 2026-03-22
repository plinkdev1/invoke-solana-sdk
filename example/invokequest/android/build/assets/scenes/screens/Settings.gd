# Settings.gd
extends Control

const CONFIG_PATH := "user://invokequest_settings.cfg"
const NETWORKS    := ["devnet", "testnet", "mainnet-beta"]
const BACKENDS    := ["Memory", "File", "Secure (Keystore)"]

var _config := ConfigFile.new()
var _mwa = null

@onready var network_opts:  OptionButton = $Scroll/VBox/NetworkCard/CardVBox/NetworkOpts
@onready var backend_opts:  OptionButton = $Scroll/VBox/BackendCard/CardVBox/BackendOpts
@onready var rpc_input:     LineEdit     = $Scroll/VBox/RpcCard/CardVBox/RpcInput
@onready var sdk_ver_label: Label        = $Scroll/VBox/InfoCard/CardVBox/SdkVerRow/ValueLabel
@onready var app_ver_label: Label        = $Scroll/VBox/InfoCard/CardVBox/AppVerRow/ValueLabel

func _ready() -> void:
	if Engine.has_singleton("InvokeMWA"):
		_mwa = Engine.get_singleton("InvokeMWA")
		for n in NETWORKS:
			network_opts.add_item(n)
			for b in BACKENDS:
				backend_opts.add_item(b)
				_config.load(CONFIG_PATH)
				network_opts.selected = _config.get_value("settings", "network", 0)
				backend_opts.selected = _config.get_value("settings", "backend", 1)
				rpc_input.text        = _config.get_value("settings", "rpc_override", "")
				sdk_ver_label.text = "1.0.0"
				app_ver_label.text = "1.0.0"

func _save_settings() -> void:
	_config.set_value("settings", "network",      network_opts.selected)
	_config.set_value("settings", "backend",      backend_opts.selected)
	_config.set_value("settings", "rpc_override", rpc_input.text.strip_edges())
	_config.save(CONFIG_PATH)

func _on_network_opts_item_selected(_index: int) -> void:
	_save_settings()

func _on_backend_opts_item_selected(_index: int) -> void:
	_save_settings()

func _on_rpc_input_text_submitted(_new_text: String) -> void:
	_save_settings()

func _on_danger_btn_pressed() -> void:
	if _mwa:
		_mwa.cacheClearAll()
		_mwa.disconnect_wallet()
		SceneManager.clear_history()
		SceneManager.replace_scene(SceneManager.SCENE_WALLET_PICKER)

func _on_back_btn_pressed() -> void:
	_save_settings()
	SceneManager.pop_scene()
