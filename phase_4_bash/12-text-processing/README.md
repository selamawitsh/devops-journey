# Text Processing

Session 12 of Phase 4 — Bash.

## What this covers
- find: locating files recursively by name, type, modification time, and size
- find -exec: running a command once per matched file
- grep: searching file contents, with -i, -c, -n, -v, -A/-B flags
- sed: search-and-replace on text, and why it doesn't modify files by default (needs -i)
- awk: splitting lines into fields ($1, $2...) and filtering with a pattern before an action
- cut: simple delimiter-based field extraction, a lighter alternative to awk for single-field jobs
- sort + uniq: uniq only removes CONSECUTIVE duplicates, which is why sort always runs first
- xargs vs find -exec: batching all matches into one command call vs running the command once per match

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the sed -i in-place danger and the sort-before-uniq requirement, both demonstrated directly
- scripts/ — practice script combining everything from this session

## Key takeaway
sed only prints its result by default — it never touches the file until -i is added, which is a safety feature: preview any transformation before committing it, especially on a real config file. uniq requires sorted input to work correctly, since it only collapses duplicates that are already adjacent. xargs batches results into fewer process calls than find -exec, which matters once the action per file is expensive.
