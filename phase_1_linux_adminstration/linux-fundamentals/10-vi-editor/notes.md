# vi Editor

## Why learn vi?
vi is available on EVERY Linux/Unix system. Even on a broken system
with nothing else working, vi is there. As a DevOps engineer you will
SSH into servers where nano or other editors may not exist.

## Three modes
vi has three modes — this is what confuses beginners:

1. Command mode (default when you open vi)
   - Movement, deletion, copying
   - Every key is a command, not text input

2. Insert mode (press `i` to enter)
   - What you type goes into the file
   - Press `Esc` to return to command mode

3. Bottom-line mode (press `:` from command mode)
   - Commands that need arguments: save, quit, search/replace

## Minimum survival commands
| Key | Action |
|-----|--------|
| `i` | enter insert mode (before cursor) |
| `A` | enter insert mode at end of line |
| `Esc` | return to command mode |
| `:w` | save file |
| `:q` | quit |
| `:wq` | save and quit |
| `:q!` | quit without saving (force) |
| `dd` | delete current line |
| `yy` | copy current line |
| `p` | paste |
| `/pattern` | search forward |
| `n` | next match |
| `gg` | go to first line |
| `G` | go to last line |
| `u` | undo |

## Opening and saving
- `vi filename` — open file
- `:w` — save
- `:wq` — save and quit
- `:q!` — quit without saving

## Why this matters in DevOps
Editing a config file on a server where only vi is available.
Fixing a broken crontab. Quick edits during an incident. You need vi.
