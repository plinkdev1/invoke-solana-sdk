# AuthCache.gd
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
	var address   := "â€”"
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
							age_label.text = "â€”"
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
		log_label.text = "\n".join(_log_lines)

func _on_back_btn_pressed() -> void:
	SceneManager.pop_scene()
