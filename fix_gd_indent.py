import os

base = r"C:\PROJECTS\Invoke_Solana_App\example\invokequest"

files = {

"autoloads/DesignTokens.gd": '''# DesignTokens.gd
# Autoload singleton -- all design constants for InvokeQuest.
extends Node

const COLOR_BG           = Color(0.031, 0.039, 0.055, 1.0)
const COLOR_SURFACE      = Color(1.0,   1.0,   1.0,   0.05)
const COLOR_SURFACE_2    = Color(1.0,   1.0,   1.0,   0.08)
const COLOR_GLASS_BORDER = Color(1.0,   1.0,   1.0,   0.10)
const COLOR_PURPLE       = Color(0.600, 0.271, 1.000, 1.0)
const COLOR_PURPLE_DIM   = Color(0.600, 0.271, 1.000, 0.15)
const COLOR_GREEN        = Color(0.078, 0.945, 0.596, 1.0)
const COLOR_GREEN_DIM    = Color(0.078, 0.945, 0.596, 0.12)
const COLOR_YELLOW       = Color(1.000, 0.725, 0.220, 1.0)
const COLOR_RED          = Color(1.000, 0.310, 0.310, 1.0)
const COLOR_WHITE        = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_WHITE_60     = Color(1.0, 1.0, 1.0, 0.6)
const COLOR_WHITE_30     = Color(1.0, 1.0, 1.0, 0.3)
const COLOR_WHITE_10     = Color(1.0, 1.0, 1.0, 0.1)

const FONT_SIZE_XL  = 36
const FONT_SIZE_LG  = 24
const FONT_SIZE_MD  = 18
const FONT_SIZE_SM  = 14
const FONT_SIZE_XS  = 12
const FONT_SIZE_XXS = 10

const SPACE_XS  =  4
const SPACE_SM  =  8
const SPACE_MD  = 16
const SPACE_LG  = 24
const SPACE_XL  = 32
const SPACE_XXL = 48

const RADIUS_SM   = 8
const RADIUS_MD   = 16
const RADIUS_LG   = 24
const RADIUS_PILL = 999

const ANIM_FAST    = 0.15
const ANIM_NORMAL  = 0.25
const ANIM_SLOW    = 0.35
const ANIM_XSLOW   = 0.60

const ANIM_STAGGER_WALLET = 0.08
const ANIM_STAGGER_ACTION = 0.05
const ANIM_STAGGER_TX     = 0.04

const ANIM_SCREEN_PUSH = 0.25
const ANIM_SCREEN_FADE = 0.30

const GLASS_BLUR_STRENGTH = 3.0
const GLASS_TINT_ALPHA    = 0.06
const GLASS_BORDER_ALPHA  = 0.10
const AURORA_TIME_SCALE   = 0.3
const GLOW_PULSE_SPEED    = 1.5

const Z_BACKGROUND   = -10
const Z_CONTENT      =   0
const Z_OVERLAY      =  10
const Z_BOTTOM_SHEET =  20
const Z_LOADING      =  30
const Z_TOAST        =  40
''',

"autoloads/SceneManager.gd": '''# SceneManager.gd
# Autoload singleton -- handles all screen navigation for InvokeQuest.
extends Node

const SCENE_SPLASH        = "res://scenes/screens/Splash.tscn"
const SCENE_WALLET_PICKER = "res://scenes/screens/WalletPicker.tscn"
const SCENE_AUTH_RESULT   = "res://scenes/screens/AuthResult.tscn"
const SCENE_DASHBOARD     = "res://scenes/screens/Dashboard.tscn"
const SCENE_SIGN_TX       = "res://scenes/screens/SignTransaction.tscn"
const SCENE_SIGN_AND_SEND = "res://scenes/screens/SignAndSend.tscn"
const SCENE_SIGN_MESSAGE  = "res://scenes/screens/SignMessage.tscn"
const SCENE_CAPABILITIES  = "res://scenes/screens/Capabilities.tscn"
const SCENE_AUTH_CACHE    = "res://scenes/screens/AuthCache.tscn"
const SCENE_SETTINGS      = "res://scenes/screens/Settings.tscn"

var _history: Array[String] = []
var _is_transitioning: bool = false

func push_scene(path: String) -> void:
if _is_transitioning:
return
_is_transitioning = true
_history.push_back(get_tree().current_scene.scene_file_path)
await _fade_out()
get_tree().change_scene_to_file(path)
await get_tree().process_frame
await _fade_in()
_is_transitioning = false

func pop_scene() -> void:
if _is_transitioning or _history.is_empty():
return
_is_transitioning = true
var previous: String = _history.pop_back()
await _fade_out()
get_tree().change_scene_to_file(previous)
await get_tree().process_frame
await _fade_in()
_is_transitioning = false

func replace_scene(path: String) -> void:
if _is_transitioning:
return
_is_transitioning = true
await _fade_out()
get_tree().change_scene_to_file(path)
await get_tree().process_frame
await _fade_in()
_is_transitioning = false

func clear_history() -> void:
_history.clear()

func can_pop() -> bool:
return not _history.is_empty()

func _fade_out() -> void:
var tree := get_tree()
if not tree:
return
var overlay := _get_or_create_overlay(tree.root)
var tween := create_tween()
tween.tween_property(overlay, "modulate:a", 1.0, DesignTokens.ANIM_SCREEN_FADE)
await tween.finished

func _fade_in() -> void:
var tree := get_tree()
if not tree:
return
var overlay := _get_or_create_overlay(tree.root)
var tween := create_tween()
tween.tween_property(overlay, "modulate:a", 0.0, DesignTokens.ANIM_SCREEN_FADE)
await tween.finished

func _get_or_create_overlay(root: Window) -> ColorRect:
var existing := root.get_node_or_null("SceneTransitionOverlay")
if existing:
return existing as ColorRect
var overlay := ColorRect.new()
overlay.name = "SceneTransitionOverlay"
overlay.color = DesignTokens.COLOR_BG
overlay.modulate.a = 0.0
overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
overlay.z_index = DesignTokens.Z_LOADING
overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
root.add_child(overlay)
return overlay
''',

"scenes/screens/Splash.gd": '''# Splash.gd
extends Control

const AUTO_ADVANCE_DELAY := 2.5

@onready var splash_icon: TextureRect   = $Center/VBox/SplashIcon
@onready var splash_logo: Label         = $Center/VBox/SplashLogo
@onready var splash_sub:  Label         = $Center/VBox/SplashSub
@onready var splash_dots: HBoxContainer = $Center/VBox/SplashDots

func _ready() -> void:
await get_tree().process_frame
await get_tree().process_frame
_play_enter_animations()
await get_tree().create_timer(AUTO_ADVANCE_DELAY).timeout
_navigate()

func _play_enter_animations() -> void:
var t_icon := create_tween().set_parallel(true)
t_icon.tween_property(splash_icon, "modulate:a", 1.0, DesignTokens.ANIM_XSLOW).set_delay(0.1)
t_icon.tween_property(splash_icon, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

var logo_rest_y := splash_logo.position.y
splash_logo.position.y = logo_rest_y + 40.0
var t_logo := create_tween().set_parallel(true)
t_logo.tween_property(splash_logo, "modulate:a", 1.0, 0.5).set_delay(0.2)
t_logo.tween_property(splash_logo, "position:y", logo_rest_y, 0.6).set_delay(0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

var t_sub := create_tween()
t_sub.tween_interval(0.6)
t_sub.tween_property(splash_sub, "modulate:a", 1.0, DesignTokens.ANIM_SLOW)

var t_dots := create_tween()
t_dots.tween_interval(0.8)
t_dots.tween_property(splash_dots, "modulate:a", 1.0, DesignTokens.ANIM_FAST * 2.0)

func _navigate() -> void:
if Engine.has_singleton("InvokeMWA"):
var plugin = Engine.get_singleton("InvokeMWA")
if plugin.cacheHasToken():
SceneManager.replace_scene(SceneManager.SCENE_DASHBOARD)
return
SceneManager.replace_scene(SceneManager.SCENE_WALLET_PICKER)
''',

"scenes/screens/WalletPicker.gd": '''# WalletPicker.gd
extends Control

const WALLETS := [
{ "name": "Phantom",  "package": "app.phantom",        "label": "Most Popular" },
{ "name": "Backpack", "package": "com.backpack.wallet", "label": "xNFT Wallet" },
{ "name": "Solflare", "package": "com.solflare.mobile", "label": "DeFi Focused" },
]

var _mwa = null
var _selected_wallet: String = ""

@onready var card_phantom:  PanelContainer = $Scroll/VBox/CardPhantom
@onready var card_backpack: PanelContainer = $Scroll/VBox/CardBackpack
@onready var card_solflare: PanelContainer = $Scroll/VBox/CardSolflare
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
var cards := [card_phantom, card_backpack, card_solflare]
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
''',

"scenes/screens/AuthResult.gd": '''# AuthResult.gd
extends Control

@onready var wallet_label:  Label          = $Center/VBox/WalletLabel
@onready var address_label: Label          = $Center/VBox/AddressLabel
@onready var cache_label:   Label          = $Center/VBox/CacheLabel
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
''',

"scenes/screens/Dashboard.gd": '''# Dashboard.gd
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
''',

"scenes/screens/SignTransaction.gd": '''# SignTransaction.gd
extends Control

@onready var status_label: Label          = $Scroll/VBox/StatusCard/CardVBox/StatusLabel
@onready var hash_label:   Label          = $Scroll/VBox/ResultCard/CardVBox/HashLabel
@onready var result_card:  PanelContainer = $Scroll/VBox/ResultCard
@onready var sign_btn:     Button         = $Scroll/VBox/SignBtn

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
await get_tree().create_timer(1.2).timeout
_show_result("SimulatedSignedTxBytes_" + str(Time.get_ticks_msec()))
return
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
''',

"scenes/screens/SignAndSend.gd": '''# SignAndSend.gd
extends Control

const SOLSCAN_BASE := "https://solscan.io/tx/%s?cluster=devnet"

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

func _on_sign_btn_pressed() -> void:
status_label.text = "Waiting for wallet approval..."
status_label.modulate = DesignTokens.COLOR_YELLOW
sign_btn.disabled = true
if _mwa == null:
await get_tree().create_timer(1.2).timeout
var fake_sig := "5J3mBbAH6QkYLRFLsim" + str(Time.get_ticks_msec())
_show_result(fake_sig)
return
var dummy_tx := PackedByteArray()
dummy_tx.resize(32)
dummy_tx.fill(0)
_mwa.signAndSendTransactions([dummy_tx.hex_encode()])

func _on_transaction_sent(signatures: Array) -> void:
var sig := signatures[0] if signatures.size() > 0 else "no signature"
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

func _on_solscan_btn_pressed() -> void:
if _full_signature != "":
OS.shell_open(SOLSCAN_BASE % _full_signature)

func _on_back_btn_pressed() -> void:
SceneManager.pop_scene()
''',

"scenes/screens/SignMessage.gd": '''# SignMessage.gd
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
var result := signed_messages[0] if signed_messages.size() > 0 else "no result"
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
''',

"scenes/screens/Capabilities.gd": '''# Capabilities.gd
extends Control

@onready var status_label:   Label          = $Scroll/VBox/StatusLabel
@onready var result_card:    PanelContainer = $Scroll/VBox/ResultCard
@onready var clone_label:    Label          = $Scroll/VBox/ResultCard/CardVBox/CloneRow/ValueLabel
@onready var signsend_label: Label          = $Scroll/VBox/ResultCard/CardVBox/SignSendRow/ValueLabel
@onready var max_tx_label:   Label          = $Scroll/VBox/ResultCard/CardVBox/MaxTxRow/ValueLabel
@onready var max_msg_label:  Label          = $Scroll/VBox/ResultCard/CardVBox/MaxMsgRow/ValueLabel
@onready var fetch_btn:      Button         = $Scroll/VBox/FetchBtn

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
await get_tree().create_timer(0.8).timeout
var fake := \'{"supports_clone_authorization":true,"supports_sign_and_send_transactions":true,"max_transactions_per_request":10,"max_messages_per_request":10}\'
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
''',

"scenes/screens/AuthCache.gd": '''# AuthCache.gd
extends Control

@onready var status_dot:    ColorRect      = $Scroll/VBox/StatusRow/StatusDot
@onready var status_label:  Label          = $Scroll/VBox/StatusRow/StatusLabel
@onready var address_label: Label          = $Scroll/VBox/InfoCard/CardVBox/AddressRow/ValueLabel
@onready var age_label:     Label          = $Scroll/VBox/InfoCard/CardVBox/AgeRow/ValueLabel
@onready var stale_label:   Label          = $Scroll/VBox/InfoCard/CardVBox/StaleRow/ValueLabel
@onready var info_card:     PanelContainer = $Scroll/VBox/InfoCard
@onready var reconnect_btn: Button         = $Scroll/VBox/ReconnectBtn
@onready var log_label:     Label          = $Scroll/VBox/LogCard/CardVBox/LogLabel

var _mwa = null
var _log_lines: Array[String] = []

func _ready() -> void:
if Engine.has_singleton("InvokeMWA"):
_mwa = Engine.get_singleton("InvokeMWA")
_mwa.authorized.connect(_on_authorized)
_mwa.mwa_error.connect(_on_mwa_error)
_refresh_status()

func _refresh_status() -> void:
var has_token := false
var address   := "—"
var age_sec   := 0
var is_stale  := false
if _mwa:
has_token = _mwa.cacheHasToken()
address   = _mwa.cacheGetAddress()
age_sec   = int(_mwa.cacheGetAgeSeconds())
is_stale  = _mwa.cacheIsStale()
if has_token:
status_dot.color  = DesignTokens.COLOR_GREEN
status_label.text = "Token cached"
status_label.modulate = DesignTokens.COLOR_GREEN
else:
status_dot.color  = DesignTokens.COLOR_RED
status_label.text = "No cached token"
status_label.modulate = DesignTokens.COLOR_RED
var display_addr := address
if address.length() > 12:
display_addr = address.substr(0, 4) + "..." + address.substr(address.length() - 4)
address_label.text = display_addr
if age_sec > 0:
age_label.text = "%d min %d sec" % [age_sec / 60, age_sec % 60]
else:
age_label.text = "—"
stale_label.text = "Yes" if is_stale else "No"
stale_label.modulate = DesignTokens.COLOR_YELLOW if is_stale else DesignTokens.COLOR_GREEN
_add_log("Status refreshed -- token: %s" % str(has_token))

func _on_clear_btn_pressed() -> void:
if _mwa:
_mwa.cacheClearAll()
_add_log("Cache cleared")
else:
_add_log("[sim] Cache cleared")
_refresh_status()
var tween := create_tween()
for i in 4:
tween.tween_property(info_card, "position:x", randf_range(-6, 6), 0.05)
tween.tween_property(info_card, "position:x", 0.0, 0.05)

func _on_reconnect_btn_pressed() -> void:
_add_log("Attempting reauthorize...")
reconnect_btn.disabled = true
if _mwa == null:
await get_tree().create_timer(1.0).timeout
_add_log("[sim] Reauthorize success")
reconnect_btn.disabled = false
_refresh_status()
return
_mwa.authorize("devnet", "InvokeQuest", "https://invoke.dev", "https://invoke.dev/icon.png")

func _on_authorized(_auth_token: String, _address: String) -> void:
_add_log("Reauthorize success")
reconnect_btn.disabled = false
_refresh_status()

func _on_mwa_error(code: int, message: String) -> void:
_add_log("Error %d: %s" % [code, message])
reconnect_btn.disabled = false

func _on_refresh_btn_pressed() -> void:
_refresh_status()

func _add_log(line: String) -> void:
var ts := Time.get_time_string_from_system()
_log_lines.append("[%s] %s" % [ts, line])
if _log_lines.size() > 8:
_log_lines = _log_lines.slice(_log_lines.size() - 8)
log_label.text = "\\n".join(_log_lines)

func _on_back_btn_pressed() -> void:
SceneManager.pop_scene()
''',

"scenes/screens/Settings.gd": '''# Settings.gd
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
''',

}

for rel_path, content in files.items():
    full_path = os.path.join(base, rel_path.replace("/", os.sep))
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)
    print(f"Written: {rel_path}")

print("All .gd files fixed.")
