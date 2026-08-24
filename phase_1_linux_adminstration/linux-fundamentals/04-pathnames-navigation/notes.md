# Pathnames and Navigation

## The Linux filesystem tree
Everything in Linux lives in one tree starting at `/` (root directory).
There are no drive letters like Windows. Everything hangs off `/`.

## Absolute vs relative paths
- Absolute path: always starts with `/`. Works from anywhere.
  Example: `/etc/hosts`, `/home/selamawit/notes.md`
- Relative path: starts from your current directory. No leading `/`.
  Example: `documents/notes.md`, `../etc/hosts`

## Special path symbols
| Symbol | Meaning |
|--------|---------|
| `/` | root of the entire filesystem |
| `~` | your home directory |
| `.` | current directory |
| `..` | parent directory (one level up) |
| `-` | previous directory you were in |

## Navigation commands
| Command | What it does |
|---------|-------------|
| `pwd` | print working directory |
| `cd /etc` | go to /etc (absolute) |
| `cd documents` | go into documents (relative) |
| `cd ..` | go up one level |
| `cd ~` | go home |
| `cd -` | go to previous directory |
| `cd` | go home (no argument) |

## Key filesystem locations
| Path | What lives there |
|------|----------------|
| `/etc` | system configuration files |
| `/var/log` | log files |
| `/home` | user home directories |
| `/tmp` | temporary files |
| `/bin`, `/usr/bin` | executable programs |
| `/etc/hosts` | hostname to IP mappings |
| `/etc/passwd` | user account info |

## Why this matters in DevOps
You will navigate filesystems on servers constantly. Config files are in
`/etc`. Logs are in `/var/log`. Knowing paths instantly — without thinking —
is fundamental to working fast on a server.
