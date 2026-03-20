# MWACacheManager.gd
# Invoke SDK — Cache backend selector and manager singleton
# Auto-detects the best available backend for the current platform
# Reference: docs/AUTH_CACHE_RESEARCH.md Section 5

class_name MWACacheManager
extends RefCounted

# ─── Backend Enum ────────────────────────────────────────────────────────────

enum Backend {
    MEMORY,   # In-memory — dev/testing only, lost on restart
    FILE,     # File-based — default, survives restart, not encrypted
    SECURE    # Android Keystore — production, encrypted at rest
}

# ─── State ───────────────────────────────────────────────────────────────────

var _cache  : MWAAuthCache = null
var _backend: Backend      = Backend.FILE

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init(backend: Backend = Backend.FILE) -> void:
    set_backend(backend)

# ─── Backend Selection ───────────────────────────────────────────────────────

func set_backend(backend: Backend) -> void:
    _backend = backend
    match backend:
        Backend.MEMORY:
            _cache = MWAMemoryCache.new()
        Backend.SECURE:
            _cache = MWASecureCache.new()
        _:
            _cache = MWAFileCache.new()

# Auto-select best backend for current platform
static func create_best() -> MWACacheManager:
    if OS.get_name() == "Android":
        return MWACacheManager.new(Backend.SECURE)
    return MWACacheManager.new(Backend.FILE)

func get_backend() -> Backend:
    return _backend

func get_backend_name() -> String:
    match _backend:
        Backend.MEMORY: return "Memory"
        Backend.SECURE: return "Secure (Android Keystore)"
        _:              return "File"

# ─── Cache Delegation ────────────────────────────────────────────────────────

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    return _cache.save_auth_token(key, token)

func load_auth_token(key: String) -> MWAAuthToken:
    return _cache.load_auth_token(key)

func clear_auth_token(key: String) -> bool:
    return _cache.clear_auth_token(key)

func clear_all() -> bool:
    return _cache.clear_all()

func has_valid_token(key: String) -> bool:
    return _cache.has_valid_token(key)

func has_fresh_token(key: String) -> bool:
    return _cache.has_fresh_token(key)

func has_reauthorizable_token(key: String) -> bool:
    return _cache.has_reauthorizable_token(key)

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWACacheManager(backend=%s)" % get_backend_name()
