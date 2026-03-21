# INVOKE SDK — LANDING PAGE & LIVE DEMO SCOPE
## Product Marketing Web Presence
## Francisco (Franny) · Portugal · 2026

---

## 1. LANDING PAGE — invoke-sdk.dev (or invoke.builders)

### What it is
A premium marketing/product page for the Invoke SDK.
Think Privy.io, Reown.com, or Dynamic.xyz — but for Godot developers.
Single page, dark theme, Solana purple/green, modern web stack.

### Tech Stack
- Framework: Next.js 14 (App Router) or plain HTML/CSS/JS
- Styling: Tailwind CSS
- Animations: Framer Motion or CSS animations
- Hosting: Vercel or Netlify
- Domain: invoke-sdk.dev or invoke.builders

### Sections (top to bottom)

#### Hero
- Headline: "Solana Wallets for Godot. Finally."
- Subheadline: "Connect Phantom, Backpack, and Solflare to your
  Android game in 5 lines of GDScript."
- CTA buttons: "Get Started →" + "View on GitHub"
- Background: animated aurora gradient (purple → green)
- Code snippet preview (syntax highlighted GDScript)

#### Problem / Solution
- Left: "The problem" — Godot has 2M devs, no Solana wallet support
- Right: "The solution" — Invoke SDK, drop-in, 5 minutes

#### Code Example
- Tabbed: GDScript / Kotlin (show both layers)
- Syntax highlighted
- Copy button
- Shows: authorize → sign → send in ~20 lines

#### Features Grid (3 columns)
- Drop-in Plugin — copy one folder, enable in Godot
- Auth Token Cache — silent reconnect, no popup on relaunch
- Full API Parity — every RN MWA method in GDScript
- Session Management — full state machine built-in
- Error Handling — typed codes, retryable detection
- Open Source — Apache 2.0, Solana Foundation grant

#### Supported Wallets
- Phantom logo + name
- Backpack logo + name
- Solflare logo + name
- "Any MWA-compatible wallet" note

#### Architecture Diagram
- Visual showing: GDScript → Kotlin Plugin → MWA SDK → Wallet App
- Animated connection lines

#### Getting Started (3 steps)
1. Download the plugin zip from GitHub
2. Drop into your Godot project
3. Call MWA.authorize() — done

#### Grant Badge
- "Built with support from Solana Foundation"
- Solana Foundation logo

#### Footer
- GitHub link, docs link, license

---

## 2. LIVE DEMO PAGE — demo.invoke-sdk.dev

### What it is
An interactive web page that visually simulates the Invoke SDK flow.
NOT a real wallet connection — a visual walkthrough/simulator.
Think: "See how it works before you install it."

### Tech Stack
- React or plain HTML/JS
- Hosted on same domain as landing page (subdomain or /demo route)
- Mobile-responsive (looks good on phone)

### What it shows
An animated step-by-step flow:

Step 1 — App Launch
- Phone mockup showing InvokeQuest splash screen
- "Checking auth cache..." animation
- Result: "No token found → starting authorize"

Step 2 — Wallet Picker
- Three wallet cards appear (Phantom, Backpack, Solflare)
- User clicks Phantom
- Card animates selected state

Step 3 — Authorization
- Phone mockup switches to "Phantom" screen
- Approval dialog animation
- User taps "Approve"
- Token returned animation

Step 4 — Connected
- Dashboard screen appears
- Address shown (truncated fake address)
- "Session cached ✓" badge appears
- Green connected indicator pulses

Step 5 — Sign Transaction
- "Sign Transaction" button
- Wallet popup animation (silent — no popup since cached)
- Signature returned
- "Tx signed ✓" confirmation

Step 6 — App Relaunch
- Phone shows splash screen again
- "Token found (12 min old) → reauthorizing silently"
- No wallet popup — straight to dashboard
- "This is the magic of the auth cache" callout

### Interactive Controls
- "Run Demo" button — plays full animation sequence
- "Step Forward / Step Back" for manual control
- Speed control (0.5x / 1x / 2x)
- Toggle: "Without cache" vs "With cache" — shows the difference

---

## 3. AGENT PROMPT FOR BUILDING THESE

### Landing Page Prompt
```
Build a premium developer tool landing page for "Invoke SDK" — 
a Godot Engine Android plugin for Solana Mobile Wallet Adapter.

REFERENCE SITES FOR STYLE: privy.io, reown.com, dynamic.xyz

TECH: Next.js 14 App Router + Tailwind CSS + Framer Motion
COLORS: Background #0D0F14, Primary #9945FF (Solana Purple), 
        Accent #14F195 (Solana Green), Text #FFFFFF
FONTS: Space Grotesk (headings), DM Sans (body)

SECTIONS:
1. Hero — "Solana Wallets for Godot. Finally." with animated aurora bg,
   GDScript code snippet, two CTAs: "Get Started" + "GitHub"
2. Problem/Solution — 2M Godot devs, no Solana wallet support → Invoke
3. Code Example — tabbed GDScript/Kotlin, syntax highlighted, copy button
4. Features Grid — 6 features, icon + title + description each
5. Supported Wallets — Phantom, Backpack, Solflare logos
6. Architecture Diagram — animated layer diagram
7. 3-Step Getting Started
8. Solana Foundation grant badge
9. Footer

TONE: Premium developer tool. Clean. Technical but approachable.
      Like Linear or Vercel but Solana-flavored.

Output: Single Next.js page component with all sections.
        Include Tailwind classes. Include Framer Motion animations.
        Make it production-ready.
```

### Live Demo Page Prompt
```
Build an interactive SDK demo page for "Invoke SDK" — showing how
a Godot game connects to Phantom wallet using the Invoke SDK.

This is a VISUAL SIMULATOR — not a real wallet connection.
It shows the flow step by step with animations.

TECH: React + Tailwind CSS + Framer Motion
COLORS: Same as landing page (#0D0F14, #9945FF, #14F195)

SIMULATE THIS FLOW (6 steps with animations):
1. App launch → cache check → no token
2. Wallet picker → user selects Phantom
3. Phantom approval dialog → user approves → token returned
4. Dashboard shown → address displayed → "Session cached ✓"
5. Sign transaction → silent (no popup) → signature returned
6. App relaunch → token found → silent reconnect → straight to dashboard

FEATURES:
- "Run Demo" button plays full sequence
- Step forward/back manual controls  
- Speed control (0.5x / 1x / 2x)
- Toggle: "Without cache" vs "With cache" comparison
- Phone mockup frame around the simulation
- Code snippet shown for each step (what GDScript runs)

Output: Single React component, self-contained, production-ready.
```

---

*Invoke SDK — Landing Page & Demo Scope v1.0 · Francisco (Franny) · 2026*
