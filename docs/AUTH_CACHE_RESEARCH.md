# Auth Cache Research
## Invoke SDK — Authorization Token Storage Backends
### Implementation spec for Phase 1 Tasks 1.1.3 + 1.2.3

---

## 1. PROBLEM

The MWA `authorize()` call opens the wallet app and shows an approval
popup to the user. Without caching, this happens on every app launch.
The auth token returned by `authorize()` can be reused via
`reauthorize()` — which is silent, no popup. The cache makes this
possible across sessions.

---

## 2. THREE STORAGE BACKENDS

### 2.1 — MWAMemoryCache (GDScript only)

| Property | Value |
|----------|-------|
| Class | `MWAMemoryCache.gd` |
| Storage | GDScript Dictionary (RAM) |
| Persistence | None — lost on app close |
| Security | None |
| Use case | Development, unit testing |
| Android required | No — works on desktop too |
```gdscript
# In-memory store — simple Dictionary
var _store: Dictionary = {}

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    _store[key] = token
    return true

func load_auth_token(key: String) -> MWAAuthToken:
    return _store.get(key, null)

func clear_auth_token(key: String) -> bool:
    _store.erase(key)
    return true

func clear_all() -> bool:
    _store.clear()
    return true
```

---

### 2.2 — MWAFileCache (GDScript — default)

| Property | Value |
|----------|-------|
| Class | `MWAFileCache.gd` |
| Storage | JSON file at `user://mwa_auth/tokens.dat` |
| Persistence | Survives app restarts |
| Security | Low — plaintext JSON on device storage |
| Use case | Default for most games |
| Android required | No — works on desktop too |

Key decisions:
- `user://` maps to app-private storage on Android (not accessible to other apps)
- Token is validated on load — expired tokens are discarded automatically
- File is rewritten on every save (small file, acceptable)
```gdscript
const CACHE_DIR  = "user://mwa_auth/"
const CACHE_FILE = "user://mwa_auth/tokens.dat"

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    DirAccess.make_dir_recursive_absolute(CACHE_DIR)
    var cache = _load_raw()
    cache[key] = token.to_dict()
    var file = FileAccess.open(CACHE_FILE, FileAccess.WRITE)
    if not file: return false
    file.store_string(JSON.stringify(cache))
    return true

func load_auth_token(key: String) -> MWAAuthToken:
    var cache = _load_raw()
    if not cache.has(key): return null
    var token = MWAAuthToken.from_dict(cache[key])
    if not token.is_valid():
        clear_auth_token(key)
        return null
    return token
```

---

### 2.3 — MWASecureCache (Android Keystore — production)

| Property | Value |
|----------|-------|
| GDScript class | `MWASecureCache.gd` |
| Kotlin class | `AuthCacheImpl.kt` |
| Storage | Android EncryptedSharedPreferences |
| Encryption | AES256-GCM (key) + AES256-SIV (value) |
| Persistence | Survives app restarts |
| Security | High — encrypted at rest |
| Use case | Production shipping games |
| Android required | YES — Android only |
```kotlin
// AuthCacheImpl.kt — EncryptedSharedPreferences backend
class AuthCacheImpl(private val context: Context) {

    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()

    private val prefs = EncryptedSharedPreferences.create(
        context,
        "invoke_mwa_session",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )

    fun save(walletPackage: String, authToken: String, address: String) {
        prefs.edit()
            .putString("_auth_token", authToken)
            .putString("_address", address)
            .putLong("_timestamp", System.currentTimeMillis())
            .apply()
    }

    fun load(walletPackage: String): CachedAuth? {
        val token = prefs.getString("_auth_token", null)
            ?: return null
        val timestamp = prefs.getLong("_timestamp", 0L)
        return CachedAuth(
            authToken = token,
            address = prefs.getString("_address", "") ?: "",
            ageMs = System.currentTimeMillis() - timestamp
        )
    }

    fun clear(walletPackage: String) {
        prefs.edit()
            .remove("_auth_token")
            .remove("_address")
            .remove("_timestamp")
            .apply()
    }

    fun clearAll() = prefs.edit().clear().apply()
}

data class CachedAuth(val authToken: String, val address: String, val ageMs: Long)
```

---

## 3. CACHE KEY STRATEGY

Key format: `{wallet_package}_{app_id}`

| Wallet | Package | Example Key |
|--------|---------|-------------|
| Phantom | `app.phantom` | `app.phantom_invoke` |
| Backpack | `com.backpack.wallet` | `com.backpack.wallet_invoke` |
| Solflare | `com.solflare.mobile` | `com.solflare.mobile_invoke` |

- One key per wallet per app
- If user switches wallet, old key stays (multi-wallet support)
- `clear_all()` wipes all wallets at once (full logout)

---

## 4. TOKEN EXPIRY LOGIC

### Two-tier expiry system:
```
Token age < 30 minutes  →  Reuse directly (no wallet call)
Token age 30min–24h     →  Silent reauthorize() (no popup)
Token age > 24h         →  Full authorize() (wallet popup)
Token invalid exception →  Clear cache + full authorize()
```

### Constants (define in AuthCacheImpl.kt):
```kotlin
const val REUSE_THRESHOLD_MS    = 30 * 60 * 1000L       // 30 minutes
const val REAUTH_THRESHOLD_MS   = 24 * 60 * 60 * 1000L  // 24 hours
```

### GDScript equivalent (MWAAuthToken.gd):
```gdscript
const REUSE_THRESHOLD_SEC  = 30 * 60      # 30 minutes
const REAUTH_THRESHOLD_SEC = 24 * 60 * 60 # 24 hours

func is_valid() -> bool:
    return token != "" and created_at > 0

func get_age_seconds() -> int:
    return int(Time.get_unix_time_from_system()) - created_at

func should_reuse() -> bool:
    return is_valid() and get_age_seconds() < REUSE_THRESHOLD_SEC

func should_reauthorize() -> bool:
    return is_valid() and get_age_seconds() < REAUTH_THRESHOLD_SEC

func is_expired() -> bool:
    return not is_valid() or get_age_seconds() >= REAUTH_THRESHOLD_SEC
```

---

## 5. AUTO-DETECT LOGIC (MWACacheManager.gd)
```gdscript
# Automatically pick the best available backend
static func create_best_cache() -> MWAAuthCache:
    if OS.get_name() == "Android":
        # Use secure encrypted storage on Android
        return MWASecureCache.new()
    else:
        # Use file cache on desktop (dev/testing)
        return MWAFileCache.new()
```

---

## 6. SECURITY NOTES

1. Never log auth tokens — not even first/last 4 chars
2. Never include tokens in crash reports or analytics
3. `user://` on Android is app-private but NOT encrypted (FileCache)
4. EncryptedSharedPreferences is encrypted but key is in MasterKey — not hardware-backed
5. Android Keystore (KeystoreCacheImpl) is hardware-backed on supported devices
6. Token expiry is app-side only — wallet may invalidate earlier without notice
7. On `AuthorizationNotValidException`: always clear cache before retrying

---

*Invoke SDK Auth Cache Research v1.0 · Francisco (Franny) · Portugal · 2026*
