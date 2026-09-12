# Exit Codes and Conditions

Session 3 of Phase 4 — Bash.

## What this covers
- $? and how every command reports success/failure as a number
- Exit code conventions (0, 1, 2, 126, 127, 128+N) and what they signal
- true and false as commands whose only job is producing an exit code
- The test builtin and its two forms: [ ] and [[ ]]
- Why [ ] is vulnerable to word-splitting on unquoted variables, and [[ ]] is not

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the [ ] vs [[ ]] word-splitting bug, side by side
- scripts/ — practice script combining everything from this session

## Key takeaway
Non-zero exit codes are structured information, not just a red flag (exit 137 = OOM-killed). if statements, and every CI/CD pipeline, are built entirely on checking a command's exit code.
