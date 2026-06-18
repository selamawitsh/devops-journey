# Manage User and Group Accounts and Related System Files

## Why this matters
Every process on Linux runs as some user, and every file is owned by some user
and some group. Access control is built entirely on this idea — if you don't
understand users and groups, you can't reason about permissions, sudo, or
service security. This is the layer almost every DevOps task touches: creating
a deploy user, locking a former employee's account, giving a CI agent the
right (and only the right) access.

## What is a user
A user account is a security boundary. Internally the system only cares about
the numeric UID, not the username — the name is just for humans. There are
three categories:
- root (UID 0) — full system access, the superuser
- system users — run background services/daemons, not meant for interactive login
- regular users — normal day-to-day accounts with limited privileges

Useful commands to inspect identity:
- `id` — show your UID, primary group, and all secondary groups
- `whoami` — just your username
- `who` / `w` — who else is logged in, and what they're doing
- `ls -l` / `ls -ld` — see the owner of a file / directory
- `ps -au` — see which user owns a running process

## What is a group
A group lets you grant the same access to a set of users instead of one at a
time. Every user has exactly one **primary group** (used as the group owner
for any new file they create) and can belong to any number of **secondary
groups** (additional access, doesn't affect file ownership on creation).

By default, creating a regular user also creates a private group with the
same name, containing only that user — this is the "user private group"
pattern, and it's why permissions stay clean by default.

Example: if user01's primary group is user01, and secondary groups are wheel
and webadmin, then user01 can read anything any of those three groups can
read — primary vs secondary makes no difference for *access*, only for
*new file ownership*.

## Where account info is stored
Locally: /etc/passwd and /etc/shadow for users, /etc/group (and /etc/gshadow)
for groups. The system can also be configured to look up identity in LDAP,
NIS/NIS+, Kerberos, or an SMB/Windows domain controller — but for a single
Ubuntu box, it's the local files.

## /etc/passwd — one line per user, colon-separated
    username:x:UID:GID:full_name:home_dir:shell

- The "x" is historical — passwords used to live here, but this file is
  world-readable, so they were moved out for security. The field is now
  just a placeholder.
- The full name field is sometimes called the GECOS field.
- The shell field is the program started after login (/bin/bash, or
  /sbin/nologin to block interactive login entirely).

## /etc/shadow — the actual password data, root-only readable
    username:hashed_password:last_changed:min_days:max_days:warn_days:inactive_days:expire_date:

Fields, in order:
1. username
2. hashed password (format below)
3. days since 1970-01-01 when password was last changed
4. minimum days before it can be changed again
5. maximum days before a change is forced
6. warning days before expiry
7. days of inactivity after expiry before the account is auto-locked
8. account expiration date (days since epoch); empty = never expires
9. reserved, usually empty

Hashed password format: $id$salt$hash — e.g. $6$saltvalue$hashvalue.
The id tells you the algorithm: 6 = SHA-512 (default on modern systems),
5 = SHA-256, 1 = MD5. The salt is random per-account, which is what defeats
precomputed ("rainbow table") password-cracking attacks — even if two users
pick the same password, their hashes look completely different.

## /etc/group — one line per group, colon-separated
    groupname:x:GID:comma_separated_secondary_members

Only secondary members show up in the member list — a user's primary group
membership lives in /etc/passwd, not here.

## UID / GID ranges (the convention to remember)
- 0 — root
- 1–999 (varies by distro, sometimes 1–200 then 201–999) — system accounts,
  for daemons/services, not real humans
- 1000+ — regular human users

This is why "always add the group before the user, and check the UID is
above the cutoff" matters — accounts below the cutoff are treated as system
accounts, not people.

## Creating, modifying, deleting users
    useradd username                  # creates user + home dir + private group
    useradd -u 610 -g 1200 -G audio,video -m -b /new1 catbert
    usermod -c "New Name" -s /bin/csh username   # change comment/shell
    usermod -aG groupname username    # ADD to a secondary group (note -a!)
    usermod -g groupname username     # CHANGE primary group
    userdel username                  # removes account, leaves home dir
    userdel -r username                # removes account AND home dir

Important gotcha: if you userdel without -r, the home directory's files are
now owned by a UID that no longer maps to a name. If you later create a new
user that happens to get reassigned that same UID, that new user silently
inherits ownership of the old files — a real security leak. Use
`find / -nouser -o -nogroup` to hunt down orphaned files.

Defaults for new users come from /etc/default/useradd and /etc/login.defs
(home dir base, default shell, UID/GID ranges, password aging defaults).
Changing these files only affects users created afterward, not existing ones.

## Creating, modifying, deleting groups
    groupadd groupname
    groupadd -g 10000 groupname        # specify exact GID
    groupmod -n newname oldname        # rename
    groupmod -g newgid groupname       # change GID
    groupdel groupname                 # fails if it's still someone's primary group

## Switching primary group temporarily
    newgrp groupname

Lets you create files owned by a different group for the rest of the shell
session, without permanently changing your primary group. Reverts on logout.

## Setting and aging passwords
    passwd username                    # set/change a password
    chage -l username                  # list current aging settings
    chage -m 3 -M 90 -W 7 -I 14 username
        -m  minimum days between changes
        -M  maximum days before forced change
        -W  warning days before expiry
        -I  inactivity days after expiry before lock
        -E  account expiration date (YYYY-MM-DD)
        -d 0   forces a password change on next login

System-wide defaults for new accounts live in /etc/login.defs
(PASS_MAX_DAYS, PASS_MIN_DAYS, PASS_WARN_AGE).

## Locking / disabling accounts
    usermod -L username                # lock (disable password login)
    usermod -U username                # unlock
    usermod -e 2026-07-30 username      # set expiry date
    usermod -s /sbin/nologin username   # block interactive shell entirely

/sbin/nologin politely refuses an interactive login attempt but doesn't
necessarily block all access (e.g. file transfer over SSH key auth can still
work) — it's not a full account freeze on its own, just a shell that says no.

## su vs sudo — the actual difference
- `su - username` switches identity, but you need THAT user's password.
  Running `su -` alone (no username) tries to become root, requiring root's
  password.
- `su username` (no dash) keeps your old shell environment.
  `su - username` (with dash) gives a full clean login environment as the
  target user. As an admin, almost always use the dash version.
- `sudo command` runs a single command as another user (root by default),
  authenticating with YOUR OWN password, as long as /etc/sudoers grants you
  permission. This is why sudo is preferred over handing out the root
  password — access can be granted/revoked per user without anyone knowing
  root's actual password.
- `sudo -i` gives you a full interactive root shell (with root's environment).
  `sudo -s` gives a root shell but keeps your own environment.

## /etc/sudoers — who is allowed to sudo, and how
Never edit this file directly with a normal editor — always use `visudo`,
which validates syntax before saving and locks the file so two admins can't
corrupt it editing simultaneously.

    %wheel ALL=(ALL:ALL) ALL

Reading this left to right: members of the wheel group (%wheel), on any host
(first ALL), can run commands as any user (second ALL) in any group (third
ALL), running any command (final ALL).

Cleaner in practice: drop a single-purpose file into /etc/sudoers.d/ instead
of editing the main file:

    echo "%consultants ALL=(ALL) ALL" > /etc/sudoers.d/consultants

You can also scope it down to one command, or skip the password prompt:

    %games ALL=(operator) /bin/id
    ansible ALL=(ALL) NOPASSWD: ALL

## Special-purpose / system accounts
Accounts like mail, ftp, nobody, apache, ntp exist to own files and run
services — they're intentionally given /sbin/nologin or /bin/false as their
shell so direct interactive login always fails, even though the account
itself is still functional for ownership/permission purposes.

## Quick command reference
| Task                          | Command                          |
|--------------------------------|-----------------------------------|
| Create user                   | useradd                          |
| Modify user                   | usermod                          |
| Delete user                   | userdel                          |
| Create group                  | groupadd                         |
| Modify group                  | groupmod                         |
| Delete group                  | groupdel                         |
| Set/change password           | passwd                           |
| Password aging policy         | chage                            |
| Temporarily change primary group | newgrp                        |
| Who am I / who's logged in     | whoami, who, w, id                |
| Edit sudoers safely            | visudo                           |
