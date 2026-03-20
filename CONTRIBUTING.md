# Contributing to Invoke SDK

Thank you for your interest in contributing!

## Branch Strategy

- `main` — stable releases only, do not push directly
- `develop` — all active development targets this branch
- `feature/*` — new features (e.g. `feature/sign-messages`)
- `fix/*` — bug fixes (e.g. `fix/auth-token-expiry`)

## Workflow

1. Fork the repo
2. Create your branch from `develop`: `git checkout -b feature/your-feature`
3. Make your changes
4. Commit with a descriptive message (see format below)
5. Push to your fork and open a PR against `develop`

## Commit Message Format

`type(scope): short description`

Examples:
- `feat(sdk): add sign_messages GDScript method`
- `fix(kotlin): handle AuthorizationNotValidException on reauth`
- `docs: add auth cache guide`
- `chore: update .gitignore`

Types: `feat`, `fix`, `docs`, `chore`, `test`, `refactor`

## Code Style

- GDScript: follow Godot 4.x style guide, snake_case everything
- Kotlin: standard Android/Kotlin conventions, coroutines for async
- All signals snake_case
- All errors emitted via signals — never throw to GDScript layer

## Reporting Issues

Open a GitHub Issue with:
- Godot version
- Android device + API level
- Wallet app + version
- Steps to reproduce
- Expected vs actual behaviour

---

*Invoke SDK — Solana Foundation Grant Project*
