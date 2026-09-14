# Script Arguments

Session 8 of Phase 4 — Bash.

## What this covers
- $0, $1-$9, $# — positional arguments and argument count
- $@ vs $* and why quoting ("$@") is the only version safe for forwarding arguments to another command
- shift — processing an unknown number of arguments in a loop
- getopts — proper flag-style arguments (-e value, -v), paired with case

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the $@ vs $* word-splitting comparison
- scripts/ — practice script combining everything from this session

## Key takeaway
Unquoted $@ and $* behave identically (both word-split). "$@" quoted is the only form that preserves each original argument intact — always use it when forwarding a script's arguments to another command (e.g. a wrapper around kubectl or docker). getopts + case is how real CLI tools parse flags.
