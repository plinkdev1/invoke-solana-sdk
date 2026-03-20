# GodotMWA SDK — Pre-PRD Master Document
## Solana Airtable Grant · Francisco "Franny" (Portugal)
### Version 1.0 | March 2026

---

## 1. EXECUTIVE SUMMARY

**Grant:** Godot Mobile Wallet Adapter SDK Improvements  
**Applicant:** Francisco (Franny), Portugal  
**Max Grant:** $10,000 USD equivalent (paid in SKR)  
**Objective:** Elevate the existing Godot MWA SDK to full API parity with the React Native SDK, add an extensible authorization token cache layer, create comprehensive documentation, and ship an open-source example Godot Android app showcasing all features.

---

## 2. PROBLEM STATEMENT

### 2.1 Current State
The Solana ecosystem has excellent wallet connectivity on mobile for React Native developers via `@solana-mobile/mobile-wallet-adapter-protocol-web3js`. However, game developers using **Godot Engine** — one of the most popular open-source game engines — lack equivalent tooling. The existing Godot MWA SDK is incomplete:

- **Missing API Methods:** Several wallet interaction methods present in the React Native SDK are absent from the Godot SDK
- **No Authorization Cache:** Every session requires a full re-authorization flow, creating poor UX — users see wallet approval dialogs on every app launch
- **Broken Session Management:** Disconnect, deauthorize, and reconnect flows are unreliable or missing
- **Poor Documentation:** Minimal docs make adoption difficult for Godot game developers
- **No Showcase App:** No reference implementation for developers to learn from

### 2.2 Impact on Ecosystem
- Godot has ~2M registered developers (as of 2024)
- Mobile gaming on Android is a $50B+ market
- Solana's gaming vertical is growing (Star Atlas, Aurory, etc.)
- Without proper tooling, Godot developers cannot integrate Solana wallets (Phantom, Backpack, Solflare) on non-Saga Android devices

---

## 3. PROPOSED SOLUTION

### 3.1 Deliverable 1 — Godot MWA SDK Improvements

#### 3.1.1 API Parity with React Native SDK

The React Native MWA SDK exposes these core methods that must all be present in the Godot SDK:

| Method | React Native SDK | Godot SDK (Current) | Gap |
|--------|-----------------|---------------------|-----|
| `authorize` | ✅ | ✅ Partial | Incomplete params |
| `reauthorize` | ✅ | ❌ | Missing |
| `deauthorize` | ✅ | ❌ | Missing |
| `signTransactions` | ✅ | ✅ Partial | No versioned tx |
| `signAndSendTransactions` | ✅ | ✅ Partial | No options param |
| `signMessages` | ✅ | ❌ | Missing |
| `getCapabilities` | ✅ | ❌ | Missing |
| `cloneAuthorization` | ✅ | ❌ | Missing |

#### 3.1.2 Session Management (Disconnect / Deauthorize / Reconnect)

```gdscript
# Target API Design
class_name MobileWalletAdapter

signal authorized(auth_token: String, public_key: PackedByteArray)
signal reauthorized(auth_token: String)
signal deauthorized()
signal disconnected()
signal transaction_signed(signatures: Array[PackedByteArray])
signal transaction_sent(signatures: Array[String])
signal message_signed(signed_messages: Array[PackedByteArray])
signal error(code: int, message: String)

func authorize(identity: MWAIdentity) -> void
func reauthorize(auth_token: String, identity: MWAIdentity) -> void
func deauthorize(auth_token: String) -> void
func disconnect() -> void
func sign_transactions(transactions: Array[PackedByteArray]) -> void
func sign_and_send_transactions(transactions: Array[PackedByteArray], options: MWASendOptions = null) -> void
func sign_messages(messages: Array[PackedByteArray], addresses: Array[PackedByteArray]) -> void
func get_capabilities() -> void
```

#### 3.1.3 Authorization Token Cache Layer (Extensible)

The cache system must be pluggable — developers can swap the storage backend:

```gdscript
# Base interface
class_name MWAAuthCache extends RefCounted

func save_auth_token(key: String, token: MWAAuthToken) -> bool: pass
func load_auth_token(key: String) -> MWAAuthToken: pass
func clear_auth_token(key: String) -> bool: pass
func clear_all() -> bool: pass

# Built-in implementations
class MWAMemoryCache extends MWAAuthCache     # In-memory, lost on restart
class MWAFileCache extends MWAAuthCache       # Encrypted file storage (default)
class MWASecureCache extends MWAAuthCache     # Android Keystore (most secure)
```

**Default Flow with Cache:**
1. App launches → check cache for valid auth token for current wallet
2. Token found & not expired → skip authorize, go straight to `reauthorize`
3. Token expired / not found → full `authorize` flow
4. On deauthorize → clear cached token

### 3.2 Deliverable 2 — Comprehensive Documentation

Built with **Docusaurus 3.x**, deployed on Netlify.

Sections:
- **Getting Started** — Prerequisites, installation, first connection
- **Core Concepts** — MWA protocol, Android intents, Godot plugins
- **API Reference** — Every method, parameter, return value, signal
- **Authorization Cache** — How to configure, swap backends, security notes
- **Session Management** — Disconnect/reconnect patterns, best practices
- **Wallet Picker** — UI patterns for Phantom, Backpack, Solflare
- **Migration Guide** — Upgrading from old Godot SDK
- **Examples** — Code snippets for common use cases
- **FAQ** — Troubleshooting, common errors

### 3.3 Deliverable 3 — Example Godot Android App

A complete open-source Godot 4.x Android game/app called **"SolanaQuest"** that demonstrates every SDK feature. Visual design inspired by the neobrutalism + glassmorphism aesthetic of Phantom Wallet, Jupiter, and Meteora.

**Screens:**
1. **Splash / Onboarding** — Brand intro with animated logo
2. **Wallet Picker** — Choose from Phantom, Backpack, Solflare
3. **Authorization Flow** — Authorize with cache indication
4. **Dashboard** — Connected wallet info, SOL balance, recent txs
5. **Sign Transaction** — Build + sign a test transaction
6. **Sign & Send** — Sign and broadcast to devnet
7. **Sign Message** — Personal sign demo (off-chain)
8. **Get Capabilities** — Display wallet capabilities
9. **Auth Cache Demo** — Visual cache status, clear, test reconnect
10. **Disconnect / Deauthorize** — Full session teardown

---

## 4. TECHNICAL ARCHITECTURE

### 4.1 Component Layers

```
┌─────────────────────────────────────────────────────┐
│                  GODOT GAME / APP                   │
│              (GDScript / Godot 4.x)                 │
├─────────────────────────────────────────────────────┤
│             GodotMWA SDK (GDScript Layer)            │
│  MobileWalletAdapter | MWAAuthCache | MWAIdentity   │
├─────────────────────────────────────────────────────┤
│           Godot Android Plugin (Kotlin)              │
│    MWAPlugin.kt | MWABridge.kt | AuthCacheImpl.kt   │
├─────────────────────────────────────────────────────┤
│    Solana Mobile MWA Android SDK (Kotlin/Java)       │
│ com.solanamobile:mobile-wallet-adapter-clientlib-ktx │
├─────────────────────────────────────────────────────┤
│              Android OS / Wallet Apps                │
│         Phantom | Backpack | Solflare                │
└─────────────────────────────────────────────────────┘
```

### 4.2 Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Game Engine | Godot Engine | 4.2+ |
| Scripting | GDScript | Godot 4.x |
| Android Plugin | Kotlin | 1.9+ |
| MWA Android SDK | `com.solanamobile:mobile-wallet-adapter-clientlib-ktx` | latest |
| Android SDK | Android API | 28+ |
| Build System | Gradle | 8.x |
| RPC Library | Solana SDK for Android (optional) | latest |
| Cache (Default) | Android EncryptedSharedPreferences | — |
| Cache (Secure) | Android Keystore | — |
| Docs Framework | Docusaurus | 3.x |
| Docs Deploy | Netlify | — |
| CI/CD | GitHub Actions | — |
| Backend (RPC Proxy) | Fastify on Railway | — |

### 4.3 Repository Structure

```
godot-mobile-wallet-adapter/
├── addons/
│   └── mobile_wallet_adapter/
│       ├── plugin.cfg
│       ├── MobileWalletAdapter.gd       # Main SDK class
│       ├── MWAAuthCache.gd              # Cache base class
│       ├── MWAMemoryCache.gd            # In-memory implementation
│       ├── MWAFileCache.gd              # File-based implementation
│       ├── MWASecureCache.gd            # Android Keystore implementation
│       ├── MWAIdentity.gd               # Identity object
│       ├── MWASendOptions.gd            # Transaction send options
│       ├── MWAAuthToken.gd              # Auth token data object
│       └── MWAError.gd                  # Error codes & messages
├── android/
│   └── plugin/
│       ├── src/main/kotlin/
│       │   └── com/godotmwa/
│       │       ├── MWAPlugin.kt          # Godot plugin entry
│       │       ├── MWABridge.kt          # MWA SDK bridge
│       │       ├── AuthCacheImpl.kt      # Android cache impl
│       │       └── KeystoreCache.kt      # Keystore impl
│       └── build.gradle
├── example/
│   └── solanaquest/                      # Example Godot app
│       ├── project.godot
│       ├── scenes/
│       │   ├── Splash.tscn
│       │   ├── WalletPicker.tscn
│       │   ├── Dashboard.tscn
│       │   ├── SignTransaction.tscn
│       │   ├── SignMessage.tscn
│       │   ├── AuthCache.tscn
│       │   └── Settings.tscn
│       ├── scripts/
│       ├── assets/
│       │   ├── fonts/
│       │   ├── shaders/   (glassmorphism effects)
│       │   └── themes/
│       └── android/
├── docs/
│   ├── docusaurus.config.js
│   └── docs/
│       ├── getting-started.md
│       ├── api-reference.md
│       ├── auth-cache.md
│       └── examples.md
├── tests/
│   └── unit/
├── .github/
│   └── workflows/
│       ├── build.yml
│       └── docs-deploy.yml
└── README.md
```

---

## 5. API PARITY MATRIX (Detailed)

### 5.1 React Native SDK → Godot SDK Method Mapping

#### `authorize(params)`
```typescript
// React Native
const auth = await wallet.authorize({
  cluster: 'mainnet-beta',
  identity: { name: 'My dApp', uri: 'https://...', icon: 'favicon.ico' },
  auth_token: undefined  // optional re-auth token
});
// Returns: { auth_token, accounts: [{address, label, chains}], wallet_uri_base }
```
```gdscript
# Godot target
var identity = MWAIdentity.new("My dApp", "https://...", "favicon.ico")
mwa.authorize("mainnet-beta", identity)
# Signal: authorized(auth_token: String, accounts: Array[MWAAccount])
```

#### `reauthorize(params)`
```typescript
// React Native
const reauth = await wallet.reauthorize({
  auth_token: 'existing-token',
  identity: { name: 'My dApp', uri: 'https://...', icon: 'favicon.ico' }
});
```
```gdscript
# Godot target
mwa.reauthorize(auth_token, identity)
# Signal: reauthorized(auth_token: String, accounts: Array[MWAAccount])
```

#### `deauthorize(params)`
```typescript
// React Native
await wallet.deauthorize({ auth_token: 'token' });
```
```gdscript
# Godot target
mwa.deauthorize(auth_token)
# Signal: deauthorized()
```

#### `signTransactions(params)`
```typescript
// React Native
const signed = await wallet.signTransactions({
  transactions: [base64EncodedTx1, base64EncodedTx2]
});
```
```gdscript
# Godot target
mwa.sign_transactions([tx_bytes_1, tx_bytes_2])
# Signal: transaction_signed(signed_txs: Array[PackedByteArray])
```

#### `signAndSendTransactions(params)`
```typescript
// React Native
const result = await wallet.signAndSendTransactions({
  transactions: [tx],
  options: { min_context_slot: 12345 }
});
```
```gdscript
# Godot target
var opts = MWASendOptions.new()
opts.min_context_slot = 12345
mwa.sign_and_send_transactions([tx_bytes], opts)
# Signal: transaction_sent(signatures: Array[String])
```

#### `signMessages(params)`
```typescript
// React Native
const signed = await wallet.signMessages({
  messages: [messageBytes],
  addresses: [walletAddress]
});
```
```gdscript
# Godot target
mwa.sign_messages([message_bytes], [wallet_address_bytes])
# Signal: message_signed(signed_messages: Array[PackedByteArray])
```

#### `getCapabilities()`
```typescript
// React Native
const caps = await wallet.getCapabilities();
// Returns: { supports_clone_authorization, supports_sign_and_send_transactions, max_transactions_per_request, max_messages_per_request }
```
```gdscript
# Godot target
mwa.get_capabilities()
# Signal: capabilities_received(caps: MWACapabilities)
```

---

## 6. AUTHORIZATION CACHE — DEEP DESIGN

### 6.1 MWAAuthToken Data Object

```gdscript
class_name MWAAuthToken extends Resource

@export var token: String = ""
@export var wallet_uri_base: String = ""
@export var accounts: Array[MWAAccount] = []
@export var created_at: int = 0    # Unix timestamp
@export var expires_at: int = 0    # 0 = never
@export var wallet_name: String = ""

func is_expired() -> bool:
    if expires_at == 0: return false
    return Time.get_unix_time_from_system() > expires_at

func is_valid() -> bool:
    return token != "" and not is_expired()
```

### 6.2 Default File Cache Implementation

```gdscript
class_name MWAFileCache extends MWAAuthCache

const CACHE_DIR = "user://mwa_auth/"
const CACHE_FILE = "auth_tokens.dat"

func save_auth_token(key: String, token: MWAAuthToken) -> bool:
    var cache = _load_cache_file()
    cache[key] = {
        "token": token.token,
        "wallet_uri_base": token.wallet_uri_base,
        "accounts": token.accounts.map(func(a): return a.to_dict()),
        "created_at": token.created_at,
        "expires_at": token.expires_at,
        "wallet_name": token.wallet_name
    }
    return _save_cache_file(cache)

func load_auth_token(key: String) -> MWAAuthToken:
    var cache = _load_cache_file()
    if not cache.has(key): return null
    var data = cache[key]
    var t = MWAAuthToken.new()
    t.token = data.get("token", "")
    t.expires_at = data.get("expires_at", 0)
    if not t.is_valid(): 
        clear_auth_token(key)
        return null
    return t
```

### 6.3 Cache Integration Flow

```
App Launch
    │
    ▼
Check MWAAuthCache for stored token
    │
    ├── Token Found & Valid ──► Attempt reauthorize()
    │                               │
    │                               ├── Success ──► Connected (no wallet popup)
    │                               └── Fail ──► Full authorize() flow
    │
    └── No Token ──► Full authorize() flow
                         │
                         └── On Success ──► Save token to cache
```

---

## 7. EXAMPLE APP — "SOLANAQUEST" DESIGN SPEC

### 7.1 Visual Design Language

**Primary Aesthetic:** Neobrutalism + Glassmorphism hybrid (matching Phantom/Jupiter/Meteora)

**Color Palette:**
- Background: `#0D0F14` (near-black, space feel)
- Surface: `rgba(255,255,255,0.06)` (frosted glass cards)
- Glass Border: `rgba(255,255,255,0.12)`
- Primary Accent: `#9945FF` (Solana Purple)
- Secondary Accent: `#14F195` (Solana Green/Teal)
- Warning: `#FFB938`
- Error: `#FF4444`
- Text Primary: `#FFFFFF`
- Text Secondary: `rgba(255,255,255,0.6)`

**Typography:**
- Display: Space Grotesk Bold (headings)
- Body: DM Sans (body text)  
- Mono: JetBrains Mono (addresses, hashes)

**Motion Design:**
- Entry animations: 300ms ease-out fade + slide
- Glassmorphism: backdrop-filter blur(20px) + saturate(180%)
- Neobrutalist shadows: 3px/4px hard offset shadows on key cards
- Wallet picker: spring bounce on hover/select
- Transaction status: animated progress rings

### 7.2 Godot Shader — Glassmorphism Card

```gdscript
# Glass card shader for Godot 4
shader_type canvas_item;

uniform float blur_amount: hint_range(0.0, 20.0) = 8.0;
uniform vec4 tint_color: source_color = vec4(1.0, 1.0, 1.0, 0.06);
uniform float border_opacity: hint_range(0.0, 1.0) = 0.12;

void fragment() {
    vec4 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    COLOR = mix(screen, tint_color, tint_color.a);
    
    // Add frosted border
    float border = max(
        step(0.98, UV.x) + step(UV.x, 0.02),
        step(0.98, UV.y) + step(UV.y, 0.02)
    );
    COLOR += vec4(1.0, 1.0, 1.0, border_opacity) * border;
}
```

---

## 8. INFRASTRUCTURE & BACKEND

### 8.1 Architecture Overview (Minimal)

The SDK itself is client-side only. The companion backend is optional but recommended for:
- **RPC Proxy**: Rate-limit protection for Solana RPC calls
- **Analytics**: Track SDK adoption (privacy-respecting)

### 8.2 Backend Stack

```
Railway (Production)
└── Fastify Server (Node.js)
    ├── /api/rpc         → Solana RPC proxy (devnet/mainnet)
    ├── /api/health      → Health check
    └── /api/version     → Latest SDK version info

Netlify
└── Documentation site (Docusaurus)
    ├── docs.godotmwa.dev
    └── Auto-deploy from /docs on main branch

GitHub
└── godot-mobile-wallet-adapter (Public repo)
    ├── Releases: .zip (Godot plugin)
    └── CI: Build + test + doc deploy
```

### 8.3 Fastify Server Structure

```
backend/
├── src/
│   ├── server.ts          # Fastify app entry
│   ├── routes/
│   │   ├── rpc.ts         # Solana RPC proxy
│   │   ├── health.ts      # Health check
│   │   └── version.ts     # Version info
│   ├── plugins/
│   │   ├── cors.ts
│   │   ├── rateLimit.ts
│   │   └── logger.ts
│   └── config.ts
├── Dockerfile
└── railway.toml
```

---

## 9. GRANT APPLICATION PROPOSAL TEXT

### Problem (for Airtable submission)

The Godot game engine has approximately 2 million active developers worldwide, making it the most popular open-source alternative to Unity/Unreal. With Unity's controversial fee changes in 2023 pushing many studios to Godot, this community has grown rapidly. Yet Solana has no production-ready wallet integration for Godot on Android.

The existing Godot MWA SDK is a proof-of-concept that lacks critical functionality: no `reauthorize`, `deauthorize`, `signMessages`, or `getCapabilities` methods; no authorization token caching (forcing wallet approval popups on every session); and no reliable disconnect/reconnect flow. This prevents any Godot game developer from shipping a Solana-integrated game on Android with acceptable UX.

### Proposed Solution (for Airtable submission)

I will deliver three interconnected components that bring Godot's Solana wallet integration to full parity with the React Native SDK:

1. **SDK Improvements**: Complete the Godot MWA SDK with all missing methods, reliable session management, and an extensible authorization token cache using Android EncryptedSharedPreferences by default (swappable to Android Keystore). Developers get automatic token caching — the wallet approval popup only appears once, just like in production React Native apps.

2. **Documentation**: A Docusaurus-based documentation site (deployed to Netlify) with API reference, installation guide, architecture docs, migration guide, and code examples matching the quality of the existing React Native documentation.

3. **Example App (SolanaQuest)**: An open-source Godot 4.x Android app that demonstrates every SDK method and the authorization cache. The app features a modern design (neobrutalism + glassmorphism) matching Phantom/Jupiter aesthetic standards, making it an attractive showcase for the Solana gaming ecosystem.

---

## 10. TIMELINE & MILESTONES

| Milestone | Deliverable | Target Week |
|-----------|-------------|-------------|
| M1 | Dev environment, SDK audit, API parity matrix | Week 2 |
| M2 | All missing SDK methods implemented (GDScript + Kotlin) | Week 5 |
| M3 | Auth token cache (Memory + File + Keystore backends) | Week 6 |
| M4 | Documentation site live on Netlify | Week 8 |
| M5 | Example app (all screens + all API methods) | Week 10 |
| M6 | Tests passing, CI green, open-source release | Week 11 |
| M7 | Grant submission package (video demo, repo, docs) | Week 12 |

---

## 11. RISK REGISTER

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Godot Android plugin API changes in 4.3/4.4 | Medium | High | Target stable 4.2 LTS first, add 4.3 compat layer |
| MWA Android SDK breaking changes | Low | High | Pin SDK version, add integration tests |
| Wallet app (Phantom) intent handling edge cases | Medium | Medium | Test on real devices, handle gracefully |
| Auth token format changes across wallets | Medium | Medium | Version auth tokens in cache format |
| Performance issues with cache on cold start | Low | Low | Cache read is async, non-blocking |

---

*End of Pre-PRD Document*
*Francisco (Franny) · Portugal · March 2026*
