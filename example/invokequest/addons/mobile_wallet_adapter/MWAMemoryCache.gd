# MWAMemoryCache.gd
# Invoke SDK — In-memory auth token cache
# Tokens are lost when the app closes — use for development/testing only
# Reference: docs/AUTH_CACHE_RESEARCH.md Section 2.1

class_name MWAMemoryCache
extends MWAAuthCache

# ─── Storage ─────────────────────────────────────────────────────────────────

var _store: Dictionary = {}

# ─── Interface Implementation ────────────────────────────────────────────────

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    if key.is_empty():
        push_error("MWAMemoryCache: key cannot be empty.")
        return false
    if token == null:
        push_error("MWAMemoryCache: token cannot be null.")
        return false
    _store[key] = token
    return true

func load_auth_token(key: String) -> MWAAuthToken:
    if not _store.has(key):
        return null
    var token: MWAAuthToken = _store[key]
    if token == null or not token.is_valid():
        clear_auth_token(key)
        return null
    return token

func clear_auth_token(key: String) -> bool:
    if _store.has(key):
        _store.erase(key)
    return true

func clear_all() -> bool:
    _store.clear()
    return true

# ─── Extras ──────────────────────────────────────────────────────────────────

func get_token_count() -> int:
    return _store.size()

func get_all_keys() -> Array:
    return _store.keys()

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWAMemoryCache(tokens=%d)" % _store.size()
