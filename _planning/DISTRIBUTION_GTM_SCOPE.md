# INVOKE SDK — DISTRIBUTION & GO-TO-MARKET SCOPE
## Ecosystem Presence, Grant Submission & Community Strategy
## Francisco (Franny) · Portugal · 2026

---

## 1. GITHUB — Professional README

### When to do it
After all three grant deliverables are complete (Phase 4).

### Reference
https://github.com/plinkdev1/SMWA-InjectionTool

### What it needs
- Hero banner image (custom designed, Solana purple/green)
- Badges row: License | CI | Godot 4.2+ | Android | Solana
- One-line description
- Animated GIF or screenshot of InvokeQuest running on device
- Quick install (5 steps, copy-pasteable)
- Code example (30 lines — connect + sign + send)
- Architecture diagram (from docs)
- Screenshots grid (6 InvokeQuest screens in phone mockups)
- Supported wallets logos
- Links: Docs | Example App | Changelog | Grant
- Contributing section
- License section
- Solana Foundation grant badge

### Agent Prompt for README
```
Write a professional GitHub README for "Invoke SDK" — a Godot Engine 
Android plugin for Solana Mobile Wallet Adapter.

REFERENCE STYLE: https://github.com/plinkdev1/SMWA-InjectionTool

INCLUDE:
- Badges: Apache 2.0 | CI passing | Godot 4.2+ | Android API 28+ | Solana
- Hero section with project description
- Quick install (5 steps)
- Code example: authorize + sign_transactions + sign_and_send (30 lines GDScript)
- Architecture diagram (ASCII or markdown table)
- Screenshots placeholder section
- Supported wallets: Phantom, Backpack, Solflare
- API overview table (method + description)
- Requirements section
- Contributing + License
- "Built with Solana Foundation grant support" footer badge

TONE: Professional open source project. Clean markdown. 
Developer-focused. No fluff.
```

---

## 2. DEMO VIDEO

### What it shows (script outline)
Total length: 3-4 minutes

00:00 — Title card: "Invoke SDK — Solana MWA for Godot Engine"
00:05 — Show InvokeQuest app on Android device (real phone)
00:10 — Fresh install: splash → wallet picker → select Phantom
00:20 — Phantom opens, user approves → connected dashboard
00:35 — Show "Session cached ✓" indicator
00:45 — Kill app completely, reopen
00:50 — Splash → straight to dashboard (NO wallet popup)
01:00 — "This is the auth cache in action" voiceover
01:10 — Sign Transaction demo — build tx, Phantom signs silently
01:30 — Sign & Send — broadcast to devnet, show Solscan link
01:50 — Sign Message — type custom message, sign, show result
02:10 — Get Capabilities — show wallet feature table
02:25 — Auth Cache screen — show token age, clear, reconnect
02:45 — Settings — switch network, switch cache backend
03:00 — Show GitHub repo, docs site, grant badge
03:20 — "Available now. Apache 2.0. Solana Foundation grant."
03:30 — End card with links

### Recording setup
- Real Android device (not emulator) for authenticity
- Screen recording via ADB or device built-in
- Voiceover: calm, technical, professional
- Upload: YouTube (unlisted until grant submission, then public)
- Embed in: README, docs homepage, grant submission

---

## 3. REDDIT POSTS

### Subreddits to target (in order)
1. r/godot — primary, 200k+ Godot devs
2. r/solana — Solana ecosystem
3. r/gamedev — broad game dev audience
4. r/androiddev — Android developers
5. r/solanamobile — Solana mobile specifically

### Post template for r/godot

Title:
"I built a Solana wallet adapter for Godot Android — connect Phantom/Backpack/Solflare with 5 lines of GDScript [open source, Solana Foundation grant]"

Body:
```
Hey Godot community,

I've been working on a grant-funded open source SDK that lets Godot 
Android games connect to Solana wallets (Phantom, Backpack, Solflare).

**What it does:**
- Authorize with any MWA-compatible wallet
- Sign transactions, sign & send, sign messages
- Auth token cache — users approve once, silent reconnect on relaunch
- Full GDScript API — no Kotlin required for game devs

**5 lines to connect:**
[code snippet]

**Links:**
- GitHub: [link]
- Docs: [link]  
- Demo app (InvokeQuest): [link]
- Demo video: [link]

Built this because I needed it myself and couldn't find anything 
production-ready for Godot. Apache 2.0, Solana Foundation grant.

Happy to answer questions!
```

---

## 4. X (TWITTER) THREAD

### Thread structure (8 tweets)

Tweet 1 (hook):
"I just shipped Invoke SDK — Solana Mobile Wallet Adapter for Godot Engine.
Connect Phantom, Backpack, Solflare to your Android game in 5 lines of GDScript.
Apache 2.0. Solana Foundation grant.
Thread 🧵"

Tweet 2 (problem):
"Godot has 2M+ developers. Mobile gaming on Android is a $50B market.
But there was NO production-ready Solana wallet integration for Godot.
The existing SDK was missing reauthorize, signMessages, getCapabilities,
and had zero auth token caching.
So I built it."

Tweet 3 (solution):
"Invoke SDK gives you:
✅ Full MWA API parity with React Native
✅ Auth token cache (EncryptedSharedPreferences)
✅ Silent reconnect — no wallet popup on relaunch
✅ 3 cache backends (Memory / File / Android Keystore)
✅ GDScript API — clean, typed, signal-based"

Tweet 4 (code):
"This is all it takes to connect Phantom to your Godot game:
[code screenshot]
One identity object. One authorize call. One signal handler.
That's it."

Tweet 5 (cache):
"The auth cache is the killer feature.
First launch: wallet popup (normal)
Every launch after: silent reconnect in background.
No popup. No friction. Just like production React Native apps.
Game devs get this for free."

Tweet 6 (demo):
"Here's InvokeQuest — the example app showing every SDK feature:
[demo video clip or GIF]
Authorize → Sign Tx → Sign & Send → Sign Message → Get Capabilities
All on a real Android device."

Tweet 7 (links):
"Everything is open source:
📦 SDK: [GitHub link]
📖 Docs: [docs link]
🎮 Example app: [link]
🎥 Demo video: [YouTube link]
Apache 2.0 · Solana Foundation grant"

Tweet 8 (CTA):
"If you're building on Godot + Solana, this is for you.
If you know someone who is — tag them.
Stars and feedback very welcome 🙏
[GitHub link]"

---

## 5. MIRROR ARTICLE

### Title
"Building Invoke SDK: Bringing Solana Wallets to Godot Engine"

### Structure
1. Introduction — why this needed to exist
2. The problem — Godot devs locked out of Solana
3. What we built — SDK overview with architecture diagram
4. The auth cache — the technical innovation
5. InvokeQuest — the example app walkthrough
6. Lessons learned — MWA 2.0.3 API gotchas, Kotlin/GDScript bridge
7. What's next — roadmap, community contributions
8. Links and resources

### Tone
Technical but accessible. First person. Show the journey.
Include code snippets. Include screenshots of InvokeQuest.

---

## 6. SOLANA MOBILE DISCORD

### Channels to post in
- #developer-showcase — share the SDK
- #mobile-wallet-adapter — technical discussion
- #grants — mention the grant project

### Message template
```
Hey! Just shipped Invoke SDK — Solana Mobile Wallet Adapter for Godot Engine.

Full API parity with the React Native SDK, extensible auth token cache 
(EncryptedSharedPreferences by default), and a complete example app.

Built as a Solana Foundation grant project.

GitHub: [link]
Docs: [link]

Would love feedback from the MWA team if anyone has time to review.
The auth token cache pattern was inspired by how MAGMA Protocol handles 
reauthorization — huge thanks to that codebase for the reference patterns.
```

---

## 7. SOLANA FOUNDATION GRANT SUBMISSION

### Airtable fields to fill

**Problem:**
The Godot game engine has approximately 2 million active developers worldwide.
Yet Solana has no production-ready wallet integration for Godot on Android.
The existing Godot MWA SDK lacks critical functionality: no reauthorize,
deauthorize, signMessages, or getCapabilities; no authorization token caching
(forcing wallet approval popups on every session); and no reliable
disconnect/reconnect flow.

**Proposed Solution:**
Three interconnected components:
1. Invoke SDK — complete GDScript + Kotlin plugin with full MWA API parity
   and extensible auth token cache (EncryptedSharedPreferences by default)
2. Documentation — Docusaurus site on Netlify with full API reference
3. InvokeQuest — open source Godot Android example app demonstrating
   every SDK method with premium UI

**Links to attach:**
- GitHub repo URL
- Docs site URL (Netlify)
- Demo video URL (YouTube)
- APK download link (GitHub Release)

**Evidence to attach:**
- CI passing screenshot
- Build successful (.aar) screenshot
- InvokeQuest running on real device screenshots (10 screens)
- API parity matrix (docs/API_PARITY_MATRIX.md)

---

## 8. TIMELINE FOR DISTRIBUTION

| Action | When |
|--------|------|
| GitHub README (professional) | After Phase 4 complete |
| Demo video recording | After InvokeQuest is on device |
| GitHub Release v1.0.0 | After QA passes |
| Netlify deploy (docs live) | After Phase 2 merged — connect now |
| Grant submission (Airtable) | Week 12 |
| Reddit posts | Same day as v1.0.0 release |
| X thread | Same day as v1.0.0 release |
| Mirror article | 1 week after release |
| Solana Discord | Same day as v1.0.0 release |

---

*Invoke SDK — Distribution & GTM Scope v1.0 · Francisco (Franny) · 2026*
