# Filter Commands

## What is a filter?
A filter reads input, processes it, and writes output. These commands
are the building blocks of powerful Linux one-liners.

## The six essential filters
| Command | What it does |
|---------|-------------|
| `less` | browse a file interactively (q to quit, / to search) |
| `grep` | search for lines matching a pattern |
| `wc` | count lines, words, characters |
| `head` | show first N lines (default 10) |
| `tail` | show last N lines (default 10) |
| `sort` | sort lines alphabetically or numerically |

## grep options
| Option | Meaning |
|--------|---------|
| `-i` | case insensitive |
| `-n` | show line numbers |
| `-v` | show lines that do NOT match |
| `-r` | search recursively in directories |
| `-l` | show only filenames that match |
| `^pattern` | lines starting with pattern |
| `pattern$` | lines ending with pattern |

## wc options
| Option | Meaning |
|--------|---------|
| `-l` | count lines only |
| `-w` | count words only |
| `-c` | count characters only |

## sort options
| Option | Meaning |
|--------|---------|
| `-n` | numeric sort |
| `-r` | reverse order |
| `-k N` | sort by field number N |

## head / tail
- `head -5 file` — first 5 lines
- `tail -5 file` — last 5 lines
- `tail -f file` — follow file in real time (for logs)

## Why this matters in DevOps
`tail -f /var/log/syslog` watches logs live. `grep ERROR /var/log/app.log`
finds errors instantly. `wc -l` counts lines in a file. These commands
are used every single day by every DevOps engineer.
