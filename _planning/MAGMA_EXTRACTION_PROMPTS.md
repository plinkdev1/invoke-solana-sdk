# MAGMA → GODOTMWA: Reference Extraction Prompts
## Use these in your Magma agent chats to extract what matters

---

## PROMPT 1 — SESSION LIFECYCLE & TRANSACT() WRAPPER

Feed this to your Magma agent that has access to the frontend/MWA codebase:

```
I'm building a separate project: a Godot Engine Android SDK for Solana Mobile Wallet Adapter 
(GodotMWA). I need you to analyze this codebase and extract a reference implementation doc.

Specifically, find and document the following — for EACH item, include:
  (a) the actual code snippet (cleaned up, no noise)
  (b) WHY this specific implementation was chosen (what broke before it)
  (c) any gotchas or edge cases this handles that weren't obvious from the MWA docs

EXTRACT THESE PATTERNS:

1. THE TRANSACT() WRAPPER
   - Find where transact() from @solana-mobile/mobile-wallet-adapter-protocol-web3js is called
   - Document the full wrapper function including error handling around it
   - Document what happens when the wallet app is NOT in foreground
   - Document any timeout handling
   - Document how you handle the case where transact() is called while another session is active

2. SESSION LIFECYCLE
   - How do you track "is session currently open"?
   - What state transitions exist? (IDLE → CONNECTING → AUTHORIZED etc.)
   - How do you handle app going to background mid-session?
   - How do you handle wallet app being killed mid-session?
   - What's the reconnect flow on app resume?

3. AUTH TOKEN STORAGE
   - Where and how is the auth_token stored after authorize()?
   - What storage mechanism is used (SecureStore, AsyncStorage, other)?
   - How is expiry handled?
   - What's the reauthorize() flow — when does it happen, what triggers it?
   - What happens when reauthorize() fails? 

4. ERROR HANDLING
   - What specific error types did you catch? List them all with their error codes/classes
   - For each error type: what's the correct recovery action?
   - Which errors are user-facing vs. silent retry?
   - Any errors that were NOT documented in MWA docs but appeared in practice?
   - How do you handle WalletNotInstalledError gracefully?

5. THINGS THAT BROKE / LESSONS LEARNED
   - What was the biggest MWA integration mistake that cost you time?
   - What did the MWA docs say vs. what actually worked in practice?
   - Any device-specific or wallet-version-specific bugs you discovered?
   - Any timing/race condition issues with intents or sessions?

Output format: a markdown document called MAGMA_MWA_REFERENCE.md structured as:

## Section 1: transact() Wrapper
[code + why + gotchas]

## Section 2: Session Lifecycle  
[code + state machine diagram in ASCII + gotchas]

## Section 3: Auth Token Storage
[code + storage choice rationale + expiry logic]

## Section 4: Error Handling Patterns
[table: ErrorType | Code/Class | Recovery Action | User-facing?]

## Section 5: Lessons Learned
[bullet list of "what broke + what fixed it"]

## Section 6: What I'd Do Differently in a New SDK
[if you were writing a fresh MWA wrapper for a new platform, what patterns would you 
 carry over and what would you redesign?]

This doc will be fed to Claude Code as context when implementing the Godot Kotlin plugin
bridge (GDScript ↔ MWA Android SDK). The more specific and honest about failures the better.
```

---

## PROMPT 2 — BACKEND / FASTIFY SERVER PATTERNS

Feed to your Magma agent that has the backend codebase:

```
I'm building a Fastify backend for a separate project (GodotMWA SDK — a Godot Engine 
Solana wallet integration). I need to extract backend patterns from this codebase.

Find and document:

1. RPC PROXY SETUP
   - How is the Solana RPC proxy implemented? (rate limiting, error handling, retries)
   - What headers/CORS config is needed for mobile app clients?
   - How are devnet vs mainnet endpoints handled?
   - Any caching layer on RPC responses?

2. TRANSACTION HANDLING  
   - How are transactions built server-side (if at all)?
   - How are blockhash freshness issues handled?
   - How are failed transactions retried?
   - What's the confirmation polling strategy?

3. AUTH/SESSION PATTERNS
   - How is the wallet's public key verified server-side?
   - Any signed message verification (proving wallet ownership)?
   - How are sessions tied to wallet address?

4. ERROR PATTERNS SPECIFIC TO SOLANA
   - What Solana-specific errors needed special handling?
   - How are "transaction expired" errors surfaced to the client?
   - How are network timeouts from Solana RPC handled?

5. MOBILE CLIENT SPECIFICS
   - Any special handling for mobile app vs web clients?
   - How are network interruptions from the mobile client handled?
   - Any retry logic designed specifically for flaky mobile connections?

Output as: MAGMA_BACKEND_REFERENCE.md with same structure (code + rationale + gotchas).
Focus especially on what would translate to a DIFFERENT mobile client (Godot Android app)
rather than React Native, since the transport is the same but the client SDK differs.
```

---

## PROMPT 3 — ANDROID-SPECIFIC INTENT HANDLING (if any native Android code exists)

```
This is for a Godot Android SDK project (GodotMWA). Check if this codebase has any:

1. Native Android code (Java/Kotlin) handling MWA intents
2. Any AndroidManifest.xml intent-filter configuration for MWA
3. Any activity result handling for wallet responses
4. Any deep link / URI scheme handling for wallet callbacks
5. Any Android-specific permission handling (QUERY_ALL_PACKAGES etc.)

For each found:
  - Show the exact code/config
  - Explain WHY it was needed (what broke without it)
  - Note which Android API levels it applies to
  - Note which wallet apps (Phantom/Backpack/Solflare) required it

Also document:
  - Minimum Android API level that MWA works reliably on in your testing
  - Any Samsung-specific, Pixel-specific, or OEM-specific issues found
  - How the wallet picker (intent chooser) was implemented — did you build custom UI 
    or use Android's built-in chooser?

Output as: MAGMA_ANDROID_REFERENCE.md
```

---

## PROMPT 4 — CONSOLIDATION PROMPT (run last, feeds outputs from 1-3)

After running prompts 1-3, feed the resulting docs + this prompt to a fresh Magma agent:

```
I have these three reference docs extracted from the Magma codebase:
[paste MAGMA_MWA_REFERENCE.md]
[paste MAGMA_BACKEND_REFERENCE.md]  
[paste MAGMA_ANDROID_REFERENCE.md]

Now produce a single consolidated doc called: GODOTMWA_REFERENCE_IMPLEMENTATION.md

This doc will be fed as CONTEXT to Claude Code at the START of each development session 
for a new project: the GodotMWA SDK (Godot Engine Android SDK for Solana MWA).

The reader is Claude Code implementing:
  - GDScript API layer (Godot 4.x)
  - Kotlin Android plugin bridge
  - Auth token cache (EncryptedSharedPreferences + Android Keystore)
  - Session state machine
  - Example Godot Android app

Structure the consolidated doc as:

## CRITICAL PATTERNS (Must implement exactly this way)
[things that have a very specific correct implementation based on hard lessons]

## COMMON FAILURE MODES (Do NOT do these)
[anti-patterns discovered through breaking things]

## ERROR HANDLING REFERENCE TABLE
[complete table: Error | Cause | Recovery | Notes]

## SESSION LIFECYCLE DIAGRAM
[ASCII state machine — authoritative reference]

## AUTH TOKEN: Storage & Reauth Flow
[the exact logic, adapted for Android/Kotlin context]

## BACKEND INTEGRATION NOTES
[what the Fastify proxy needs to handle for Godot clients specifically]

## PLATFORM DIFFERENCES: React Native vs. Godot/Kotlin
[for each pattern: how it works in RN vs. how it should work in Godot/Kotlin]
[this is the highest value section — explicit translation of learned patterns to new stack]

Keep it dense and practical. No padding. Every sentence should be something Claude Code 
needs to know before writing a single line of GodotMWA implementation code.
Max length: 800 lines. Compress aggressively.
```

---

## HOW TO USE THESE PROMPTS

Run in this order:
1. Prompt 1 → Magma frontend agent (needs access to MWA/wallet code)
2. Prompt 2 → Magma backend agent (needs access to Fastify/server code)  
3. Prompt 3 → Magma agent with Android/native code access (if exists)
4. Prompt 4 → Fresh agent, paste outputs from 1-3, get final consolidated doc

Then: save GODOTMWA_REFERENCE_IMPLEMENTATION.md to your GodotMWA project root.
Feed it at the top of EVERY Claude Code session for this project.
```
