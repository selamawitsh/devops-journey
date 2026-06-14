# Wildcards and Brace Expansion

## Wildcards (glob patterns)
The shell expands wildcards BEFORE the command runs.

| Pattern | Matches |
|---------|---------|
| `*` | zero or more characters |
| `?` | exactly one character |
| `[abc]` | any one of a, b, or c |
| `[a-z]` | any character in range a to z |
| `[!abc]` | any character NOT in the set |
| `[[:digit:]]` | any digit 0-9 |
| `[[:alpha:]]` | any letter |
| `[[:upper:]]` | any uppercase letter |

## Examples
- `ls *.conf` — all files ending in .conf
- `ls app?.log` — app1.log, app2.log but not app10.log
- `rm *.tmp` — delete all .tmp files
- `ls [A-Z]*` — files starting with uppercase letter

## Brace expansion
Brace expansion generates strings. Happens before wildcard matching.

- `echo file{1,2,3}.txt` → file1.txt file2.txt file3.txt
- `mkdir {logs,configs,backups}` → creates 3 directories
- `echo {a..e}` → a b c d e
- `mkdir app{1..5}` → app1 app2 app3 app4 app5

## Tilde expansion
- `~` expands to your home directory
- `~username` expands to that user's home directory

## Why this matters in DevOps
`rm *.log` to clean up logs. `cp *.conf /backup/` to back up configs.
`mkdir {dev,staging,prod}` to create environments. Used constantly.
