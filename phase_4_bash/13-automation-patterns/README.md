# Automation Patterns

Session 13 of Phase 4 — Bash. Last concept session before the three capstone projects.

## What this covers
- Idempotency: a script should be safe to run any number of times with the same end result, no errors from "it's already done"
- Dry-run mode: a --dry-run flag that describes actions instead of executing them, using the same command path for both so the preview stays trustworthy
- Proper logging: INFO to stdout, WARN/ERROR to stderr, so failures can be filtered and monitored independently of normal output
- Configuration separated from logic: a config file loaded with source, so settings can change without touching script code

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the non-idempotent vs idempotent mkdir comparison
- scripts/ — practice script combining everything from this session

## Key takeaway
These four patterns are what separate a script trusted to run unattended in production from one that only works when run once, by hand, on a clean system. Project 1 (backup script), Project 2 (health checker), and Project 3 (deployment helper) are all built directly on top of these four habits.
