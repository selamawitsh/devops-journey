# I/O Redirection and Pipes

## The three standard streams
Every program has three streams:
- Stream 0 (stdin): input — keyboard by default
- Stream 1 (stdout): normal output — screen by default
- Stream 2 (stderr): error output — screen by default

## Redirecting output
| Operator | Meaning |
|----------|---------|
| `>` | redirect stdout to file (overwrites) |
| `>>` | redirect stdout to file (appends) |
| `2>` | redirect stderr to file |
| `2>&1` | send stderr to same place as stdout |
| `&>` | redirect both stdout and stderr to file |
| `&>>` | append both stdout and stderr to file |

## Redirecting input
| Operator | Meaning |
|----------|---------|
| `<` | read stdin from file instead of keyboard |

## Pipes
The pipe `|` connects stdout of one command to stdin of the next.
Both commands run at the same time.

  command1 | command2 | command3

## tee — split output two ways
`tee` sends output to both a file AND the screen at the same time.
  ls -l | tee output.txt | less

## /dev/null — the black hole
Redirect anything to `/dev/null` to discard it silently.
  command 2> /dev/null    (discard error messages)
  command &> /dev/null    (discard everything)

## Why this matters in DevOps
Pipes are how you build powerful one-liners. Redirection is how you
save command output to files, capture logs, and discard noise.
You use these every single day.
