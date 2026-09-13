# If / Elif / Else and Conditions

Session 4 of Phase 4 — Bash.

## What this covers
- if / elif / else structure and evaluation order (stops at first true branch)
- Numeric comparison operators: -eq -ne -gt -ge -lt -le
- String comparison operators: == != -z -n
- File test operators: -f -d -e -r -w -x
- Combining conditions with && and || inside [[ ]]

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — file test and combined condition examples
- scripts/ — practice script combining everything from this session

## Key takeaway
Numeric and string comparisons use different operators (-eq vs ==) because they compare different things — mixing them up is a common source of subtle bugs, especially with version-like strings. File tests should gate any action that assumes a file or directory exists, rather than letting the script crash on a missing path.
