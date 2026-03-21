# SceneManager.gd
# Autoload singleton -- handles all screen navigation for InvokeQuest.
# Reference: SOLANAQUEST_ASSET_MAP.md Section 6A (screen transitions).
#
# Usage:
#   SceneManager.push_scene("res://scenes/screens/Dashboard.tscn")
#   SceneManager.pop_scene()
#   SceneManager.replace_scene("res://scenes/screens/Splash.tscn")

extends Node

# ---------------------------------------------------------------------------
# SCENE PATHS -- canonical references, never hardcode paths in screen scripts
# ---------------------------------------------------------------------------

const SCENE_SPLASH          = "res://scenes/screens/Splash.tscn"
const SCENE_WALLET_PICKER   = "res://scenes/screens/WalletPicker.tscn"
const SCENE_AUTH_RESULT     = "res://scenes/screens/AuthResult.tscn"
const SCENE_DASHBOARD       = "res://scenes/screens/Dashboard.tscn"
const SCENE_SIGN_TX         = "res://scenes/screens/SignTransaction.tscn"
const SCENE_SIGN_AND_SEND   = "res://scenes/screens/SignAndSend.tscn"
const SCENE_SIGN_MESSAGE    = "res://scenes/screens/SignMessage.tscn"
const SCENE_CAPABILITIES    = "res://scenes/screens/Capabilities.tscn"
const SCENE_AUTH_CACHE      = "res://scenes/screens/AuthCache.tscn"
const SCENE_SETTINGS        = "res://scenes/screens/Settings.tscn"

# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------

var _history: Array[String] = []
var _is_transitioning: bool = false

# ---------------------------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------------------------

## Push a new scene onto the stack. Plays slide-left transition.
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

## Pop back to the previous scene. Plays slide-right transition.
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

## Replace current scene with no history entry. Plays fade transition.
## Use for: Splash -> WalletPicker, auth success -> Dashboard.
func replace_scene(path: String) -> void:
if _is_transitioning:
return
_is_transitioning = true
await _fade_out()
get_tree().change_scene_to_file(path)
await get_tree().process_frame
await _fade_in()
_is_transitioning = false

## Clear navigation history (use after full logout -> back to Splash).
func clear_history() -> void:
_history.clear()

## Returns true if there is a scene to pop back to.
func can_pop() -> bool:
return not _history.is_empty()

# ---------------------------------------------------------------------------
# TRANSITIONS -- simple tween-based fade
# Screens handle their own enter animations internally.
# SceneManager only manages the cross-scene fade overlay.
# ---------------------------------------------------------------------------

func _fade_out() -> void:
var tree := get_tree()
if not tree:
return
var root := tree.root
var overlay := _get_or_create_overlay(root)
var tween := create_tween()
tween.tween_property(overlay, "modulate:a", 1.0, DesignTokens.ANIM_SCREEN_FADE)
await tween.finished

func _fade_in() -> void:
var tree := get_tree()
if not tree:
return
var root := tree.root
var overlay := _get_or_create_overlay(root)
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
