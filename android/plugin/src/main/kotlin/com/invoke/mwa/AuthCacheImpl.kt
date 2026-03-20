package com.invoke.mwa

import android.content.Context
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * AuthCacheImpl.kt
 * Invoke SDK — EncryptedSharedPreferences auth token cache
 * Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 5
 * Reference: docs/AUTH_CACHE_RESEARCH.md Section 2.3
 *
 * SECURITY NOTES:
 * - Never log auth tokens — not even first/last 4 chars
 * - AES256-GCM key encryption + AES256-SIV value encryption
 * - Encrypted at rest, app-private storage
 */

data class CachedAuth(
    val authToken: String,
    val address:   String,
    val ageMs:     Long
)

class AuthCacheImpl(private val context: Context) {

    companion object {
        private const val PREFS_FILE            = "invoke_mwa_session"
        private const val REUSE_THRESHOLD_MS    = 30  * 60 * 1000L   // 30 minutes
        private const val REAUTH_THRESHOLD_MS   = 24  * 60 * 60 * 1000L // 24 hours

        private const val KEY_AUTH_TOKEN  = "_auth_token"
        private const val KEY_ADDRESS     = "_address"
        private const val KEY_TIMESTAMP   = "_timestamp"
    }

    private val prefs by lazy {
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        EncryptedSharedPreferences.create(
            context,
            PREFS_FILE,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    // ── Write ────────────────────────────────────────────────────────────────

    fun save(walletPackage: String, authToken: String, address: String) {
        prefs.edit()
            .putString(walletPackage + KEY_AUTH_TOKEN, authToken)
            .putString(walletPackage + KEY_ADDRESS,    address)
            .putLong(  walletPackage + KEY_TIMESTAMP,  System.currentTimeMillis())
            .apply()
    }

    // ── Read ─────────────────────────────────────────────────────────────────

    fun load(walletPackage: String): CachedAuth? {
        val token = prefs.getString(walletPackage + KEY_AUTH_TOKEN, null)
            ?: return null
        val timestamp = prefs.getLong(walletPackage + KEY_TIMESTAMP, 0L)
        val address   = prefs.getString(walletPackage + KEY_ADDRESS, "") ?: ""
        return CachedAuth(
            authToken = token,
            address   = address,
            ageMs     = System.currentTimeMillis() - timestamp
        )
    }

    // ── Token Age Helpers ─────────────────────────────────────────────────────

    fun shouldReuse(walletPackage: String): Boolean {
        val cached = load(walletPackage) ?: return false
        return cached.ageMs < REUSE_THRESHOLD_MS
    }

    fun shouldReauthorize(walletPackage: String): Boolean {
        val cached = load(walletPackage) ?: return false
        return cached.ageMs < REAUTH_THRESHOLD_MS
    }

    fun isStale(walletPackage: String): Boolean {
        val cached = load(walletPackage) ?: return false
        return cached.ageMs >= REUSE_THRESHOLD_MS
    }

    fun hasToken(walletPackage: String): Boolean {
        return prefs.getString(walletPackage + KEY_AUTH_TOKEN, null) != null
    }

    fun getAgeSeconds(walletPackage: String): Long {
        val timestamp = prefs.getLong(walletPackage + KEY_TIMESTAMP, 0L)
        if (timestamp == 0L) return Long.MAX_VALUE
        return (System.currentTimeMillis() - timestamp) / 1000L
    }

    // ── Delete ───────────────────────────────────────────────────────────────

    fun clear(walletPackage: String) {
        prefs.edit()
            .remove(walletPackage + KEY_AUTH_TOKEN)
            .remove(walletPackage + KEY_ADDRESS)
            .remove(walletPackage + KEY_TIMESTAMP)
            .apply()
    }

    fun clearAll() {
        prefs.edit().clear().apply()
    }
}
