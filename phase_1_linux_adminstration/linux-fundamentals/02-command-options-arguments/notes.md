# Command Options and Arguments

## Structure of a Linux command
Every command follows this pattern:
  command  [options]  [arguments]

- Options modify how the command behaves. They start with `-` (short) or `--` (long).
- Arguments are the targets the command acts on (files, directories, text).

## Short vs long options
- Short: `-l`, `-a`, `-n` — single letter, prefixed by dash
- Long: `--long`, `--all`, `--number` — full word, prefixed by double dash
- They often do the same thing: `date -I` == `date --iso-8601`

## Combining short options
You can combine multiple short options:
  ls -la   (same as ls -l -a)
  ls -lah  (long listing, all files, human-readable sizes)

## Key examples
| Command | Meaning |
|---------|---------|
| `ls -l` | long listing |
| `ls -a` | show hidden files |
| `ls -lh` | long listing, human-readable sizes |
| `cal -y` | full year calendar |
| `date -I` | ISO date format |
| `ls -l /etc` | long listing of /etc specifically |

## Why this matters in DevOps
Every tool you use — docker, kubectl, git, systemctl — follows this exact
same pattern. Understanding options and arguments means you can read any
command you have never seen before and figure out what it does.
