# man Pages and Built-in Help

## Three ways to get help
1. `man command` — the manual (full reference)
2. `command --help` — quick summary of options
3. `info command` — longer documentation (some commands)

## man pages
- `man ls` — manual for ls
- `man 5 crontab` — section 5 (file formats) for crontab
- `man 2 open` — section 2 (system calls) for open

## man page sections
| Section | Contains |
|---------|---------|
| 1 | User commands (programs you run) |
| 2 | System calls (kernel interface) |
| 3 | Library functions |
| 4 | Device files |
| 5 | File formats and config files |
| 7 | Miscellaneous |
| 8 | System administration commands (root) |

## Navigating man pages (it opens in less)
| Key | Action |
|-----|--------|
| Space | next page |
| b | previous page |
| /pattern | search |
| n | next match |
| q | quit |

## Searching for commands by keyword
- `man -k keyword` — search all man pages for keyword
- `apropos keyword` — same as man -k
- `whatis command` — one-line description

## --help flag
Almost every GNU command supports `--help`:
  ls --help
  grep --help
  find --help

## Why this matters in DevOps
You will constantly encounter commands and flags you have not seen.
`man` and `--help` are how you figure them out without googling.
Being able to read documentation is a core engineering skill.
