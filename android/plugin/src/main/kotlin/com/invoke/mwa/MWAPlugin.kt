package com.invoke.mwa

import android.util.Log
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

/**
 * MWAPlugin.kt
 * Invoke SDK — GodotPlugin entry point
 * Registers all signals and exposes methods to GDScript via @UsedByGodot
 * Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 1
 */
class MWAPlugin(godot: Godot) : GodotPlugin(godot) {

    companion object {
        private const val TAG = "InvokeMWA"
    }

    private var bridge: MWABridge? = null

    // ── Plugin Identity ───────────────────────────────────────────────────────

    override fun getPluginName() = "InvokeMWA"

    // ── Signal Registration ───────────────────────────────────────────────────

    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo("authorized",            String::class.java, String::class.java),
        SignalInfo("reauthorized",          String::class.java),
        SignalInfo("deauthorized"),
        SignalInfo("transaction_signed",    Array<String>::class.java),
        SignalInfo("transaction_sent",      Array<String>::class.java),
        SignalInfo("message_signed",        Array<String>::class.java),
        SignalInfo("capabilities_received", String::class.java),
        SignalInfo("wallet_apps_detected",  String::class.java),
        SignalInfo("mwa_error",             Int::class.java, String::class.java)
    )

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onMainCreate(activity: android.app.Activity): android.view.View? {
        Log.d(TAG, "MWAPlugin onMainCreate — initializing bridge")
        bridge = MWABridge(
            activity  = activity,
            cache     = AuthCacheImpl(activity),
            onSignal  = { name, args -> emitSignal(name, *args) }
        )
        return null
    }

    override fun onMainResume() {
        super.onMainResume()
        Log.d(TAG, "MWAPlugin onMainResume")
    }

    override fun onMainPause() {
        super.onMainPause()
        Log.d(TAG, "MWAPlugin onMainPause")
    }

    override fun onMainDestroy() {
        super.onMainDestroy()
        bridge?.destroy()
        bridge = null
        Log.d(TAG, "MWAPlugin onMainDestroy — bridge destroyed")
    }

    // ── GDScript-Callable Methods ─────────────────────────────────────────────

    @UsedByGodot
    fun authorize(cluster: String, name: String, uri: String, icon: String) {
        bridge?.authorize(cluster, name, uri, icon)
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun reauthorize(authToken: String, name: String, uri: String, icon: String) {
        bridge?.reauthorize(authToken, name, uri, icon)
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun deauthorize(authToken: String) {
        bridge?.deauthorize(authToken)
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun signTransactions(transactionsB64: Array<String>) {
        bridge?.signTransactions(transactionsB64)
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun signAndSendTransactions(transactionsB64: Array<String>, minContextSlot: Int) {
        bridge?.signAndSendTransactions(transactionsB64, minContextSlot)
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun signMessages(messagesB64: Array<String>, addressesB64: Array<String>) {
        bridge?.signMessages(messagesB64, addressesB64)
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun getCapabilities() {
        bridge?.getCapabilities()
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    @UsedByGodot
    fun getInstalledWallets() {
        bridge?.getInstalledWallets()
            ?: emitSignal("mwa_error", MWAErrorCodes.WALLET_NOT_INSTALLED,
                "Bridge not initialized.")
    }

    // ── Cache Methods (callable from GDScript) ────────────────────────────────

    @UsedByGodot
    fun cacheHasToken(): Boolean = bridge?.cacheHasToken() ?: false

    @UsedByGodot
    fun cacheGetAgeSeconds(): Long = bridge?.cacheGetAgeSeconds() ?: -1L

    @UsedByGodot
    fun cacheGetAddress(): String = bridge?.cacheGetAddress() ?: ""

    @UsedByGodot
    fun cacheIsStale(): Boolean = bridge?.cacheIsStale() ?: false

    @UsedByGodot
    fun cacheClear() { bridge?.cacheClear() }

    @UsedByGodot
    fun cacheClearAll() { bridge?.cacheClearAll() }

    @UsedByGodot
    fun setActiveWallet(packageName: String) { bridge?.setActiveWallet(packageName) }
}
