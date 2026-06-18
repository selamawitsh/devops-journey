# umask — Default File Permissions

## What is umask?
umask (user file-creation mask) controls what permissions are REMOVED
from newly created files and directories.

It does not SET permissions — it SUBTRACTS from the maximum.

## Maximum starting permissions
- New regular file: 0666 (rw-rw-rw-)
- New directory: 0777 (rwxrwxrwx)

## How umask works
umask bits that are SET are permissions that are REMOVED.

Example with umask 0022:
- File: 0666 - 0022 = 0644 (rw-r--r--)
- Directory: 0777 - 0022 = 0755 (rwxr-xr-x)

Example with umask 0027:
- File: 0666 - 0027 = 0640 (rw-r-----)
- Directory: 0777 - 0027 = 0750 (rwxr-x---)

## Checking umask
  umask            # shows current umask
  umask -S         # shows in symbolic form

## Setting umask
  umask 022        # set for current session only
  umask 027        # more restrictive — no access for others

## Making umask permanent
Add to `~/.bashrc` or `~/.bash_profile`:
  echo "umask 027" >> ~/.bashrc

## Common umask values
| umask | Files get | Dirs get | Use case |
|-------|-----------|----------|---------|
| 022 | 644 | 755 | standard — others can read |
| 027 | 640 | 750 | group can read, others nothing |
| 077 | 600 | 700 | private — only owner |
| 002 | 664 | 775 | collaborative group work |

## Why this matters in DevOps
If a service creates files with wrong default permissions, it can be
a security issue. You may need to set umask in service startup scripts
to ensure files are created with correct permissions automatically.
