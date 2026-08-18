# Phase 1 — Linux Package Management

Part of the [DevOps Engineering Roadmap](../) — Intern level.

## What this covers
- `dpkg` vs `apt`: the two-layer model behind every package operation on Debian/Ubuntu
- Dependency resolution and how apt validates before touching disk
- Held vs pinned packages
- Adding third-party repos safely with `signed-by` GPG keys
- Diagnosing and recovering from a broken dependency state

## Structure
| File | Purpose |
|---|---|
| `notes.md` | Theory: dpkg/apt split, dependency resolution, holds/pins, repos & GPG |
| `practice.md` | Hands-on commands with expected output |
| `challenge.md` | Break-things exercise prompt |
| `ChallengeAndAnswer.md` | Worked solution + diagnosis + lessons learned |
| `screenshots/` | Terminal output screenshots supporting the exercises above |

## Lessons learned
- apt validates a requested version exists *before* building a dependency graph — a failed pinned-version install is safe, not a broken state.
- `signed-by` scopes trust per-repo; the deprecated `apt-key add` trusted a key globally, which was a real security regression.

