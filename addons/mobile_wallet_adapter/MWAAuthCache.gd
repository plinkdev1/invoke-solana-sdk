# MWAAuthCache.gd
# Invoke SDK — Abstract base class for auth token cache backends
# Extend this class to implement a custom cache backend
# Reference: docs/AUTH_CACHE_RESEARCH.md

class_name MWAAuthCache
extends RefCounted

# ─── Interface (override in subclasses) ──────────────────────────────────────

# Save an auth token for the given wallet key
func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    push_error("MWAAuthCache.save_auth_token() must be implemented by subclass.")
    return false

# Load an auth token for the given wallet key
# Returns null if not found or expired
func load_auth_token(key: String) -> MWAAuthToken:
    push_error("MWAAuthCache.load_auth_token() must be implemented by subclass.")
    return null

# Clear the auth token for the given wallet key
func clear_auth_token(key: String) -> bool:
    push_error("MWAAuthCache.clear_auth_token() must be implemented by subclass.")
    return false

# Clear all cached auth tokens
func clear_all() -> bool:
    push_error("MWAAuthCache.clear_all() must be implemented by subclass.")
    return false

# ─── Shared Helpers (available to all subclasses) ────────────────────────────

# Build a cache key from wallet package + app identifier
static func make_key(wallet_package: String, app_id: String = "invoke") -> String:
    return "%s_%s" % [wallet_package, app_id]

# Check if a token exists and is still usable
func has_valid_token(key: String) -> bool:
    var token = load_auth_token(key)
    return token != null and token.is_valid()

# Check if a token exists and is fresh enough to reuse directly
func has_fresh_token(key: String) -> bool:
    var token = load_auth_token(key)
    return token != null and token.should_reuse()

# Check if a token exists and can be silently reauthorized
func has_reauthorizable_token(key: String) -> bool:
    var token = load_auth_token(key)
    return token != null and token.should_reauthorize()
