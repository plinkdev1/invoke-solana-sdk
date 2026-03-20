# MobileWalletAdapter.gd
# Invoke SDK — Main SDK class. Drop this addon into any Godot 4.x project.
# Usage: add as AutoLoad singleton named 'MWA' in Project Settings
# Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md

class_name MobileWalletAdapter
extends Node

# ─── State Machine ───────────────────────────────────────────────────────────

enum State {
    IDLE,           # No session, no token
    CONNECTING,     # transact() in flight — waiting for wallet
    AUTHORIZED,     # Token valid, account set, cache populated
    REAUTHORIZING,  # Silent background reauth in progress
    ERROR           # Last operation failed
}

# ─── Signals ─────────────────────────────────────────────────────────────────

signal authorized(auth_token: String, account: MWAAccount)
signal reauthorized(auth_token: String)
signal deauthorized()
signal disconnected()
signal transaction_signed(signatures: Array)
signal transaction_sent(signatures: Array)
signal message_signed(signed_messages: Array)
signal capabilities_received(capabilities: MWACapabilities)
signal wallets_detected(wallets: Array)
signal error(code: int, message: String)
signal state_changed(new_state: State)

# ─── Internal State ──────────────────────────────────────────────────────────

var _state         : State       = State.IDLE
var _current_token : MWAAuthToken = null
var _plugin        : Object       = null
var _identity      : MWAIdentity  = null

# ─── Constants ───────────────────────────────────────────────────────────────

const PLUGIN_NAME  = "InvokeMWA"
const COLD_START_DELAY_MS = 500  # Reference: GODOTMWA_REFERENCE_IMPLEMENTATION.md Section 3

# ─── Lifecycle ───────────────────────────────────────────────────────────────

func _ready() -> void:
    _plugin = _get_plugin()
    if _plugin:
        _connect_plugin_signals()
        print("[InvokeMWA] Plugin loaded — Android MWA ready.")
    else:
        push_warning("[InvokeMWA] Android plugin not found. Running in stub mode (non-Android).")

func _get_plugin() -> Object:
    if Engine.has_singleton(PLUGIN_NAME):
        return Engine.get_singleton(PLUGIN_NAME)
    return null

func _is_plugin_available() -> bool:
    if _plugin == null:
        _emit_error(MWAError.Code.WALLET_NOT_INSTALLED,
            "InvokeMWA plugin not available on this platform.")
        return false
    return true

# ─── State Management ────────────────────────────────────────────────────────

func get_state() -> State:
    return _state

func is_connected() -> bool:
    return _state == State.AUTHORIZED

func get_current_account() -> MWAAccount:
    if _current_token and _current_token.account:
        return _current_token.account
    return null

func get_current_token() -> MWAAuthToken:
    return _current_token

func _set_state(new_state: State) -> void:
    if _state == new_state:
        return
    _state = new_state
    state_changed.emit(new_state)

# ─── Plugin Signal Connections ───────────────────────────────────────────────

func _connect_plugin_signals() -> void:
    _plugin.connect("authorized",             _on_plugin_authorized)
    _plugin.connect("reauthorized",           _on_plugin_reauthorized)
    _plugin.connect("deauthorized",           _on_plugin_deauthorized)
    _plugin.connect("transaction_signed",     _on_plugin_transaction_signed)
    _plugin.connect("transaction_sent",       _on_plugin_transaction_sent)
    _plugin.connect("message_signed",         _on_plugin_message_signed)
    _plugin.connect("capabilities_received",  _on_plugin_capabilities_received)
    _plugin.connect("wallet_apps_detected",   _on_plugin_wallets_detected)
    _plugin.connect("mwa_error",              _on_plugin_error)

# ─── Public API — Session ────────────────────────────────────────────────────

# authorize() — opens wallet app, shows approval popup on first call
# identity: MWAIdentity — your app name, uri, icon
# cluster: "devnet" | "testnet" | "mainnet-beta"
func authorize(identity: MWAIdentity, cluster: String = "devnet") -> void:
    if not _is_plugin_available():
        return
    if not identity.is_valid():
        _emit_error(MWAError.Code.UNKNOWN, "Invalid MWAIdentity provided.")
        return
    if _state == State.CONNECTING or _state == State.REAUTHORIZING:
        _emit_error(MWAError.Code.SESSION_ALREADY_ACTIVE,
            MWAError.get_message(MWAError.Code.SESSION_ALREADY_ACTIVE))
        return
    _identity = identity
    _set_state(State.CONNECTING)
    _plugin.authorize(cluster, identity.name, identity.uri, identity.icon)

# reauthorize() — silent background call, no wallet popup if token still valid
func reauthorize(auth_token: String, identity: MWAIdentity) -> void:
    if not _is_plugin_available():
        return
    if auth_token.is_empty():
        _emit_error(MWAError.Code.AUTH_TOKEN_INVALID, "Auth token is empty.")
        return
    _set_state(State.REAUTHORIZING)
    _plugin.reauthorize(auth_token, identity.name, identity.uri, identity.icon)

# deauthorize() — tells wallet to invalidate this token server-side
func deauthorize(auth_token: String) -> void:
    if not _is_plugin_available():
        return
    if auth_token.is_empty():
        _emit_error(MWAError.Code.AUTH_TOKEN_INVALID, "Auth token is empty.")
        return
    _plugin.deauthorize(auth_token)

# disconnect() — local only, does NOT call wallet, keeps token in cache
func disconnect() -> void:
    _set_state(State.IDLE)
    disconnected.emit()

# full_logout() — deauthorize + clear local token + go to IDLE
func full_logout() -> void:
    if _current_token and not _current_token.token.is_empty():
        deauthorize(_current_token.token)
    _current_token = null
    _set_state(State.IDLE)
    disconnected.emit()

# ─── Internal Helpers ────────────────────────────────────────────────────────

func _emit_error(code: MWAError.Code, msg: String) -> void:
    _set_state(State.ERROR)
    error.emit(int(code), msg)

# ─── Public API — Transactions ───────────────────────────────────────────────

# sign_transactions() — sign one or more transactions, does NOT send
func sign_transactions(transactions: Array) -> void:
    if not _is_plugin_available():
        return
    if transactions.is_empty():
        _emit_error(MWAError.Code.UNKNOWN, "No transactions provided.")
        return
    if not is_connected():
        _emit_error(MWAError.Code.AUTH_TOKEN_INVALID, "Not authorized. Call authorize() first.")
        return
    var encoded: Array[String] = []
    for tx in transactions:
        encoded.append(Marshalls.raw_to_base64(tx))
    _plugin.signTransactions(encoded)

# sign_and_send_transactions() — sign and broadcast to network
func sign_and_send_transactions(transactions: Array,
        options: MWASendOptions = null) -> void:
    if not _is_plugin_available():
        return
    if transactions.is_empty():
        _emit_error(MWAError.Code.UNKNOWN, "No transactions provided.")
        return
    if not is_connected():
        _emit_error(MWAError.Code.AUTH_TOKEN_INVALID, "Not authorized. Call authorize() first.")
        return
    var encoded: Array[String] = []
    for tx in transactions:
        encoded.append(Marshalls.raw_to_base64(tx))
    var min_slot: int = -1
    if options and options.has_min_context_slot():
        min_slot = options.min_context_slot
    _plugin.signAndSendTransactions(encoded, min_slot)

# sign_messages() — sign arbitrary messages (off-chain, personal sign)
func sign_messages(messages: Array, addresses: Array) -> void:
    if not _is_plugin_available():
        return
    if messages.is_empty():
        _emit_error(MWAError.Code.UNKNOWN, "No messages provided.")
        return
    if not is_connected():
        _emit_error(MWAError.Code.AUTH_TOKEN_INVALID, "Not authorized. Call authorize() first.")
        return
    var encoded_msgs: Array[String] = []
    for msg in messages:
        encoded_msgs.append(Marshalls.raw_to_base64(msg))
    var encoded_addrs: Array[String] = []
    for addr in addresses:
        encoded_addrs.append(Marshalls.raw_to_base64(addr))
    _plugin.signMessages(encoded_msgs, encoded_addrs)

# get_capabilities() — query what features the wallet supports
func get_capabilities() -> void:
    if not _is_plugin_available():
        return
    _plugin.getCapabilities()

# get_installed_wallets() — list MWA wallets installed on device
func get_installed_wallets() -> void:
    if not _is_plugin_available():
        return
    _plugin.getInstalledWallets()

# ─── Plugin Signal Handlers ──────────────────────────────────────────────────

func _on_plugin_authorized(auth_token: String, address_base58: String) -> void:
    var account             = MWAAccount.new()
    account.address_base58  = address_base58
    var token               = MWAAuthToken.new()
    token.token             = auth_token
    token.account           = account
    token.created_at        = int(Time.get_unix_time_from_system())
    if _identity:
        token.wallet_name   = _identity.name
    _current_token = token
    _set_state(State.AUTHORIZED)
    authorized.emit(auth_token, account)

func _on_plugin_reauthorized(auth_token: String) -> void:
    if _current_token:
        _current_token.token      = auth_token
        _current_token.created_at = int(Time.get_unix_time_from_system())
    _set_state(State.AUTHORIZED)
    reauthorized.emit(auth_token)

func _on_plugin_deauthorized() -> void:
    _current_token = null
    _set_state(State.IDLE)
    deauthorized.emit()

func _on_plugin_transaction_signed(signatures_b64: Array) -> void:
    var signatures: Array[PackedByteArray] = []
    for s in signatures_b64:
        signatures.append(Marshalls.base64_to_raw(s))
    transaction_signed.emit(signatures)

func _on_plugin_transaction_sent(signatures: Array) -> void:
    transaction_sent.emit(signatures)

func _on_plugin_message_signed(signed_b64: Array) -> void:
    var signed: Array[PackedByteArray] = []
    for s in signed_b64:
        signed.append(Marshalls.base64_to_raw(s))
    message_signed.emit(signed)

func _on_plugin_capabilities_received(json: String) -> void:
    var data = JSON.parse_string(json)
    if data == null:
        _emit_error(MWAError.Code.UNKNOWN, "Failed to parse capabilities JSON.")
        return
    var caps = MWACapabilities.from_dict(data)
    capabilities_received.emit(caps)

func _on_plugin_wallets_detected(json: String) -> void:
    var data = JSON.parse_string(json)
    if data == null:
        wallets_detected.emit([])
        return
    wallets_detected.emit(data)

func _on_plugin_error(code: int, message: String) -> void:
    _set_state(State.ERROR)
    error.emit(code, message)
