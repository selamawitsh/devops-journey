# Command History

## How bash stores history
Bash remembers every command you type. They are stored in `~/.bash_history`.
This file survives logout and login. Default size is 500-1000 commands.

## Viewing history
| Command | What it does |
|---------|-------------|
| `history` | show all history |
| `history 10` | show last 10 commands |
| `history -c` | clear history |

## Re-executing commands
| Shortcut | What it does |
|----------|-------------|
| `!!` | repeat last command |
| `!85` | run command number 85 |
| `!ls` | run most recent command starting with ls |
| Up arrow | scroll back through history |
| `Ctrl+R` | reverse search through history |

## Line editing shortcuts
| Shortcut | What it does |
|----------|-------------|
| `Ctrl+A` | jump to beginning of line |
| `Ctrl+E` | jump to end of line |
| `Ctrl+K` | delete from cursor to end of line |
| `Esc+.` | paste last argument of previous command |
| `Alt+.` | same as Esc+. |

## Why this matters in DevOps
On a production server you run many commands in sequence. History lets
you re-run long commands without retyping. `Ctrl+R` to search history
is one of the most used shortcuts by experienced engineers.
