# MWAFileCache.gd
# Invoke SDK — File-based auth token cache (default backend)
# Stores tokens as JSON in Godot's user:// directory
# Survives app restarts. NOT encrypted — use MWASecureCache for production.
# Reference: docs/AUTH_CACHE_RESEARCH.md Section 2.2

class_name MWAFileCache
extends MWAAuthCache

# ─── Constants ───────────────────────────────────────────────────────────────

const CACHE_DIR  : String = "user://mwa_auth/"
const CACHE_FILE : String = "user://mwa_auth/tokens.dat"

# ─── Interface Implementation ────────────────────────────────────────────────

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    if key.is_empty() or token == null:
        return false
    _ensure_dir()
    var cache = _load_raw()
    cache[key] = token.to_dict()
    return _save_raw(cache)

func load_auth_token(key: String) -> MWAAuthToken:
    var cache = _load_raw()
    if not cache.has(key):
        return null
    var token = MWAAuthToken.from_dict(cache[key])
    if token == null or not token.is_valid():
        clear_auth_token(key)
        return null
    return token

func clear_auth_token(key: String) -> bool:
    var cache = _load_raw()
    if cache.has(key):
        cache.erase(key)
        return _save_raw(cache)
    return true

func clear_all() -> bool:
    if FileAccess.file_exists(CACHE_FILE):
        return _save_raw({})
    return true

# ─── Private Helpers ─────────────────────────────────────────────────────────

func _ensure_dir() -> void:
    if not DirAccess.dir_exists_absolute(CACHE_DIR):
        DirAccess.make_dir_recursive_absolute(CACHE_DIR)

func _load_raw() -> Dictionary:
    if not FileAccess.file_exists(CACHE_FILE):
        return {}
    var file = FileAccess.open(CACHE_FILE, FileAccess.READ)
    if file == null:
        return {}
    var content = file.get_as_text()
    file.close()
    if content.is_empty():
        return {}
    var parsed = JSON.parse_string(content)
    if parsed == null or not parsed is Dictionary:
        return {}
    return parsed

func _save_raw(data: Dictionary) -> bool:
    _ensure_dir()
    var file = FileAccess.open(CACHE_FILE, FileAccess.WRITE)
    if file == null:
        push_error("MWAFileCache: failed to open cache file for writing.")
        return false
    file.store_string(JSON.stringify(data))
    file.close()
    return true

# ─── Extras ──────────────────────────────────────────────────────────────────

func get_cache_path() -> String:
    return CACHE_FILE

func cache_file_exists() -> bool:
    return FileAccess.file_exists(CACHE_FILE)

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWAFileCache(path=%s, exists=%s)" % [
        CACHE_FILE, str(cache_file_exists())
    ]
