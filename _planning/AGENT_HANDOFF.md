# INVOKE SDK — COMPLETE AGENT HANDOFF
## Updated Session Startup Document
## Francisco (Franny) · Portugal · March 2026

---

## CRITICAL: READ THIS FIRST

This is a Solana Foundation grant project ($10,000 USD).
Three non-negotiable deliverables — ALL NOW COMPLETE:
1. Invoke SDK — GDScript + Kotlin plugin, full MWA API parity, auth token cache
2. Documentation — Docusaurus site on Netlify
3. InvokeQuest — Example Godot Android app showcasing every SDK method

---

## HOW THIS DEVELOPER WORKS — RESPECT THIS ALWAYS

- ONE task at a time. Maximum two complementary subtasks per prompt.
- Developer copy-pastes output into terminal and verifies before continuing.
- Commit + push after EVERY completed task. No exceptions.
- If something fails, paste the exact error. Fix before moving on. Never skip ahead.
- Always give PowerShell commands. Developer is on Windows.
- Always confirm current directory before running commands.
- Developer has TWO projects in C:\PROJECTS\ — do NOT confuse them:
  - C:\PROJECTS\Invoke_Solana_App  <- THIS PROJECT
  - C:\PROJECTS\MAGMA-APP          <- DIFFERENT PROJECT, ignore it

---

## PROJECT IDENTITY

- Project name: INVOKE (formerly GodotMWA / SolanaQuest — both deprecated)
- SDK name: Invoke
- Example app: InvokeQuest (formerly SolanaQuest — deprecated)
- Repo: https://github.com/plinkdev1/invoke-solana-sdk (private until grant delivery)
- Local path: C:\PROJECTS\Invoke_Solana_App
- Active branch: develop (all work here, merge to main after each phase)
- Terminal: PowerShell on Windows

---

## ENVIRONMENT

- JDK: 17 (Microsoft OpenJDK)
- Android SDK: C:\Users\MAXI KROOKED\AppData\Local\Android\Sdk
- ANDROID_HOME: set as Windows env var
- NDK: 27.1.12297006
- compileSdk = 36, minSdk = 28, targetSdk = 34
- Node.js: v22.22.1, npm: 10.9.4
- Kotlin build: cd android && .\gradlew.bat assembleRelease
- AAR output: android/plugin/build/outputs/aar/plugin-release.aar
- gradle.properties MUST be ASCII encoded (no BOM):
  Set-Content -Encoding ASCII

---

## COMPLETED PHASES

### Phase 0 — Foundation (DONE, merged to main)
- Repo scaffold, .gitignore, README, LICENSE (Apache 2.0), CONTRIBUTING.md
- GitHub Actions CI skeleton (.github/workflows/build.yml)
- API Parity Matrix (docs/API_PARITY_MATRIX.md)
- Auth Cache Research (docs/AUTH_CACHE_RESEARCH.md)

### Phase 1 — Core SDK (DONE, merged to main)

#### Epic 1.1 — GDScript layer (addons/mobile_wallet_adapter/)
- MWAError.gd, MWAIdentity.gd, MWAAccount.gd, MWAAuthToken.gd
- MWASendOptions.gd, MWACapabilities.gd
- MobileWalletAdapter.gd — main SDK class, all API methods, state machine
- plugin.cfg — Godot addon entry point (name: InvokeMWA)

#### Epic 1.2 — Kotlin Android Plugin (android/plugin/)
- MWAError.kt, AuthCacheImpl.kt, MWABridge.kt, MWAPlugin.kt
- Gradle build system, AndroidManifest.xml, gradlew.bat
- BUILD SUCCESSFUL — plugin-release.aar (64KB) confirmed

#### Epic 1.3 — Auth Cache GDScript layer
- MWAAuthCache.gd, MWAMemoryCache.gd, MWAFileCache.gd
- MWASecureCache.gd, MWACacheManager.gd

### Phase 2 — Documentation (DONE, merged to main)
- Docusaurus site at docs/ with Invoke branding, Solana purple/green theme
- All 6 doc pages written and building successfully
- netlify.toml configured for deployment

#### Pending for docs (do before grant submission):
- Replace default Docusaurus homepage card images with custom Invoke images
- Generate with Recraft: feature-plugin.png, feature-cache.png, feature-api.png (512x512)
- Place in docs/static/img/
- Update docs/src/components/HomepageFeatures/index.tsx

### Phase 3 — InvokeQuest Example App (DONE, merged to main)

#### Foundation files (example/invokequest/)
- project.godot — Godot 4.x config, 1080x1920 portrait, mobile renderer
- autoloads/DesignTokens.gd — all colors, font sizes, spacing, animation durations
- autoloads/SceneManager.gd — navigation stack with fade transitions
- shaders/glass_card.gdshader — glassmorphism card effect
- shaders/aurora_background.gdshader — animated aurora background
- assets/images/splash/splash_logo_mark.png — Invoke logo mark (chosen: geometric rune/totem)
- assets/images/misc/invoke_wordmark.png — Invoke wordmark (chosen: inline striped treatment)
- assets/icons/wallets/ — Phantom, Backpack, Solflare official brand icons

#### All 10 screens (example/invokequest/scenes/screens/)
- Splash.tscn + Splash.gd
- WalletPicker.tscn + WalletPicker.gd
- AuthResult.tscn + AuthResult.gd
- Dashboard.tscn + Dashboard.gd
- SignTransaction.tscn + SignTransaction.gd
- SignAndSend.tscn + SignAndSend.gd
- SignMessage.tscn + SignMessage.gd
- Capabilities.tscn + Capabilities.gd
- AuthCache.tscn + AuthCache.gd
- Settings.tscn + Settings.gd

---

## NEXT PHASE — PHASE 4: QA & GRANT SUBMISSION

### Epic 4.1 — Testing
- Open InvokeQuest in Godot editor — verify all scenes load, no errors
- Test desktop simulation mode (F5 in editor) — all navigation flows work
- Build Android APK and test on real device with Phantom/Backpack/Solflare
- Verify: authorize, reauthorize from cache, sign tx, sign & send, sign message, capabilities
- Verify: cache clear + reconnect flow on AuthCache screen

### Epic 4.2 — Grant Submission Package
- Demo video: record Android device — fresh install, Phantom auth, cache demo,
  kill app, reopen, auto-reconnect (no popup), sign tx, sign & send, sign message
- Upload video to YouTube (unlisted ok), get URL
- Docs homepage images (Recraft) — 3 feature card images 512x512
- Fill Airtable grant application with all URLs
- README full professional treatment (see note below)

---

## POST-GRANT TASKS (from _planning/LANDING_PAGE_DEMO_SCOPE.md and DISTRIBUTION_GTM_SCOPE.md)

These come AFTER grant submission but BEFORE going public:
1. Landing page — premium marketing page (separate project/session)
2. Live demo page — Godot web export embedded (HTML5/WASM build of InvokeQuest
   running in simulation mode — MWA is Android-only so wallet calls use
   desktop fallbacks, but UI/navigation/cache demo all work in browser)
3. README — full professional treatment
   Reference: https://github.com/plinkdev1/SMWA-InjectionTool
4. Reddit/X/Mirror posts
5. Grant submission final package

### IMPORTANT NOTE ON PRESENTATION & GRANT QUALITY:
The web demo (Godot HTML5 export) and demo video are HIGH PRIORITY even though
they are technically post-deliverable. Grant reviewers judge on presentation.
A live interactive demo + polished video = significantly better outcome.
Do NOT skip these. Prioritize them before the Airtable submission deadline.

---

## CRITICAL TECHNICAL NOTES

### MWA SDK 2.0.3 API (Kotlin)
- Identity goes in MobileWalletAdapter constructor as ConnectionIdentity
- transact() lambda receives authResult directly
- account.publicKey is ByteArray (not address string — that was 1.x)
- signMessages uses signMessagesDetached()
- Result types: TransactionResult.Success / .Failure / .NoWalletFound
- ActivityResultSender requires ComponentActivity (not plain Activity)

### GDScript conventions
- All signals: snake_case
- All errors: emitted via error signal, NEVER thrown
- Plugin singleton name: InvokeMWA
- All classes typed with class_name

### Network selection
- Stored in user://invokequest_settings.cfg via Settings.gd
- All SDK calls should read network from this config
- Default: devnet (correct for grant demo)

### Desktop simulation mode
- All screens check Engine.has_singleton("InvokeMWA")
- If plugin not present: simulate success after short delay
- This allows testing all UI flows in Godot editor on Windows

### Git workflow
- All work on develop branch
- git push (no flags needed — upstream already set)
- After each phase: PR develop -> main via GitHub UI
- PR title format: "Phase X complete — description"

### Logo assets (locked)
- Mark: geometric rune/totem (purple-to-teal gradient, line art)
  Path: example/invokequest/assets/images/splash/splash_logo_mark.png
- Wordmark: inline striped INVOKE treatment
  Path: example/invokequest/assets/images/misc/invoke_wordmark.png
- Both also needed for: docs site, README hero, landing page

---

## PLANNING DOCS (all in _planning/ folder in repo)

- GODOTMWA_REFERENCE_IMPLEMENTATION.md — GROUND TRUTH for all MWA patterns
- GodotMWA_DEV_PLAN.md — full task list for all phases
- GodotMWA_PRE_PRD.md — grant scope and deliverables
- GodotMWA_TECH_STACK.md — architecture reference
- SOLANAQUEST_ASSET_MAP.md — every UI asset, font, color, animation spec
- LANDING_PAGE_DEMO_SCOPE.md — landing page + web demo scope (post-grant)
- DISTRIBUTION_GTM_SCOPE.md — Reddit/X/Mirror posts, GTM plan (post-grant)

---

## CURRENT GIT STATE

Repo: https://github.com/plinkdev1/invoke-solana-sdk
Main branch: Phase 3 merged (all 3 grant deliverables complete)
Develop branch: up to date with main
Last PR on main: Phase 3 complete — InvokeQuest example app (all 10 screens)

---

*INVOKE SDK Agent Handoff v3.0 · Francisco (Franny) · Portugal · March 2026*
