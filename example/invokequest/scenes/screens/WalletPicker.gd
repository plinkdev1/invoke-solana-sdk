# WalletPicker.gd
extends Control

const WALLETS := [
{ "name": "Phantom",  "package": "app.phantom",        "label": "Most Popular" },
{ "name": "Backpack", "package": "com.backpack.wallet", "label": "xNFT Wallet" },
{ "name": "Solflare", "package": "com.solflare.mobile", "label": "DeFi Focused" },
{ "name": "Jupiter",  "package": "ag.jup.jupiter.android", "label": "DEX Aggregator" },
]

var _mwa = null
var _selected_wallet: String = ""

@onready var card_phantom:  PanelContainer = $Scroll/VBox/CardPhantom
@onready var card_backpack: PanelContainer = $Scroll/VBox/CardBackpack
@onready var card_solflare: PanelContainer = $Scroll/VBox/CardSolflare
@onready var card_jupiter:  PanelContainer = $Scroll/VBox/CardJupiter
@onready var loading_overlay: Control      = $LoadingOverlay
@onready var status_label: Label           = $LoadingOverlay/StatusLabel

func _ready() -> void:
	loading_overlay.visible = false
	if Engine.has_singleton("InvokeMWA"):
		_mwa = Engine.get_singleton("InvokeMWA")
		_mwa.authorized.connect(_on_authorized)
		_mwa.mwa_error.connect(_on_mwa_error)
		await get_tree().process_frame
		_play_stagger_in()

func _play_stagger_in() -> void:
	var cards := [card_phantom, card_backpack, card_solflare, card_jupiter]
	for i in cards.size():
		var card: Control = cards[i]
		var rest_y := card.position.y
		card.position.y = rest_y + 20.0
		card.modulate.a = 0.0
		var t := create_tween().set_parallel(true)
		t.tween_property(card, "modulate:a", 1.0, DesignTokens.ANIM_NORMAL).set_delay(i * DesignTokens.ANIM_STAGGER_WALLET)
		t.tween_property(card, "position:y", rest_y, DesignTokens.ANIM_SLOW).set_delay(i * DesignTokens.ANIM_STAGGER_WALLET).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_card_pressed(wallet_index: int) -> void:
	var wallet: Dictionary = WALLETS[wallet_index]
	_selected_wallet = wallet.package
	_show_loading("Waiting for " + wallet.name + "...")
	if _mwa == null:
		await get_tree().create_timer(1.0).timeout
		SceneManager.push_scene(SceneManager.SCENE_AUTH_RESULT)
		return
	_mwa.authorize("devnet", "InvokeQuest", "https://invoke.dev", "https://invoke.dev/icon.png")

func _on_authorized(_auth_token: String, _address: String) -> void:
	_hide_loading()
	SceneManager.push_scene(SceneManager.SCENE_AUTH_RESULT)

func _on_mwa_error(code: int, message: String) -> void:
	_hide_loading()
	status_label.text = "Error " + str(code) + ": " + message

func _show_loading(msg: String) -> void:
	status_label.text = msg
	loading_overlay.visible = true

func _hide_loading() -> void:
	loading_overlay.visible = false
