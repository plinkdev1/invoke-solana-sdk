package com.invoke.mwa

/**
 * MWAError.kt
 * Invoke SDK — Error code constants and exception mapper
 * Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 3
 */
object MWAErrorCodes {
    const val USER_DECLINED           = 1001
    const val WALLET_NOT_INSTALLED    = 1002
    const val SESSION_ALREADY_ACTIVE  = 1003
    const val AUTH_TOKEN_INVALID      = 1004
    const val AUTH_TOKEN_EXPIRED      = 1005
    const val TRANSACTION_EXPIRED     = 2001
    const val TRANSACTION_FAILED      = 2002
    const val SIMULATION_FAILED       = 2003
    const val INSUFFICIENT_FUNDS      = 2004
    const val BLOCKHASH_NOT_FOUND     = 2005
    const val NETWORK_TIMEOUT         = 3001
    const val RPC_ERROR               = 3002
    const val UNKNOWN                 = 9999
}

/**
 * Maps MWA SDK exceptions to Invoke error codes.
 * Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 3
 */
fun mapErrorCode(e: Exception): Int = when {
    e is android.content.ActivityNotFoundException
        -> MWAErrorCodes.WALLET_NOT_INSTALLED
    e.message?.contains("User rejected",       ignoreCase = true) == true
        -> MWAErrorCodes.USER_DECLINED
    e.message?.contains("Authorization not valid", ignoreCase = true) == true
        -> MWAErrorCodes.AUTH_TOKEN_INVALID
    e.message?.contains("Blockhash not found", ignoreCase = true) == true
        -> MWAErrorCodes.BLOCKHASH_NOT_FOUND
    e.message?.contains("insufficient funds",  ignoreCase = true) == true
        -> MWAErrorCodes.INSUFFICIENT_FUNDS
    e.message?.contains("simulation failed",   ignoreCase = true) == true
        -> MWAErrorCodes.SIMULATION_FAILED
    e is java.io.IOException
        -> MWAErrorCodes.NETWORK_TIMEOUT
    else
        -> MWAErrorCodes.UNKNOWN
}

fun isRetryable(code: Int): Boolean = code in setOf(
    MWAErrorCodes.AUTH_TOKEN_INVALID,
    MWAErrorCodes.AUTH_TOKEN_EXPIRED,
    MWAErrorCodes.TRANSACTION_EXPIRED,
    MWAErrorCodes.BLOCKHASH_NOT_FOUND,
    MWAErrorCodes.NETWORK_TIMEOUT,
    MWAErrorCodes.RPC_ERROR
)
