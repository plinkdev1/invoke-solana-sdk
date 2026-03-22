# MWACapabilities.gd
# Invoke SDK — Wallet capabilities returned by get_capabilities()
# Mirrors the Capabilities type from the React Native MWA SDK

class_name MWACapabilities
extends RefCounted

# ─── Fields ──────────────────────────────────────────────────────────────────

var supports_clone_authorization       : bool  # Wallet supports cloneAuthorization()
var supports_sign_and_send_transactions: bool  # Wallet supports signAndSendTransactions()
var max_transactions_per_request       : int   # Max txs in a single sign request (0 = unlimited)
var max_messages_per_request           : int   # Max messages in a single sign request (0 = unlimited)

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init() -> void:
    supports_clone_authorization        = false
    supports_sign_and_send_transactions = false
    max_transactions_per_request        = 0
    max_messages_per_request            = 0

# ─── Helpers ─────────────────────────────────────────────────────────────────

func can_sign_and_send() -> bool:
    return supports_sign_and_send_transactions

func can_clone_authorization() -> bool:
    return supports_clone_authorization

# Returns true if the wallet can handle the requested tx count
func supports_transaction_count(count: int) -> bool:
    if max_transactions_per_request == 0:
        return true
    return count <= max_transactions_per_request

# Returns true if the wallet can handle the requested message count
func supports_message_count(count: int) -> bool:
    if max_messages_per_request == 0:
        return true
    return count <= max_messages_per_request

# ─── Serialization ───────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
    return {
        "supports_clone_authorization":        supports_clone_authorization,
        "supports_sign_and_send_transactions": supports_sign_and_send_transactions,
        "max_transactions_per_request":        max_transactions_per_request,
        "max_messages_per_request":            max_messages_per_request
    }

static func from_dict(data: Dictionary) -> MWACapabilities:
    var c = MWACapabilities.new()
    c.supports_clone_authorization        = data.get("supports_clone_authorization", false)
    c.supports_sign_and_send_transactions = data.get("supports_sign_and_send_transactions", false)
    c.max_transactions_per_request        = data.get("max_transactions_per_request", 0)
    c.max_messages_per_request            = data.get("max_messages_per_request", 0)
    return c

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWACapabilities(clone=%s, sign_and_send=%s, max_tx=%d, max_msg=%d)" % [
        str(supports_clone_authorization),
        str(supports_sign_and_send_transactions),
        max_transactions_per_request,
        max_messages_per_request
    ]
