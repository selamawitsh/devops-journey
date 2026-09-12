# Variables and Quoting

Session 2 of Phase 4 — Bash.

## What this covers
- Declaring variables and the strict no-space rule around =
- Single quotes vs double quotes, and when to prefer which
- Escaping a special character inside double quotes
- Command substitution: $(...) vs the legacy backtick syntax
- The difference between a plain shell variable and an exported (environment) variable
- readonly variables

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — small standalone examples, one concept each
- scripts/ — practice script combining everything from this session

## Key takeaway
A plain variable only exists in the shell that created it. export copies it into every child process spawned afterward — this is exactly how env vars work in Docker containers and CI/CD pipelines. Default to single quotes unless you specifically need expansion.
