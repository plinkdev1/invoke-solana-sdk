# INVOKE SDK — AGENT HANDOFF DOCUMENT
## Session Handoff · March 2026 · Francisco (Franny) · Portugal

---

## PROJECT IDENTITY
- Project name: INVOKE (formerly GodotMWA / SolanaQuest — deprecated)
- SDK name: Invoke
- Example app: InvokeQuest
- Repo: https://github.com/plinkdev1/invoke-solana-sdk (PRIVATE until grant delivery)
- Local path: C:\PROJECTS\Invoke_Solana_App
- Branch strategy: all work on develop, merge to main after each phase
- Terminal: PowerShell on Windows

---

## GRANT CONTEXT
Solana Foundation grant — ,000 USD. Three non-negotiable deliverables:
1. Invoke SDK — GDScript + Kotlin plugin, full MWA API parity, extensible auth token cache
2. Documentation — Docusaurus site deployed to Netlify
3. InvokeQuest — Example Godot Android app showcasing every SDK method

---

## CURRENT STATE — PHASE 1 COMPLETE

### What is done (committed + merged to main):
- Phase 0: Repo scaffold, .gitignore, README, LICENSE (Apache 2.0), CONTRIBUTING.md
- Phase 0: GitHub Actions CI skeleton (.github/workflows/build.yml)
- Phase 0: API Parity Matrix (docs/API_PARITY_MATRIX.md)
- Phase 0: Auth Cache Research (docs/AUTH_CACHE_RESEARCH.md)
- Phase 1 Epic 1.1 — GDScript SDK layer (addons/mobile_wallet_adapter/):
  - MWAError.gd, MWAIdentity.gd, MWAAccount.gd, MWAAuthToken.gd
  - MWASendOptions.gd, MWACapabilities.gd
  - MobileWalletAdapter.gd (main SDK class)
  - plugin.cfg
- Phase 1 Epic 1.2 — Kotlin Android Plugin (android/plugin/):
  - MWAError.kt, AuthCacheImpl.kt, MWABridge.kt, MWAPlugin.kt
  - Gradle build system (settings.gradle.kts, build.gradle.kts, gradle.properties)
  - AndroidManifest.xml with wallet detection queries
  - gradlew.bat + gradle wrapper
  - BUILD SUCCESSFUL — plugin-release.aar (64KB) generated
- Phase 1 Epic 1.3 — Auth Cache GDScript layer:
  - MWAAuthCache.gd (base interface)
  - MWAMemoryCache.gd (in-memory)
  - MWAFileCache.gd (file-based, default)
  - MWASecureCache.gd (Android Keystore, delegates to Kotlin)
  - MWACacheManager.gd (auto-select backend)

### Git log (last 5 on main):
- beb71c7 Merge pull request #5 — Phase 1 complete
- 4fb1c12 Merge pull request #4 — Epic 1.2 Kotlin plugin + AAR
- a557468 Merge pull request #3 — Epic 1.1 GDScript layer
- 1bb43b1 Merge pull request #1 — Phase 0 Foundation

---

## NEXT TASK — PHASE 2: DOCUMENTATION

### Phase 2 Epic 2.1 — Docusaurus Setup
Start here. Commands are PowerShell on Windows.

Step 1: Bootstrap Docusaurus inside the docs/ folder
  cd C:\PROJECTS\Invoke_Solana_App
  npx create-docusaurus@latest docs classic --typescript

Step 2: Configure docusaurus.config.js
  - title: 'Invoke SDK'
  - tagline: 'Solana Mobile Wallet Adapter for Godot Engine'
  - Dark mode default
  - GitHub URL: https://github.com/plinkdev1/invoke-solana-sdk

Step 3: Netlify deployment
  - Connect GitHub repo to Netlify
  - Auto-deploy on push to main
  - Build command: cd docs && npm run build
  - Publish dir: docs/build

Step 4: Wire up GitHub Actions docs-check job (already stubbed in build.yml)

### Phase 2 Epic 2.2 — Documentation Content
Sections to write:
1. Getting Started (install, first connection, Hello Phantom example)
2. Core Concepts (MWA protocol, Android intents, Godot plugins)
3. API Reference (every method, signal, parameter)
4. Auth Cache Guide (backends, security, custom implementation)
5. Session Management (connect/disconnect/reconnect patterns)
6. Migration Guide (old Godot SDK → Invoke)

---

## PHASE 3 PREVIEW — INVOKEQUEST EXAMPLE APP

After docs, build the example app at example/invokequest/
- Godot 4.2+ project
- 10 screens (Splash, Wallet Picker, Auth Result, Dashboard, Sign Tx,
  Sign & Send, Sign Message, Capabilities, Auth Cache Demo, Settings)
- Design: Neobrutalism + Glassmorphism (Phantom/Jupiter aesthetic)
- Colors: #0D0F14 bg, #9945FF purple, #14F195 green
- Fonts: Space Grotesk (display), DM Sans (body), JetBrains Mono (mono)
- Full asset map in: _planning/SOLANAQUEST_ASSET_MAP.md

---

## CRITICAL TECHNICAL NOTES

### MWA SDK version: 2.0.3
- Identity goes in MobileWalletAdapter constructor as ConnectionIdentity
- transact() lambda receives authResult directly — no wallet.authorize() inside
- account.publicKey is a ByteArray (not address string)
- signMessages uses signMessagesDetached()
- Result is TransactionResult.Success / .Failure / .NoWalletFound

### Kotlin build:
- Build from: C:\PROJECTS\Invoke_Solana_App\android\
- Command: .\gradlew.bat assembleRelease
- Output: android/plugin/build/outputs/aar/plugin-release.aar
- gradle.properties must be ASCII encoded (no BOM) — use:
  Set-Content -Encoding ASCII

### Android environment:
- JDK 17 (Microsoft OpenJDK)
- Android SDK at: C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk
- ANDROID_HOME set as env var
- NDK 27.1.12297006
- compileSdk = 36, minSdk = 28, targetSdk = 34

### How the developer works:
- ONE task at a time
- Verify output before moving to next task
- Commit + push after EVERY completed task
- Always PowerShell commands (not bash)
- Always confirm current directory before running commands
- MAGMA-APP is a different project in C:\PROJECTS\ — do not confuse

### Planning docs location:
All reference docs are in _planning/ folder:
- GODOTMWA_REFERENCE_IMPLEMENTATION.md (ground truth for MWA patterns)
- GodotMWA_DEV_PLAN.md (full task list)
- GodotMWA_PRE_PRD.md (grant scope)
- GodotMWA_TECH_STACK.md (architecture)
- SOLANAQUEST_ASSET_MAP.md (UI assets for example app)

### README note:
At end of project, README needs full professional treatment.
Reference style: https://github.com/plinkdev1/SMWA-InjectionTool
(badges, hero banner, screenshots, quick install, code examples)

---

*Invoke SDK Agent Handoff v1.0 · Francisco (Franny) · Portugal · March 2026*
