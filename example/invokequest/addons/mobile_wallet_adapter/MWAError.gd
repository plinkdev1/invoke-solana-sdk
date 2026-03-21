# MWAError.gd
# Invoke SDK — Error codes and messages
# All SDK errors are emitted via the 'error' signal — never thrown

class_name MWAError
extends RefCounted

# ─── Error Code Enum ─────────────────────────────────────────────────────────

enum Code {
    # Auth errors (1xxx)
    USER_DECLINED           = 1001,  # User tapped Reject in wallet
    WALLET_NOT_INSTALLED    = 1002,  # No MWA wallet app found on device
    SESSION_ALREADY_ACTIVE  = 1003,  # Concurrent transact() call blocked
    AUTH_TOKEN_INVALID      = 1004,  # AuthorizationNotValidException from wallet
    AUTH_TOKEN_EXPIRED      = 1005,  # Token age exceeded reauth threshold

    # Transaction errors (2xxx)
    TRANSACTION_EXPIRED     = 2001,  # BlockhashNotFound — retry with new blockhash
    TRANSACTION_FAILED      = 2002,  # On-chain failure — do not retry
    SIMULATION_FAILED       = 2003,  # Preflight simulation error
    INSUFFICIENT_FUNDS      = 2004,  # InsufficientFundsForRentError
    BLOCKHASH_NOT_FOUND     = 2005,  # Blockhash expired — retry once

    # Network errors (3xxx)
    NETWORK_TIMEOUT         = 3001,  # IOException or 60s timeout exceeded
    RPC_ERROR               = 3002,  # RPC 5xx or malformed response

    # Unknown
    UNKNOWN                 = 9999
}

# ─── Human-Readable Messages ─────────────────────────────────────────────────

static func get_message(code: Code) -> String:
    match code:
        Code.USER_DECLINED:
            return "Authorization declined by user."
        Code.WALLET_NOT_INSTALLED:
            return "No Solana wallet app found. Please install Phantom, Backpack, or Solflare."
        Code.SESSION_ALREADY_ACTIVE:
            return "A wallet session is already active. Please wait."
        Code.AUTH_TOKEN_INVALID:
            return "Authorization token is no longer valid. Re-authorization required."
        Code.AUTH_TOKEN_EXPIRED:
            return "Authorization token has expired. Re-authorization required."
        Code.TRANSACTION_EXPIRED:
            return "Transaction expired. Please try again."
        Code.TRANSACTION_FAILED:
            return "Transaction failed on-chain."
        Code.SIMULATION_FAILED:
            return "Transaction simulation failed. Check transaction data."
        Code.INSUFFICIENT_FUNDS:
            return "Insufficient funds for this transaction."
        Code.BLOCKHASH_NOT_FOUND:
            return "Blockhash not found. Retrying with a fresh blockhash."
        Code.NETWORK_TIMEOUT:
            return "Network timeout. Check your connection and try again."
        Code.RPC_ERROR:
            return "RPC error. Please try again."
        _:
            return "An unknown error occurred."

# ─── Retryable Check ─────────────────────────────────────────────────────────

static func is_retryable(code: Code) -> bool:
    match code:
        Code.AUTH_TOKEN_INVALID, \
        Code.AUTH_TOKEN_EXPIRED, \
        Code.TRANSACTION_EXPIRED, \
        Code.BLOCKHASH_NOT_FOUND, \
        Code.NETWORK_TIMEOUT, \
        Code.RPC_ERROR:
            return true
        _:
            return false
