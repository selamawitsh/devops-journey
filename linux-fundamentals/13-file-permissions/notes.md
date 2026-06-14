# File Permissions

## The three categories
Every file has permissions for three groups:
- u (user/owner) — the person who owns the file
- g (group) — members of the file's group
- o (other) — everyone else

## The three permission types
| Permission | On a file | On a directory |
|-----------|-----------|----------------|
| r (read, 4) | read file contents | list filenames |
| w (write, 2) | modify file | create/delete files in it |
| x (execute, 1) | run as program | enter directory with cd |

## Precedence
User permissions override group. Group overrides other.
The most specific rule wins.

## Reading ls -l output
```
-rw-r--r--  1  selamawit  devs  1234  Jun 13  file.txt
^             ^  ^          ^
|             |  owner      group
|             link count
file type and permissions
```

## File type characters
| Character | Type |
|-----------|------|
| `-` | regular file |
| `d` | directory |
| `l` | symbolic link |
| `c` | character device |
| `b` | block device |

## The 10-character permission string
Position 1: file type
Positions 2-4: owner permissions (rwx)
Positions 5-7: group permissions (rwx)
Positions 8-10: other permissions (rwx)
A `-` in any position means that permission is absent.

Example: `-rwxr-xr--`
- Regular file
- Owner: read, write, execute
- Group: read, execute (no write)
- Other: read only

## Why this matters in DevOps
Wrong permissions break applications. A web server cannot read a config
file if permissions are too restrictive. A script cannot run if execute
is missing. Security vulnerabilities come from permissions too open.
