# MWAAuthToken.gd
# Invoke SDK — Authorization token returned by wallet after authorize()
# Holds the token string, associated account, and expiry logic
# Reference: docs/AUTH_CACHE_RESEARCH.md Section 4

class_name MWAAuthToken
extends RefCounted

# ─── Expiry Thresholds ───────────────────────────────────────────────────────

const REUSE_THRESHOLD_SEC  : int = 30 * 60       # 30 min — reuse with no wallet call
const REAUTH_THRESHOLD_SEC : int = 24 * 60 * 60  # 24 hrs — attempt silent reauthorize

# ─── Fields ──────────────────────────────────────────────────────────────────

var token          : String      # Raw auth token string from wallet
var wallet_uri_base: String      # Wallet's base URI (for reconnect)
var wallet_name    : String      # Wallet display name e.g. "Phantom"
var wallet_package : String      # Wallet package e.g. "app.phantom"
var account        : MWAAccount  # The authorized account
var created_at     : int         # Unix timestamp (seconds) when token was issued
var cluster        : String      # "devnet" | "testnet" | "mainnet-beta"

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init() -> void:
    token           = ""
    wallet_uri_base = ""
    wallet_name     = ""
    wallet_package  = ""
    account         = null
    created_at      = 0
    cluster         = "devnet"

# ─── Expiry Logic ────────────────────────────────────────────────────────────

func get_age_seconds() -> int:
    if created_at == 0:
        return 999999
    return int(Time.get_unix_time_from_system()) - created_at

# Token is fresh — reuse directly, no wallet call needed
func should_reuse() -> bool:
    return is_valid() and get_age_seconds() < REUSE_THRESHOLD_SEC

# Token is stale but recoverable — attempt silent reauthorize()
func should_reauthorize() -> bool:
    return is_valid() and get_age_seconds() < REAUTH_THRESHOLD_SEC

# Token is expired — must do full authorize() with wallet popup
func is_expired() -> bool:
    return not is_valid() or get_age_seconds() >= REAUTH_THRESHOLD_SEC

# Basic validity — token string must exist
func is_valid() -> bool:
    return not token.is_empty() and created_at > 0

# Human-readable status for UI / debug
func get_status() -> String:
    if not is_valid():
        return "INVALID"
    if should_reuse():
        return "FRESH"
    if should_reauthorize():
        return "STALE"
    return "EXPIRED"

# ─── Serialization ───────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
    return {
        "token":           token,
        "wallet_uri_base": wallet_uri_base,
        "wallet_name":     wallet_name,
        "wallet_package":  wallet_package,
        "account":         account.to_dict() if account else {},
        "created_at":      created_at,
        "cluster":         cluster
    }

static func from_dict(data: Dictionary) -> MWAAuthToken:
    var t             = MWAAuthToken.new()
    t.token           = data.get("token", "")
    t.wallet_uri_base = data.get("wallet_uri_base", "")
    t.wallet_name     = data.get("wallet_name", "")
    t.wallet_package  = data.get("wallet_package", "")
    t.created_at      = data.get("created_at", 0)
    t.cluster         = data.get("cluster", "devnet")
    var acc_data      = data.get("account", {})
    if not acc_data.is_empty():
        t.account = MWAAccount.from_dict(acc_data)
    return t

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWAAuthToken(status=%s, age=%ds, wallet=%s, cluster=%s)" % [
        get_status(), get_age_seconds(), wallet_name, cluster
    ]
