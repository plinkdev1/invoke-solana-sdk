extends Control

var _mwa = null

@onready var btn_connect: Button      = $BtnConnect
@onready var loading_overlay: Control = $LoadingOverlay
@onready var status_label: Label      = $LoadingOverlay/StatusLabel

func _ready() -> void:
	loading_overlay.visible = false
	btn_connect.modulate.a = 0.0
	if Engine.has_singleton("InvokeMWA"):
		_mwa = Engine.get_singleton("InvokeMWA")
		_mwa.authorized.connect(_on_authorized)
		_mwa.mwa_error.connect(_on_mwa_error)
	await get_tree().process_frame
	_fade_in_button()

func _fade_in_button() -> void:
	var t := create_tween()
	t.tween_property(btn_connect, "modulate:a", 1.0, DesignTokens.ANIM_NORMAL)

func _on_connect_pressed() -> void:
	_show_loading("Opening wallet picker...")
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
