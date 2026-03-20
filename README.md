# Invoke — Godot Mobile Wallet Adapter SDK

Invoke is a Godot Engine Android SDK for Solana Mobile Wallet Adapter (MWA).
Full API parity with the React Native SDK, extensible auth token cache, and a
complete example app. Built under a Solana Foundation grant.

## Grant Deliverables

| # | Deliverable | Status |
|---|-------------|--------|
| 1 | Invoke SDK — GDScript + Kotlin plugin, auth token cache | In progress |
| 2 | Documentation — Docusaurus site on Netlify | Planned |
| 3 | InvokeQuest — Example Godot Android app | Planned |

## Repository Structure

| Path | Contents |
|------|----------|
| `addons/mobile_wallet_adapter/` | GDScript SDK |
| `android/plugin/` | Kotlin Android plugin (.aar) |
| `example/invokequest/` | InvokeQuest demo app (Godot 4.x) |
| `docs/` | Docusaurus documentation site |
| `backend/` | Fastify RPC proxy (Railway) |
| `tests/` | Unit + integration tests |
| `_planning/` | Internal planning docs (not part of release) |

## Requirements

- Godot 4.2+
- Android Studio (Giraffe+)
- Android SDK 28+ (target 34)
- Kotlin 1.9+

---

*Solana Foundation Grant · Francisco (Franny) · Portugal · 2026*
