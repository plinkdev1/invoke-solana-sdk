# MWASecureCache.gd
# Invoke SDK — Secure auth token cache via Android Keystore (production)
# Delegates storage to AuthCacheImpl.kt via the Kotlin plugin
# Falls back to MWAFileCache on non-Android platforms
# Reference: docs/AUTH_CACHE_RESEARCH.md Section 2.3

class_name MWASecureCache
extends MWAAuthCache

# ─── Internal ────────────────────────────────────────────────────────────────

var _plugin  : Object       = null
var _fallback: MWAFileCache = null
const PLUGIN_NAME = "InvokeMWA"

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init() -> void:
    if Engine.has_singleton(PLUGIN_NAME):
        _plugin = Engine.get_singleton(PLUGIN_NAME)
    else:
        push_warning("MWASecureCache: plugin not available — falling back to MWAFileCache.")
        _fallback = MWAFileCache.new()

func _is_plugin_available() -> bool:
    return _plugin != null

# ─── Interface Implementation ────────────────────────────────────────────────

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    if not _is_plugin_available():
        return _fallback.save_auth_token(key, token)
    if key.is_empty() or token == null:
        return false
    _plugin.cacheSet(key, JSON.stringify(token.to_dict()))
    return true

func load_auth_token(key: String) -> MWAAuthToken:
    if not _is_plugin_available():
        return _fallback.load_auth_token(key)
    var json_str: String = _plugin.cacheGet(key)
    if json_str.is_empty():
        return null
    var data = JSON.parse_string(json_str)
    if data == null:
        return null
    var token = MWAAuthToken.from_dict(data)
    if token == null or not token.is_valid():
        clear_auth_token(key)
        return null
    return token

func clear_auth_token(key: String) -> bool:
    if not _is_plugin_available():
        return _fallback.clear_auth_token(key)
    _plugin.cacheClear(key)
    return true

func clear_all() -> bool:
    if not _is_plugin_available():
        return _fallback.clear_all()
    _plugin.cacheClearAll()
    return true

# ─── Extras ──────────────────────────────────────────────────────────────────

func get_cache_status() -> Dictionary:
    if not _is_plugin_available():
        return { "backend": "file_fallback", "has_token": false }
    return {
        "backend":          "secure_keystore",
        "has_token":        _plugin.cacheHasToken(),
        "age_seconds":      _plugin.cacheGetAgeSeconds(),
        "wallet_address":   _plugin.cacheGetAddress(),
        "is_stale":         _plugin.cacheIsStale()
    }

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    if _is_plugin_available():
        return "MWASecureCache(backend=EncryptedSharedPreferences)"
    return "MWASecureCache(backend=file_fallback)"
