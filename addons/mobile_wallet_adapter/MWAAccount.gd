# MWAAccount.gd
# Invoke SDK — Wallet account returned after successful authorize()
# NOTE: MWA spec returns address as base64 bytes — Kotlin layer decodes
# to base58 string before emitting the signal. This class receives base58.

class_name MWAAccount
extends RefCounted

# ─── Fields ──────────────────────────────────────────────────────────────────

var address_base58: String          # Public key as base58 string (decoded by Kotlin)
var address_bytes: PackedByteArray  # Raw public key bytes (32 bytes)
var label: String                   # Optional wallet label
var chains: Array[String]           # Supported chains e.g. ["solana:devnet"]
var features: Array[String]         # Supported features from wallet

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init() -> void:
    address_base58 = ""
    address_bytes  = PackedByteArray()
    label          = ""
    chains         = []
    features       = []

# ─── Helpers ─────────────────────────────────────────────────────────────────

# Returns truncated address for UI display (first 4 ... last 4)
func get_display_address() -> String:
    if address_base58.length() <= 8:
        return address_base58
    return "%s...%s" % [
        address_base58.substr(0, 4),
        address_base58.substr(address_base58.length() - 4, 4)
    ]

func is_valid() -> bool:
    return not address_base58.is_empty() and address_base58.length() >= 32

func supports_chain(chain: String) -> bool:
    return chain in chains

# ─── Serialization ───────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
    return {
        "address_base58": address_base58,
        "address_bytes":  address_bytes.hex_encode(),
        "label":          label,
        "chains":         chains,
        "features":       features
    }

static func from_dict(data: Dictionary) -> MWAAccount:
    var account          = MWAAccount.new()
    account.address_base58 = data.get("address_base58", "")
    account.label          = data.get("label", "")
    account.chains         = data.get("chains", [])
    account.features       = data.get("features", [])
    var hex: String        = data.get("address_bytes", "")
    if not hex.is_empty():
        account.address_bytes = hex.hex_decode()
    return account

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    return "MWAAccount(address=%s, label=%s, chains=%s)" % [
        get_display_address(), label, str(chains)
    ]
