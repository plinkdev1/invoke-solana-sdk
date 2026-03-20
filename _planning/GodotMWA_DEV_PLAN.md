# GodotMWA — Hyperdetailed Development Plan
## All Phases · Epics · Tasks · Subtasks

---

## PHASE 0 — FOUNDATION & AUDIT (Weeks 1–2)

### Epic 0.1: Developer Environment Setup

**Task 0.1.1 — Godot Engine Installation**
- [ ] Install Godot 4.2+ (stable branch) on dev machine
- [ ] Install Android Studio (Giraffe+) with Android SDK 34
- [ ] Configure ANDROID_SDK_ROOT and ANDROID_NDK_ROOT env vars
- [ ] Download Godot Android export templates
- [ ] Test basic Godot → Android export pipeline (hello world APK)
- [ ] Set up USB debugging with test Android device (API 28+)

**Task 0.1.2 — Kotlin/Java Plugin Dev Environment**
- [ ] Create new Android library project in Android Studio
- [ ] Add Godot Android plugin skeleton (`com.google.android.exoplayer` replaced by Godot's `GodotPlugin`)
- [ ] Reference: https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html
- [ ] Set up Gradle with: `com.solanamobile:mobile-wallet-adapter-clientlib-ktx:latest`
- [ ] Build .aar file and import into Godot project
- [ ] Confirm plugin signals route GDScript ↔ Kotlin

**Task 0.1.3 — Repository Setup**
- [ ] Create GitHub repo: `godot-mobile-wallet-adapter`
- [ ] Initialize with LICENSE (Apache 2.0 — Solana grant standard)
- [ ] Create branch strategy: `main`, `develop`, `feature/*`, `fix/*`
- [ ] Add `.gitignore` for Godot + Android
- [ ] Set up GitHub Actions CI skeleton
- [ ] Add CONTRIBUTING.md
- [ ] Add CODE_OF_CONDUCT.md

**Task 0.1.4 — Existing SDK Analysis**
- [ ] Clone existing Godot MWA SDK
- [ ] Document all existing GDScript classes and methods
- [ ] Document existing Kotlin plugin code
- [ ] Run existing SDK on test device — record all failures
- [ ] Create bug report list

---

### Epic 0.2: API Parity Audit

**Task 0.2.1 — React Native SDK Deep Dive**
- [ ] Clone `@solana-mobile/mobile-wallet-adapter-protocol-web3js`
- [ ] Document every public method with TypeScript signatures
- [ ] Document all callback/promise patterns
- [ ] Document all error types and codes
- [ ] Document all data types (Auth, Account, SendOptions, Capabilities)
- [ ] Note: `transact()` wrapper pattern

**Task 0.2.2 — Create API Parity Matrix**
- [ ] Build spreadsheet: RN method → Godot equivalent → gap status
- [ ] For each gap, define: (a) GDScript signature, (b) Kotlin bridge method needed, (c) complexity estimate (S/M/L/XL)
- [ ] Prioritize by grant deliverable importance
- [ ] Output: `docs/API_PARITY_MATRIX.md`

**Task 0.2.3 — Auth Cache Research**
- [ ] Research `EncryptedSharedPreferences` Android API
- [ ] Research Android Keystore for highly sensitive creds
- [ ] Research Godot's built-in `ConfigFile` for fallback
- [ ] Map cache key strategy: wallet_name + app_id → token
- [ ] Define token expiry logic (wallet-side vs. app-side)

---

## PHASE 1 — CORE SDK DEVELOPMENT (Weeks 3–6)

### Epic 1.1: GDScript Layer — Complete API

**Task 1.1.1 — Data Objects (GDScript)**
- [ ] `MWAIdentity.gd` — name, uri, icon fields + validation
- [ ] `MWAAccount.gd` — address (PackedByteArray), label, chains
- [ ] `MWAAuthToken.gd` — token, wallet_uri_base, accounts, timestamps
- [ ] `MWASendOptions.gd` — min_context_slot optional field
- [ ] `MWACapabilities.gd` — all capability booleans + limits
- [ ] `MWAError.gd` — error codes enum matching MWA spec

**Task 1.1.2 — `MobileWalletAdapter.gd` Core Class**
```
Subtasks:
- [ ] Class definition, signals declaration
- [ ] `authorize(cluster, identity)` method
- [ ] `reauthorize(auth_token, identity)` method
- [ ] `deauthorize(auth_token)` method
- [ ] `disconnect()` method
- [ ] `sign_transactions(txs: Array[PackedByteArray])` method
- [ ] `sign_and_send_transactions(txs, opts)` method
- [ ] `sign_messages(messages, addresses)` method
- [ ] `get_capabilities()` method
- [ ] `clone_authorization(auth_token)` method (advanced)
- [ ] Internal state machine: IDLE → CONNECTING → AUTHORIZED → DISCONNECTING
- [ ] Error signal emission with proper MWAError codes
- [ ] Plugin availability check (graceful fail on non-Android)
- [ ] Signal routing from Kotlin plugin → GDScript signals
```

**Task 1.1.3 — Auth Cache GDScript Layer**
- [ ] `MWAAuthCache.gd` base class (interface definition)
- [ ] `MWAMemoryCache.gd` — Dictionary-based in-memory cache
- [ ] `MWAFileCache.gd` — Godot `user://` path storage (JSON)
- [ ] `MWASecureCache.gd` — Delegates to Android Keystore via plugin
- [ ] Cache manager singleton: `MWACacheManager.gd`
- [ ] Auto-detect: use SecureCache on Android, FileCache on desktop

**Task 1.1.4 — Wallet Picker Helper**
- [ ] `MWAWalletPicker.gd` — detect installed wallets via Android intent
- [ ] Return list: `[{name: "Phantom", package: "app.phantom", installed: true}]`
- [ ] `is_phantom_installed()`, `is_backpack_installed()`, `is_solflare_installed()` helpers

---

### Epic 1.2: Kotlin Plugin — Android Bridge

**Task 1.2.1 — Plugin Foundation**
- [ ] `MWAPlugin.kt` — extends `GodotPlugin`
- [ ] Register all plugin methods with `@UsedByGodot` annotation
- [ ] Emit signals via `emitSignal()` for all async results
- [ ] Handle Activity lifecycle (onResume, onPause for MWA intent handling)
- [ ] Coroutine scope setup with `lifecycleScope`
- [ ] Error handling: catch all MWA exceptions, emit `mwa_error` signal

**Task 1.2.2 — MWA Session Bridge**
```
Subtasks:
- [ ] `authorize(cluster, name, uri, icon)` → calls MWA SDK authorize
- [ ] `reauthorize(auth_token, name, uri, icon)` → calls MWA SDK reauthorize
- [ ] `deauthorize(auth_token)` → calls MWA SDK deauthorize
- [ ] `signTransactions(transactions_base64: Array<String>)` → sign
- [ ] `signAndSendTransactions(txs_base64, min_context_slot)` → sign+send
- [ ] `signMessages(messages_base64, addresses_base64)` → sign messages
- [ ] `getCapabilities()` → return capabilities as JSON string
- [ ] Handle `AuthorizationNotValidException` → emit reconnect needed signal
- [ ] Handle `RequestDeclinedException` → emit user_declined signal
- [ ] Handle `IOException` → emit connection_error signal
```

**Task 1.2.3 — Auth Cache Android Implementation**
- [ ] `AuthCacheImpl.kt` — EncryptedSharedPreferences backend
  - `saveAuthToken(key, tokenJson)`
  - `loadAuthToken(key): String?`
  - `clearAuthToken(key)`
  - `clearAll()`
- [ ] `KeystoreCacheImpl.kt` — Android Keystore backend (high security)
- [ ] Plugin methods: `cacheGet(key)`, `cacheSet(key, value)`, `cacheClear(key)`, `cacheClearAll()`

**Task 1.2.4 — Wallet Detection**
- [ ] Query Android PackageManager for installed wallet apps
- [ ] Return JSON array of `{name, packageName, installed, version}`
- [ ] Handle permissions gracefully (Android 11+ package visibility)

**Task 1.2.5 — Build Pipeline**
- [ ] Gradle config for .aar build
- [ ] Copy .aar + .gdap to `addons/mobile_wallet_adapter/android/`
- [ ] GitHub Actions: auto-build on push to `develop`
- [ ] Validate on API 28, 30, 33, 34 via GitHub Actions emulator matrix

---

### Epic 1.3: Session Management Flows

**Task 1.3.1 — Full Session State Machine**
```gdscript
# States: IDLE, CONNECTING, AUTHORIZING, AUTHORIZED, REAUTHORIZING, 
#          DEAUTHORIZING, DISCONNECTING, ERROR
```
- [ ] Implement state transitions with validation (can't reauthorize when IDLE)
- [ ] Expose `get_state()` → String for UI
- [ ] Expose `is_connected()` → bool convenience
- [ ] Expose `get_current_account()` → MWAAccount or null

**Task 1.3.2 — Reconnect Flow**
- [ ] On app resume: check cache → attempt reauthorize
- [ ] If reauthorize fails with `AuthorizationNotValid`: clear cache, go to full authorize
- [ ] Expose `try_reconnect()` method for manual trigger
- [ ] Signal: `reconnect_attempted(success: bool)`

**Task 1.3.3 — Clean Disconnect Flow**
- [ ] `disconnect()` → closes MWA session (doesn't deauthorize)
- [ ] `full_logout()` → deauthorizes + clears cache + resets state
- [ ] Handle wallet app killed mid-session gracefully
- [ ] Timeout: 30s on all wallet operations, emit `timeout` signal if exceeded

---

## PHASE 2 — DOCUMENTATION (Weeks 7–8)

### Epic 2.1: Docusaurus Setup

**Task 2.1.1 — Site Initialization**
- [ ] `npx create-docusaurus@latest docs classic --typescript`
- [ ] Configure `docusaurus.config.js`: title, tagline, GitHub URL
- [ ] Custom theme: dark mode default, Solana-inspired purple/green accents
- [ ] Install `@docusaurus/plugin-content-docs`, `prism-react-renderer`
- [ ] Configure Prism for GDScript syntax highlighting (custom lang definition)
- [ ] Add Algolia DocSearch (free for open-source)

**Task 2.1.2 — Netlify Deployment**
- [ ] Connect GitHub repo → Netlify
- [ ] Auto-deploy on push to `main`
- [ ] Configure custom domain: `docs.godotmwa.dev` (or similar)
- [ ] Set `netlify.toml` for build command

**Task 2.1.3 — GitHub Actions: Docs CI**
- [ ] On PR: `npm run build` docs → fail PR if broken
- [ ] On merge to main: deploy to Netlify production

---

### Epic 2.2: Documentation Content

**Task 2.2.1 — Getting Started Guide**
- [ ] Prerequisites (Godot 4.2+, Android Studio, Android device)
- [ ] Installation: download plugin .zip from GitHub Release
- [ ] Import into Godot project (step by step with screenshots)
- [ ] Add to `project.godot` settings
- [ ] "Hello Phantom" — 30-line connect + show address example

**Task 2.2.2 — Core Concepts**
- [ ] What is Mobile Wallet Adapter? (architecture diagram)
- [ ] How Android intents work with wallet apps
- [ ] Authorization vs. Reauthorization vs. Deauthorization
- [ ] What the auth token cache is and why it matters
- [ ] Supported wallets table (Phantom, Backpack, Solflare + minimum versions)

**Task 2.2.3 — API Reference**
- [ ] Auto-generate from GDScript comments + manual review
- [ ] Every method: signature, parameters, return/signals, errors, example
- [ ] Every signal: parameters, when emitted, example handler
- [ ] Every class: fields, constructor, methods
- [ ] Error codes table with descriptions and resolution

**Task 2.2.4 — Auth Cache Guide**
- [ ] Default behavior (file cache, auto-enabled)
- [ ] How to use Memory cache (testing/development)
- [ ] How to use Secure cache (production, Android Keystore)
- [ ] How to implement a custom cache backend (interface)
- [ ] Security considerations and best practices

**Task 2.2.5 — Session Management Guide**
- [ ] Connect flow diagram (first-time vs. returning user)
- [ ] Reconnect on app resume pattern
- [ ] Disconnect vs. Deauthorize — when to use each
- [ ] Handling wallet app not installed
- [ ] Handling timeout and network errors

**Task 2.2.6 — Migration Guide (Old SDK → New)**
- [ ] What changed in the API
- [ ] Step-by-step migration for each method
- [ ] Breaking changes highlighted in red callouts

---

## PHASE 3 — EXAMPLE APP "SOLANAQUEST" (Weeks 9–11)

### Epic 3.1: Godot Project Foundation

**Task 3.1.1 — Project Setup**
- [ ] Create new Godot 4.2 project: `example/solanaquest/`
- [ ] Add GodotMWA plugin
- [ ] Configure Android export preset
- [ ] Set min SDK 28, target SDK 34
- [ ] Configure app permissions (INTERNET)
- [ ] Configure app identity (name, icon, package: `dev.godotmwa.solanaquest`)

**Task 3.1.2 — Design System**
- [ ] Create Godot Theme resource with all colors, fonts
- [ ] Import fonts: Space Grotesk (display), DM Sans (body), JetBrains Mono (mono)
- [ ] Create reusable StyleBoxes for glass cards, primary buttons, secondary buttons
- [ ] Create GlassCard scene with shader applied
- [ ] Create WalletBadge scene (Phantom/Backpack/Solflare logos + name)
- [ ] Create AddressChip scene (truncated address + copy button)
- [ ] Create TxStatusIndicator (animated ring progress)
- [ ] Create BottomSheet scene (animated slide-up overlay)

**Task 3.1.3 — Navigation Architecture**
- [ ] Main scene with SceneManager singleton
- [ ] `SceneManager.gd`: `push_scene(path)`, `pop_scene()`, `replace_scene(path)`
- [ ] Navigation stack with back button support
- [ ] Transition animations: slide-left for push, slide-right for pop, fade for replace

---

### Epic 3.2: App Screens Implementation

**Task 3.2.1 — Splash Screen**
- [ ] Godot logo + "SolanaQuest" wordmark centered
- [ ] Animated gradient background (purple → teal aurora effect)
- [ ] Particle system: floating Solana coins (custom particles)
- [ ] Auto-advance after 2.5s → check auth cache → navigate

**Task 3.2.2 — Wallet Picker Screen**
- [ ] "Connect Your Wallet" heading
- [ ] List of detected wallets (Phantom, Backpack, Solflare)
- [ ] Each wallet: icon + name + installed badge (or "Get on Play Store" link)
- [ ] Glassmorphism cards per wallet with neobrutalist 4px shadow
- [ ] Select wallet → trigger `mwa.authorize()` with that wallet's deeplink hint
- [ ] Loading state: spinner overlay on selected card

**Task 3.2.3 — Authorization Result Screen**
- [ ] Show: wallet connected, truncated address, wallet name
- [ ] Show: "Session cached ✓" or "New session" indicator
- [ ] Continue → Dashboard

**Task 3.2.4 — Dashboard Screen**
- [ ] Header: wallet name + avatar (generated from address)
- [ ] Balance card (SOL balance via devnet RPC)
- [ ] Quick actions grid: Sign Tx, Sign & Send, Sign Msg, Get Caps
- [ ] Recent transactions feed (mock data for demo)
- [ ] Auth cache status widget (bottom)
- [ ] Settings gear → Settings screen
- [ ] Disconnect button

**Task 3.2.5 — Sign Transaction Demo**
- [ ] Build a dummy devnet transaction (transfer 0.001 SOL to self)
- [ ] Show raw transaction bytes (hex)
- [ ] "Request Signature" button → `mwa.sign_transactions([tx_bytes])`
- [ ] Signed tx display with copy button
- [ ] Success/error state

**Task 3.2.6 — Sign & Send Demo**
- [ ] Same as 3.2.5 but calls `mwa.sign_and_send_transactions()`
- [ ] Show transaction signature (base58)
- [ ] "View on Solscan" deeplink

**Task 3.2.7 — Sign Message Demo**
- [ ] Text input for custom message
- [ ] Pre-filled: "GodotMWA SDK Demo - {timestamp}"
- [ ] "Sign Message" → `mwa.sign_messages()`
- [ ] Show signed bytes + verify locally

**Task 3.2.8 — Capabilities Screen**
- [ ] "Get Capabilities" button → `mwa.get_capabilities()`
- [ ] Display result in formatted table:
  - supports_clone_authorization
  - supports_sign_and_send_transactions
  - max_transactions_per_request
  - max_messages_per_request

**Task 3.2.9 — Auth Cache Demo Screen**
- [ ] Live cache status panel: token present / token expired / no token
- [ ] Token info: wallet, created_at, expires_at
- [ ] Buttons: "Clear Cache", "Force Reconnect", "Test Reauthorize"
- [ ] Animated flow diagram showing cache → reauthorize path
- [ ] Console log panel showing cache operations

**Task 3.2.10 — Settings Screen**
- [ ] Network select: Devnet / Testnet / Mainnet
- [ ] Cache backend select: Memory / File / Secure Keystore
- [ ] RPC endpoint (default Solana public devnet, or custom)
- [ ] App version, SDK version
- [ ] "Disconnect & Clear All" danger zone

---

### Epic 3.3: Backend RPC Proxy (Optional/Bonus)

**Task 3.3.1 — Fastify Setup on Railway**
- [ ] Init: `npm init fastify-app backend`
- [ ] Add plugins: `@fastify/cors`, `@fastify/rate-limit`, `fastify-plugin`
- [ ] Route: `POST /api/rpc` → proxy to Solana RPC
- [ ] Rate limiting: 100 req/min per IP
- [ ] Deploy to Railway with environment variable for RPC_URL

**Task 3.3.2 — Railway Configuration**
- [ ] `railway.toml` with build command
- [ ] Environment variables: PORT, SOLANA_RPC_DEVNET, SOLANA_RPC_MAINNET
- [ ] Health check endpoint `/api/health`
- [ ] Auto-scale: min 1 instance, max 3

---

### Epic 3.4: Open Source Release Preparation

**Task 3.4.1 — README.md**
- [ ] Hero banner (custom designed)
- [ ] Badges: License, CI status, Godot version, Platform
- [ ] Quick install (5-step)
- [ ] Code example (30 lines, covers connect + sign)
- [ ] Screenshots of example app
- [ ] Links to docs, example, changelog

**Task 3.4.2 — GitHub Release**
- [ ] Tag: `v1.0.0`
- [ ] Release notes with changelog
- [ ] Attach: `godot-mwa-plugin-v1.0.0.zip` (ready-to-import plugin)
- [ ] Attach: `solanaquest-demo-v1.0.0.apk` (sideloadable demo)

**Task 3.4.3 — Demo Video**
- [ ] Record: phone screen + voice narration
- [ ] Show: fresh install → Phantom picks up → authorize → cache → kill app → reopen → auto-reconnect (no popup)
- [ ] Show: sign tx → sign & send → sign message
- [ ] Upload to YouTube, embed in README + grant submission

---

## PHASE 4 — QA & GRANT SUBMISSION (Week 12)

### Epic 4.1: Testing

**Task 4.1.1 — Unit Tests**
- [ ] Test MWAAuthToken.is_valid() and is_expired()
- [ ] Test MWAFileCache save/load/clear cycle
- [ ] Test state machine transitions (valid + invalid)
- [ ] Test error code mapping

**Task 4.1.2 — Integration Tests (Real Device)**
- [ ] Test authorize flow with Phantom installed
- [ ] Test authorize flow with Backpack installed
- [ ] Test authorize flow with no wallet installed (graceful error)
- [ ] Test reauthorize from cache (no wallet popup expected)
- [ ] Test sign_transactions with devnet tx
- [ ] Test sign_and_send_transactions on devnet
- [ ] Test sign_messages
- [ ] Test deauthorize flow
- [ ] Test disconnect flow
- [ ] Test: kill app mid-authorize → reopen → recover
- [ ] Test: cache clear → reconnect requires new authorize

**Task 4.1.3 — Cross-Device Testing**
- [ ] Samsung Galaxy (Android 12)
- [ ] Pixel (Android 14)
- [ ] Budget device (Android 10, Qualcomm)
- [ ] Test with each wallet: Phantom, Backpack, Solflare

---

### Epic 4.2: Grant Submission Package

**Task 4.2.1 — Airtable Application**
- [ ] Fill "Problem" field (from Section 9 of Pre-PRD)
- [ ] Fill "Proposed Solution" field
- [ ] Attach GitHub repo URL
- [ ] Attach docs site URL
- [ ] Attach demo video URL
- [ ] Attach APK download link

**Task 4.2.2 — Portfolio Assets**
- [ ] Screenshots: 10 app screens in mockup frames
- [ ] Architecture diagram (high-res PNG)
- [ ] API comparison table (rendered)
- [ ] Test evidence: CI passing screenshots

---

## AGENT WORKFLOW GUIDE (Claude Code Terminal)

### How to use this plan with Claude Code

Each task group can be fed to Claude Code as a standalone prompt. Use this pattern:

```
CONTEXT: I'm building the GodotMWA SDK for the Solana grant.
CURRENT PHASE: [Phase X — Epic Y]
CURRENT TASK: [Task Z.Z.Z description]
REPO STATE: [brief description of what's done so far]

Please implement [specific subtask] following these constraints:
- GDScript 4.x syntax only (no GDScript 2)
- Kotlin coroutines for async (lifecycleScope)
- All signals snake_case
- All errors emit via 'error' signal, not exceptions
```

### Recommended Claude Code Session Order

1. Session 1: Epic 0.1 + 0.2 (environment + audit)
2. Session 2: Epic 1.1.1 + 1.1.2 (GDScript data objects + main class skeleton)
3. Session 3: Epic 1.2.1 + 1.2.2 (Kotlin plugin + session bridge)
4. Session 4: Epic 1.1.3 + 1.2.3 (auth cache both layers)
5. Session 5: Epic 1.3 (session state machine)
6. Session 6: Epic 2.1 + 2.1.2 (Docusaurus setup + Netlify)
7. Session 7: Epic 2.2.1–2.2.3 (docs content, first half)
8. Session 8: Epic 2.2.4–2.2.6 (docs content, second half)
9. Session 9: Epic 3.1 (Godot example project + design system)
10. Session 10: Epic 3.2.1–3.2.5 (app screens 1-5)
11. Session 11: Epic 3.2.6–3.2.10 (app screens 6-10)
12. Session 12: Epic 3.3 + 3.4 (backend + open source release)
13. Session 13: Epic 4.1 (testing)
14. Session 14: Epic 4.2 (grant submission)

---

*GodotMWA Development Plan v1.0 · Francisco (Franny) · Portugal · March 2026*
