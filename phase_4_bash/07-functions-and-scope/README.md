# Functions and Scope

Session 7 of Phase 4 — Bash.

## What this covers
- Defining and calling functions (both function name() and function name styles)
- Functions must be defined before they're called (no hoisting — Bash reads top to bottom)
- Function arguments: $1, $2, $# are local to the function call, separate from the script's own arguments
- local variables and why Bash defaults to global scope without it
- return vs echo: return is exit-code only (0-255, wraps on overflow), echo is how you get real data out of a function

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the return-overflow bug and the local scope bug, both demonstrated directly
- scripts/ — practice script combining everything from this session

## Key takeaway
return is exclusively for signaling success/failure via a 0-255 exit code — never for handing back computed data, which wraps silently on overflow (return 300 becomes exit code 44). echo, captured with $(), is how a function returns real values. Without local, a variable assigned inside a function silently overwrites a global of the same name — always use local by default for function-only variables.
