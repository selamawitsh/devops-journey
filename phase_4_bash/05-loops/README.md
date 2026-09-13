# Loops

Session 5 of Phase 4 — Bash.

## What this covers
- for loops over globs and word lists
- The nullglob gotcha: an unmatched glob pattern is passed through literally by default
- while vs until (run while true vs run until true — mirror images)
- Arithmetic expansion: $(( )) vs command substitution $( )
- break (exit the loop entirely) vs continue (skip to the next iteration)

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the nullglob bug demonstrated directly
- scripts/ — practice script combining everything from this session

## Key takeaway
A for loop over an unmatched glob (*.log with no matching files) runs once with the literal pattern as a string, unless shopt -s nullglob is set. This is a real production bug class in cleanup/rotation scripts run against an empty directory.
