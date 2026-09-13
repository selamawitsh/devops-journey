# Case Statements

Session 6 of Phase 4 — Bash.

## What this covers
- Basic case structure and how it matches a value against patterns
- The *) catch-all branch and why production scripts always need one
- Matching multiple values in one branch with |
- Glob-style pattern matching inside case (e.g. matching by file extension)

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — case matching on a y/n answer and on file extensions
- scripts/ — practice script combining everything from this session

## Key takeaway
case is the direct mechanism behind most Linux service scripts you already use without thinking about it (systemctl/init-style start|stop|restart handling). Always include a *) branch — it's the difference between a clear "unknown option" message and a script that silently does nothing when given unexpected input.
