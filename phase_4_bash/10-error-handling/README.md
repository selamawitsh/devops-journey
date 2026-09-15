# Error Handling

Session 10 of Phase 4 — Bash.

## What this covers
- set -e: stop the script immediately when any command fails, instead of Bash's default of continuing regardless
- set -u: stop on any reference to an undefined variable, instead of silently treating it as empty
- set -o pipefail: surface a failure hidden earlier in a pipeline, instead of only reporting the last command's exit code
- set -euo pipefail as the standard combined line for production scripts
- trap: run cleanup code no matter how a script's process ends (normal completion, a failure under set -e, or manual interruption)

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the undefined-variable path bug and the pipefail rightmost-failure behavior, both demonstrated directly
- scripts/ — practice script combining everything from this session

## Key takeaway
By default Bash continues past failed commands, silently treats undefined variables as empty strings, and only reports a pipeline's last command's exit code. Each of set -e, set -u, and set -o pipefail closes one of these gaps. trap ensures cleanup code (removing temp files, releasing a lock) runs even if the script is killed mid-execution — without it, an interrupted script can leave behind state that breaks the next run.
