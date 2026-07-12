# User and Group Account Management

## Why this comes after permissions
Permissions (rwx, chmod, chown) only make sense once you understand WHO
the "user" and "group" actually are. This topic is about creating and
managing those identities — the accounts that own files and run processes.

## Core identity concepts
- UID (User ID) — a unique number identifying a user. 0 = root.
- GID (Group ID) — a unique number identifying a group.
- Primary group — every user has exactly one. Set at account creation.
- Secondary (supplementary) groups — a user can belong to many.

## Creating a group
  groupadd -g GID groupname

- `-g` sets a specific GID. If omitted, the system picks the next free one.

## Creating a user — useradd
  useradd -u UID -g primarygroup -G group1,group2 -m -d /path/to/home -k /etc/skel username

| Flag | Meaning |
|------|---------|
| `-u` | specific UID |
| `-g` | primary group (name or GID) |
| `-G` | secondary groups, comma-separated, no spaces |
| `-m` | create the home directory |
| `-d` | custom home directory path (instead of default /home/username) |
| `-k` | skeleton directory to copy initial files from (default /etc/skel) |

## /etc/skel
A template directory. Whatever files/folders exist in `/etc/skel` get
copied into a new user's home directory automatically when `-m` is used.
This is how every new user gets `.bashrc`, `.profile`, etc. by default.
You can customize `/etc/skel` to include your own files (like a `finance/`
folder with an `accounting` file) so every new user gets them too.

**Note:** most commands that change system accounts require root. Prefix
with `sudo` (or run as root) when following the examples on a real host.

## Setting a password
  passwd username

Prompts interactively for a new password. Only root can set another
user's password this way.

## Verifying account creation
| File | What it stores |
|------|----------------|
| `/etc/passwd` | username, UID, GID, home dir, shell (NOT the password) |
| `/etc/group` | group name, GID, list of secondary members |
| `/etc/shadow` | encrypted password and password aging info (root-only readable) |

  grep username /etc/passwd
  grep groupname /etc/group
  grep username /etc/shadow

For systems using LDAP or NSS, `getent` is a more portable way to query:

  getent passwd username
  getent group groupname

## /etc/passwd field order
  username:x:UID:GID:comment:home_dir:shell
The `x` means the real password is stored in /etc/shadow, not here.

## /etc/shadow field order
  username:encrypted_password:last_change:min:max:warn:inactive:expire:reserved

| Field | Meaning |
|-------|---------|
| last_change | days since Jan 1 1970 password was last changed |
| min | minimum days between password changes |
| max | maximum days before password must change |
| warn | days of warning before expiry |
| inactive | days after expiry before account is disabled |
| expire | absolute date the account itself expires |

## chage — managing password aging
  chage -m MIN -M MAX -W WARN -I INACTIVE -E EXPIRE_DATE username

| Flag | Meaning |
|------|---------|
| `-m` | minimum days between password changes |
| `-M` | maximum days before password must change |
| `-W` | warning days before expiry |
| `-I` | inactive days after expiry before account disabled |
| `-E` | account expiration date (YYYY-MM-DD) |

  man 5 shadow    # explains shadow file fields in detail

## Secondary groups and usermod
  usermod -aG groupname username

**Warning:** `-G` without `-a` will replace a user's secondary groups and can
accidentally remove important memberships — prefer `-aG` when adding groups.

To test a new secondary group without logging out, use `newgrp groupname` or
`sg groupname -c "command"`.

`-aG` APPENDS to secondary groups. Without `-a`, `-G` REPLACES all
secondary groups — a very common and dangerous mistake.

## sudo and sudoers.d
Instead of editing `/etc/sudoers` directly (risky), you create a file
inside `/etc/sudoers.d/` for a specific group or user.

Example content to give a group full admin rights:
  %admin1 ALL=(ALL) NOPASSWD: ALL

The `%` prefix means "this is a group, not a user."
Always edit sudoers files with `visudo -f /etc/sudoers.d/filename`
because it checks syntax before saving — a broken sudoers file can
lock everyone out of sudo.

## Why this matters in DevOps
Every server you manage needs service accounts (for apps), admin
accounts (for engineers), and proper group-based access control.
Getting UID/GID conflicts wrong, or secondary groups wrong, breaks
permissions across the whole system. Password aging and sudoers are
core to security compliance on any production server.

## Notes on UID/GID ranges
- Many distributions reserve low UIDs/GIDs (<1000) for system accounts. Use
  UIDs >= 1000 for human users unless you have a specific reason otherwise.
- When choosing explicit UIDs/GIDs, check `/etc/login.defs` and the local
  distribution policy to avoid collisions.
