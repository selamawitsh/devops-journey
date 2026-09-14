# stdin, stdout, stderr, and Redirection

Session 9 of Phase 4 — Bash.

## What this covers
- The three default file descriptors: 0 (stdin), 1 (stdout), 2 (stderr)
- Why normal output and error output are separate streams
- > (overwrite) vs >> (append)
- 2> to redirect stderr alone, and 2>&1 to combine it with stdout
- The 2>&1 ordering gotcha — why > file.txt 2>&1 works but 2>&1 > file.txt does not
- Pipes (|) to chain commands together

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session
- examples/ — the 2>&1 ordering bug demonstrated directly
- scripts/ — practice script combining everything from this session

## Key takeaway
stdout and stderr are separate channels specifically so scripts and cron jobs can capture clean data without error noise mixed in. > wipes a file every run; >> appends — using > where >> was intended is a common accidental log-wiping bug. Redirection order matters: stdout must be redirected before stderr is told to follow it.
