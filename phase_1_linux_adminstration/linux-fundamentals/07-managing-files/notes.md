# Managing Files

## Essential file management commands
| Command | What it does |
|---------|-------------|
| `mkdir dir` | create directory |
| `mkdir -p a/b/c` | create nested directories |
| `rmdir dir` | delete empty directory |
| `cp src dst` | copy file |
| `cp -r src dst` | copy directory recursively |
| `mv src dst` | move or rename |
| `rm file` | delete file (no undo!) |
| `rm -r dir` | delete directory and contents |
| `rm -rf dir` | force delete, no prompts (dangerous) |
| `touch file` | create empty file or update timestamp |

## cp options
| Option | Meaning |
|--------|---------|
| `-r` | recursive (for directories) |
| `-i` | interactive, ask before overwrite |
| `-p` | preserve timestamps and permissions |

## mv — rename or move
- `mv old.txt new.txt` — renames the file
- `mv file.txt /tmp/` — moves to /tmp
- `mv *.txt /tmp/` — moves all .txt files

## rm — permanent deletion
There is no recycle bin in Linux. `rm` is final.
Use `-i` to be prompted before each deletion.
Never run `rm -rf /` — it destroys the entire system.

## touch — create or update
- Creates an empty file if it does not exist
- Updates the last-modified timestamp if it does exist
- Used in scripts to create placeholder files

## Why this matters in DevOps
You create config files, move logs, clean up old deployments, copy
configs between environments. These commands are used constantly.
