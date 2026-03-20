# MWASendOptions.gd
# Invoke SDK — Options passed to sign_and_send_transactions()
# Mirrors the SendOptions type from the React Native MWA SDK

class_name MWASendOptions
extends RefCounted

# ─── Fields ──────────────────────────────────────────────────────────────────

# The minimum slot that the request can be evaluated at.
# Optional — pass null to use the current slot.
# Matches: minContextSlot in React Native SDK SendOptions
var min_context_slot: Variant  # int or null

# ─── Constructor ─────────────────────────────────────────────────────────────

func _init(p_min_context_slot: Variant = null) -> void:
    min_context_slot = p_min_context_slot

# ─── Helpers ─────────────────────────────────────────────────────────────────

func has_min_context_slot() -> bool:
    return min_context_slot != null

# ─── Serialization ───────────────────────────────────────────────────────────

func to_dict() -> Dictionary:
    return {
        "min_context_slot": min_context_slot
    }

static func from_dict(data: Dictionary) -> MWASendOptions:
    return MWASendOptions.new(data.get("min_context_slot", null))

# ─── Debug ───────────────────────────────────────────────────────────────────

func _to_string() -> String:
    if has_min_context_slot():
        return "MWASendOptions(min_context_slot=%d)" % min_context_slot
    return "MWASendOptions(min_context_slot=null)"
