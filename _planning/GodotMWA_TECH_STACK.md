# GodotMWA — Tech Stack, Architecture & Infrastructure
## Full Reference Document

---

## 1. TECH STACK SUMMARY

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **Game Engine** | Godot Engine | 4.2+ | Core runtime, scene management |
| **Scripting** | GDScript | 4.x | SDK API layer, example app logic |
| **Android Plugin** | Kotlin | 1.9+ | JVM bridge to MWA Android SDK |
| **MWA Android SDK** | `com.solanamobile:mobile-wallet-adapter-clientlib-ktx` | latest | Actual MWA protocol implementation |
| **Build System** | Gradle | 8.x | Android .aar build |
| **Android API** | Android SDK | 28+ (target 34) | OS integration, EncryptedSharedPreferences |
| **Secure Storage** | Android Keystore | OS-level | High-security auth token storage |
| **Docs Framework** | Docusaurus | 3.x | Documentation site |
| **Docs Deploy** | Netlify | — | CDN, CI/CD for docs |
| **Backend** | Fastify | 4.x | RPC proxy, rate limiting |
| **Backend Runtime** | Node.js | 20 LTS | Fastify runtime |
| **Backend Deploy** | Railway | — | Container hosting, auto-scale |
| **CI/CD** | GitHub Actions | — | Build, test, deploy automation |
| **Package Registry** | npm | — | Docusaurus, Fastify dependencies |

---

## 2. ARCHITECTURE DIAGRAM

```
┌──────────────────────────────────────────────────────────────────┐
│                        ANDROID DEVICE                            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                   Godot Engine (4.2+)                       │ │
│  │                                                             │ │
│  │  ┌─────────────────────────────────────────────────────┐   │ │
│  │  │            Game / App (GDScript)                    │   │ │
│  │  │  ┌─────────────────────────────────────────────┐   │   │ │
│  │  │  │         GodotMWA SDK (GDScript)              │   │   │ │
│  │  │  │                                             │   │   │ │
│  │  │  │  MobileWalletAdapter.gd                    │   │   │ │
│  │  │  │  MWAAuthCache.gd (+ impls)                 │   │   │ │
│  │  │  │  MWAIdentity.gd                            │   │   │ │
│  │  │  │  MWAAuthToken.gd                           │   │   │ │
│  │  │  │  MWAAccount.gd                             │   │   │ │
│  │  │  │  MWAError.gd                               │   │   │ │
│  │  │  └─────────────────┬───────────────────────────┘   │   │ │
│  │  └────────────────────┼───────────────────────────────┘   │ │
│  │                       │ Godot Plugin Bridge (signals)      │ │
│  │  ┌────────────────────▼───────────────────────────────┐   │ │
│  │  │         Godot Android Plugin (Kotlin .aar)          │   │ │
│  │  │                                                    │   │ │
│  │  │  MWAPlugin.kt (GodotPlugin entry)                  │   │ │
│  │  │  MWABridge.kt (coroutine session management)       │   │ │
│  │  │  AuthCacheImpl.kt (EncryptedSharedPreferences)     │   │ │
│  │  │  KeystoreCacheImpl.kt (Android Keystore)           │   │ │
│  │  └────────────────────┬───────────────────────────────┘   │ │
│  └───────────────────────┼─────────────────────────────────────┘ │
│                          │ Android SDK calls                      │
│  ┌───────────────────────▼────────────────────────────────────┐  │
│  │         Solana MWA Android SDK (Kotlin/Java)               │  │
│  │  com.solanamobile:mobile-wallet-adapter-clientlib-ktx      │  │
│  └───────────────────────┬────────────────────────────────────┘  │
│                          │ Android Intent / Association          │
│  ┌──────────┐  ┌─────────▼──────┐  ┌───────────────────────┐   │
│  │ Phantom  │  │    Backpack    │  │       Solflare        │   │
│  │   App    │  │      App       │  │         App           │   │
│  └──────────┘  └────────────────┘  └───────────────────────┘   │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │               Android Secure Storage                       │  │
│  │  EncryptedSharedPreferences | Android Keystore             │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
         │
         │ HTTPS (Solana RPC calls)
         ▼
┌─────────────────────────────────────────────────────┐
│              BACKEND (Railway)                      │
│  Fastify Node.js                                    │
│  POST /api/rpc → Solana RPC proxy                   │
│  Rate limiting: 100 req/min/IP                      │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        ▼                     ▼
┌──────────────┐    ┌──────────────────────┐
│ Solana       │    │ Solana               │
│ Devnet RPC   │    │ Mainnet RPC          │
└──────────────┘    └──────────────────────┘

┌─────────────────────────────────────────────────────┐
│              DOCS (Netlify)                         │
│  Docusaurus 3.x                                     │
│  docs.godotmwa.dev                                  │
│  Auto-deploy from GitHub main branch                │
└─────────────────────────────────────────────────────┘
```

---

## 3. ANDROID PLUGIN ARCHITECTURE

### 3.1 GodotPlugin Registration

```kotlin
// MWAPlugin.kt
@GodotPlugin
class MWAPlugin(godot: Godot) : GodotPlugin(godot) {
    
    override fun getPluginName() = "GodotMWA"
    
    override fun getPluginSignals(): Set<SignalInfo> = setOf(
        SignalInfo("authorized", String::class.java, String::class.java),
        SignalInfo("reauthorized", String::class.java),
        SignalInfo("deauthorized"),
        SignalInfo("disconnected"),
        SignalInfo("transaction_signed", Array<String>::class.java),
        SignalInfo("transaction_sent", Array<String>::class.java),
        SignalInfo("message_signed", Array<String>::class.java),
        SignalInfo("capabilities_received", String::class.java),
        SignalInfo("wallet_apps_detected", String::class.java),
        SignalInfo("mwa_error", Int::class.java, String::class.java),
    )

    @UsedByGodot
    fun authorize(cluster: String, name: String, uri: String, icon: String) {
        activity?.lifecycleScope?.launch {
            try {
                val result = transact(activity!!) { wallet ->
                    wallet.authorize(AuthorizeParams(
                        cluster = Cluster.fromName(cluster),
                        identityUri = Uri.parse(uri),
                        iconRelativeUri = Uri.parse(icon),
                        identityName = name
                    ))
                }
                emitSignal("authorized", 
                    result.authToken,
                    Base58.encode(result.publicKey)
                )
            } catch (e: Exception) {
                emitSignal("mwa_error", mapError(e), e.message ?: "Unknown error")
            }
        }
    }
    // ... other methods
}
```

### 3.2 Auth Cache (Android)

```kotlin
// AuthCacheImpl.kt
class AuthCacheImpl(context: Context) {
    
    private val masterKey = MasterKey.Builder(context)
        .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
        .build()
    
    private val sharedPreferences = EncryptedSharedPreferences.create(
        context,
        "godot_mwa_auth_cache",
        masterKey,
        EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
        EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
    )
    
    fun saveAuthToken(key: String, tokenJson: String) {
        sharedPreferences.edit().putString(key, tokenJson).apply()
    }
    
    fun loadAuthToken(key: String): String? {
        return sharedPreferences.getString(key, null)
    }
    
    fun clearAuthToken(key: String) {
        sharedPreferences.edit().remove(key).apply()
    }
    
    fun clearAll() {
        sharedPreferences.edit().clear().apply()
    }
}
```

---

## 4. GRADLE BUILD CONFIG

```kotlin
// android/plugin/build.gradle.kts
plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.godotmwa.plugin"
    compileSdk = 34
    
    defaultConfig {
        minSdk = 28
        targetSdk = 34
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    compileOnly("org.godotengine:godot:4.2.0.stable")
    implementation("com.solanamobile:mobile-wallet-adapter-clientlib-ktx:2.0.3")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.google.code.gson:gson:2.10.1")
}
```

---

## 5. FASTIFY BACKEND

### 5.1 Server Entry

```typescript
// backend/src/server.ts
import Fastify from 'fastify'
import cors from '@fastify/cors'
import rateLimit from '@fastify/rate-limit'
import { rpcRoutes } from './routes/rpc'

const server = Fastify({ logger: true })

server.register(cors, { origin: '*' })
server.register(rateLimit, { max: 100, timeWindow: '1 minute' })
server.register(rpcRoutes, { prefix: '/api' })

const PORT = parseInt(process.env.PORT ?? '3000')
server.listen({ port: PORT, host: '0.0.0.0' }, (err) => {
    if (err) { server.log.error(err); process.exit(1) }
})
```

### 5.2 RPC Proxy Route

```typescript
// backend/src/routes/rpc.ts
import { FastifyPluginAsync } from 'fastify'

const SOLANA_RPCS = {
    devnet: process.env.SOLANA_RPC_DEVNET ?? 'https://api.devnet.solana.com',
    mainnet: process.env.SOLANA_RPC_MAINNET ?? 'https://api.mainnet-beta.solana.com',
}

export const rpcRoutes: FastifyPluginAsync = async (fastify) => {
    fastify.post<{ 
        Querystring: { network?: string },
        Body: Record<string, unknown>
    }>('/rpc', async (request, reply) => {
        const network = (request.query.network ?? 'devnet') as keyof typeof SOLANA_RPCS
        const rpcUrl = SOLANA_RPCS[network] ?? SOLANA_RPCS.devnet
        
        const response = await fetch(rpcUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(request.body)
        })
        
        const data = await response.json()
        reply.send(data)
    })
    
    fastify.get('/health', async () => ({ status: 'ok', version: '1.0.0' }))
    fastify.get('/version', async () => ({ sdk: '1.0.0', protocol: 'MWA v2' }))
}
```

---

## 6. DOCUSAURUS CONFIG

```javascript
// docs/docusaurus.config.js
const config = {
    title: 'GodotMWA SDK',
    tagline: 'Solana Mobile Wallet Adapter for Godot Engine',
    url: 'https://docs.godotmwa.dev',
    baseUrl: '/',
    
    themeConfig: {
        colorMode: { defaultMode: 'dark', respectPrefersColorScheme: false },
        navbar: {
            title: 'GodotMWA',
            logo: { alt: 'GodotMWA Logo', src: 'img/logo.svg' },
            items: [
                { to: '/docs/getting-started', label: 'Docs', position: 'left' },
                { to: '/docs/api-reference', label: 'API', position: 'left' },
                { href: 'https://github.com/org/godot-mobile-wallet-adapter', label: 'GitHub', position: 'right' },
            ],
        },
        prism: {
            theme: require('prism-react-renderer').themes.dracula,
            additionalLanguages: ['gdscript', 'kotlin', 'bash'],
        },
        algolia: {
            appId: 'YOUR_APP_ID',
            apiKey: 'YOUR_SEARCH_KEY',
            indexName: 'godotmwa',
        },
    },
    
    presets: [['classic', {
        docs: { sidebarPath: require.resolve('./sidebars.js') },
        theme: { customCss: require.resolve('./src/css/custom.css') },
    }]],
}
module.exports = config
```

---

## 7. CI/CD PIPELINES

### 7.1 GitHub Actions — Build & Test

```yaml
# .github/workflows/build.yml
name: Build & Test

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [main]

jobs:
  android-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '17', distribution: 'temurin' }
      - name: Build Android plugin
        run: cd android/plugin && ./gradlew build
      - name: Upload .aar artifact
        uses: actions/upload-artifact@v4
        with:
          name: godot-mwa-plugin
          path: android/plugin/build/outputs/aar/

  docs-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: cd docs && npm ci && npm run build

  backend-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: cd backend && npm ci && npm run build
```

### 7.2 GitHub Actions — Release

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags: ['v*']

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { java-version: '17', distribution: 'temurin' }
      - name: Build plugin
        run: cd android/plugin && ./gradlew assembleRelease
      - name: Package plugin
        run: |
          mkdir -p release/addons/mobile_wallet_adapter/android
          cp addons/mobile_wallet_adapter/*.gd release/addons/mobile_wallet_adapter/
          cp android/plugin/build/outputs/aar/plugin-release.aar release/addons/mobile_wallet_adapter/android/
          cd release && zip -r ../godot-mwa-plugin-${{ github.ref_name }}.zip .
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: '*.zip'
          generate_release_notes: true
```

---

## 8. DATABASE / STATE MANAGEMENT

For the GodotMWA SDK, there is **no traditional database** needed. State is managed as follows:

| Data | Storage | Scope | Security Level |
|------|---------|-------|---------------|
| Auth Token | EncryptedSharedPreferences | Per-app | Medium |
| Auth Token (high-security) | Android Keystore | Per-app | High |
| In-memory session state | GDScript Dictionary | Runtime only | N/A |
| User preferences | Godot ConfigFile (user://) | Per-app | Low |
| Example app demo data | Hardcoded / devnet | Runtime | N/A |

---

## 9. SECURITY CONSIDERATIONS

1. **Auth tokens are sensitive** — never log them, never include in crash reports
2. **EncryptedSharedPreferences** uses AES256-GCM — encrypted at rest, but not as secure as Keystore
3. **Android Keystore** — hardware-backed on supported devices, software on emulators
4. **Transport** — MWA communicates locally via Android intents (no network for auth)
5. **RPC calls** — go through HTTPS, use the Railway proxy to avoid exposing API keys
6. **Plugin permissions** — only INTERNET required; no personal data collected
7. **Token expiry** — respect wallet-side token expiry, clear stale tokens proactively

---

*GodotMWA Tech Stack Document v1.0 · Francisco (Franny) · Portugal*
