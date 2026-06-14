# find Command

## Basic syntax
  find  [where to look]  [criteria]  [action]

## Search criteria
| Criteria | Example | Meaning |
|----------|---------|---------|
| `-name` | `-name '*.log'` | filename matches pattern |
| `-iname` | `-iname '*.LOG'` | case insensitive name match |
| `-type f` | `-type f` | regular files only |
| `-type d` | `-type d` | directories only |
| `-type l` | `-type l` | symbolic links only |
| `-user` | `-user root` | owned by user |
| `-group` | `-group www-data` | owned by group |
| `-size +10M` | `-size +10M` | larger than 10MB |
| `-size -1k` | `-size -1k` | smaller than 1KB |
| `-mtime -7` | `-mtime -7` | modified in last 7 days |
| `-mtime +30` | `-mtime +30` | not modified in 30+ days |
| `-perm 644` | `-perm 644` | exact permissions |
| `-perm /222` | `-perm /222` | has write permission for someone |

## Actions
| Action | Meaning |
|--------|---------|
| (default) | print matching paths |
| `-ls` | detailed listing like ls -li |
| `-exec cmd {} \;` | run cmd on each match |
| `-delete` | delete matching files |

## Combining criteria
- Default between criteria is AND
- Use `!` or `-not` to negate
- `2>/dev/null` to suppress permission errors

## Essential examples
```bash
find /var/log -name '*.log'                    # all log files
find /home -user john                          # john's files
find / -size +100M 2>/dev/null                 # large files
find /tmp -mtime +7 -delete                    # clean old tmp files
find /etc -name '*.conf' -type f               # config files
find / -perm /4000 2>/dev/null                 # setuid files (security)
```

## Why this matters in DevOps
Finding large files eating disk space. Finding files with wrong
permissions. Cleaning up old logs. Finding config files. Used weekly.
