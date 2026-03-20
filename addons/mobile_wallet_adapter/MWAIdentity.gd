# MWAIdentity.gd
# Invoke SDK — App identity passed to authorize() and reauthorize()
# Tells the wallet which app is requesting authorization

class_name MWAIdentity
extends RefCounted

# ─── Fields ──────────────────────────────────────────────────────────────────

var name: String        # Display name shown in wallet UI (e.g. "InvokeQuest")
var uri: String         # App URI (e.g. "https://invokequest.dev")
var icon: String        # Relative icon URI (e.g. "favicon.ico")

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init(p_name: String = "", p_uri: String = "", p_icon: String = "") -> void:
    name = p_name
    uri  = p_uri
    icon = p_icon

# ─── Validation ──────────────────────────────────────────────────────────────

func is_valid() -> bool:
    if name.is_empty():
        push_error("MWAIdentity: 'name' is required.")
        return false
    if uri.is_empty():
        push_error("MWAIdentity: 'uri' is required.")
        return false
    if not uri.begins_with("https://") and not uri.begins_with("http://"):
        push_error("MWAIdentity: 'uri' must begin with http:// or https://")
        return false
    return true

# ─── Serialization ───────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
    return {
        "name": name,
        "uri":  uri,
        "icon": icon
    }

static func from_dict(data: Dictionary) -> MWAIdentity:
    return MWAIdentity.new(
        data.get("name", ""),
        data.get("uri",  ""),
        data.get("icon", "")
    )

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWAIdentity(name=%s, uri=%s, icon=%s)" % [name, uri, icon]
