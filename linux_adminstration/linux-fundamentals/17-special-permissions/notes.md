# Special Permissions — setuid, setgid, sticky bit

## Three special permission bits
In addition to the 9 standard bits, there are 3 special ones.

## setuid (SUID) — run as file owner
- Symbolic: `u+s`
- Octal: 4 (prepend to regular octal, e.g. 4755)
- Shows as `s` in owner execute position
- On files: process runs as the FILE OWNER, not the person running it
- On directories: no effect

Real example: `/usr/bin/passwd`
  - Owned by root
  - Has setuid bit set
  - When YOU run it, it runs AS ROOT so it can write to /etc/shadow
  - You cannot write /etc/shadow yourself, but passwd can

## setgid (SGID) — run as file group / inherit group
- Symbolic: `g+s`
- Octal: 2 (prepend, e.g. 2755)
- Shows as `s` in group execute position
- On files: process runs as the FILE GROUP
- On directories: new files created inside inherit the directory's group
  (very useful for team shared directories)

## Sticky bit — protect files in shared directories
- Symbolic: `o+t`
- Octal: 1 (prepend, e.g. 1777)
- Shows as `t` in other execute position
- On directories: users can only delete files THEY OWN, even with write permission
- Classic example: `/tmp` has 1777 — everyone can write, but you can only delete your own files

## Setting special permissions
Symbolic:
  chmod u+s file          # set setuid
  chmod g+s directory     # set setgid
  chmod o+t directory     # set sticky bit
  chmod u-s file          # remove setuid

Octal (4-digit):
  chmod 4755 file         # setuid + owner rwx + group/other rx
  chmod 2770 directory    # setgid + owner/group rwx + other nothing
  chmod 1777 directory    # sticky + everyone rwx
  chmod 0770 directory    # remove special bits + owner/group rwx

## Reading special permissions in ls -l
- `-rwsrwxrwx` — setuid set (lowercase s = execute also set)
- `-rwSrwxrwx` — setuid set (uppercase S = execute NOT set)
- `drwxrwsr-x` — setgid on directory
- `drwxrwxrwt` — sticky bit (lowercase t = execute also set)

## Why this matters in DevOps
- Understanding setuid helps you do security audits (look for unauthorized setuid files)
- setgid on shared directories ensures team members' files belong to the right group
- Sticky bit on /tmp prevents users from deleting each other's temp files
