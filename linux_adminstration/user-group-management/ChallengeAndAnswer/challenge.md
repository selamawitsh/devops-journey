# Real-World DevOps Challenge — User and Group Account Management

## Corrected and completed by Selamawit

## Scenario
You are the DevOps engineer for a small fintech startup. The engineering
team is onboarding two new backend developers and one new database
administrator. You also need to set up a shared group for an upcoming
audit so external auditors get strictly limited, temporary access.

---

## Question 1 — New department group
Create a group called `backend` with GID `1500`.

**Command:**
```
groupadd -g 1500 backend
```
**Verify:**
```
grep backend /etc/group
```

---

## Question 2 — Onboard two developers
Create two users:
- `alemu`, UID `2001`, primary group `backend`, secondary groups
  `docker` and `developers`, home directory `/srv/users/alemu`
- `bethel`, UID `2002`, same group setup, home directory `/srv/users/bethel`

Both home directories should be created and populated from the skeleton
directory.

**Commands:**
```
useradd -u 2001 -g backend -G docker,developers -d /srv/users/alemu -m alemu

useradd -u 2002 -g backend -G docker,developers -d /srv/users/bethel -m bethel
```

Note: the `-m` flag is required to actually create and populate the
home directory. Without it, only the passwd entry is written the
directory itself is never made.

---

## Question 3 — Verify
Confirm both users exist correctly in the system account files.
Confirm the backend group shows both users as members.
Confirm both home directories exist with correct ownership.

**Commands:**
```
grep -E 'alemu|bethel' /etc/passwd

grep backend /etc/group

ls -ld /srv/users/alemu
ls -ld /srv/users/bethel
```

**What you observed:**
```
Both users appear in /etc/passwd with correct UID, GID, and home path.
backend group's primary GID is referenced by both users via /etc/passwd
field 4 — backend itself shows no secondary members since both
memberships here are PRIMARY, not secondary, so /etc/group's member
list for backend stays empty unless someone is added with -aG backend
on top of another primary group.
Both home directories exist, owned by their respective user and group.
```

---

## Question 4 — Database administrator with strict password policy
Create a user `selam_dba`, UID `2003`, with a home directory at
`/srv/users/selam_dba`. Set their password. Then configure password
aging so that:
- They must wait at least 5 days between password changes
- Their password expires every 45 days
- They get 3 days of warning before expiry
- Their account is disabled 7 days after the password expires if not changed
- The account itself expires on June 30 next year

**Commands:**
```
useradd -u 2003 -d /srv/users/selam_dba -m selam_dba
passwd selam_dba

chage -m 5 -M 45 -W 3 -I 7 -E 2027-06-30 selam_dba
```

**Verify by checking the shadow entry. Decode each field:**
```
grep selam_dba /etc/shadow
```
or more readably:
```
chage -l selam_dba
```

```
last_change: date the password was last set (today's date, since I just set it)
min: 5
max: 45
warn: 3
inactive: 7
expire: 2027-06-30
```

---

## Question 5 — Temporary audit access
Create a group called `auditors` (let the system assign the GID).
Create a user `external_auditor` with this group as primary,
home directory `/srv/users/external_auditor`. Set the account to
expire automatically in exactly 14 days from today.

**Commands:**
```
groupadd auditors
useradd -g auditors -d /srv/users/external_auditor -m external_auditor

chage -E $(date -d "+14 days" +%Y-%m-%d) external_auditor
```

Note: chage -E does not accept relative shorthand like "14d". It needs
an actual calendar date. I use `date -d "+14 days" +%Y-%m-%d` to
calculate that date and feed it directly into chage with command
substitution $(...). Also fixed the username typo
(exernal_auditors -> external_auditor) and added -m.

**Why is using account expiration safer here than just remembering
to delete the account manually later? Explain in your own words:**
```
A manually remembered deletion depends on a human not forgetting —
if I'm on leave or busy that week, the account stays active past
when it should. Account expiration is enforced automatically by the
system the moment the date passes, with no dependency on anyone
remembering anything. For temporary external access this matters a
lot, since forgetting to revoke it is a real security risk.
```

---

## Question 6 — Fixing a mistake
A teammate ran this command to add `bethel` to the `audit-readonly`
group:
```
usermod -G audit-readonly bethel
```
After running this, `bethel` lost membership in the `backend` group's
secondary memberships you set up earlier. What did your teammate do
wrong? What is the correct command they should have used instead?

**What went wrong:**
```
-G without -a REPLACES the entire secondary group list instead of
adding to it. So bethel's previous secondary groups (docker,
developers) were wiped out and replaced with only audit-readonly.
```
**Correct command:**
```
usermod -aG audit-readonly bethel
```

---

## Question 7 — sudo access for the DBA team
Create a group called `dba_admins`. Add `selam_dba` to it. Configure
sudoers so that members of `dba_admins` can run any command with sudo
WITHOUT being prompted for a password. Use the safe method for editing
sudoers files.

**Commands:**
```
groupadd dba_admins
usermod -aG dba_admins selam_dba

visudo -f /etc/sudoers.d/dba_admins
```

**Content of the sudoers file created:**
```
%dba_admins ALL=(ALL) NOPASSWD: ALL
```

Note: ALL must stay uppercase, and (ALL) sits between the host spec
and command spec — it does not get glued onto the end. NOPASSWD: must
be spelled out explicitly to skip the password prompt; without it,
sudo still asks for the user's own password by default.

**Why must you use visudo -f instead of opening the file directly
in a text editor?**
```
Because if it has a syntax error, visudo checks it before saving and
refuses to write a broken file to disk. A broken sudoers file edited
directly with a normal editor could lock everyone out of sudo,
including root's ability to fix it through sudo itself.
```

---

## Question 8 — Investigation
You SSH into a server and need to answer these questions using only
`/etc/passwd`, `/etc/group`, and `/etc/shadow` — without running `id`
or `groups`.

a) List all users whose primary GID is 1500 (the backend group).
**Command:**
```
awk -F: '$4 == 1500 {print $1}' /etc/passwd
```
Primary group membership lives in /etc/passwd field 4 (the GID
number). awk lets me match that field exactly
and print just the username (field 1).

b) List all members of the `backend` group from the group file
(secondary members only).
**Command:**
```
grep backend /etc/group | cut -d: -f4
```
The group file format is groupname:x:GID:member1,member2,...
Field 4 (after cutting on colons) is the comma-separated secondary
member list. This is different from part (a) — primary membership
is in passwd, secondary membership is in group. Two different files
for two different relationships to the same group.

c) Find any user account in `/etc/shadow` whose password field starts
with `!` or `*` (meaning the account is locked). What does a locked
password mean for that account?
**Command:**
```
grep -E '^[^:]+:[!*]' /etc/shadow
```
**Explanation:**
```
A locked password field has been deliberately overwritten with a
value that can never match any real typed password hash. This means
password-based login is impossible for that account even if someone
knows or guesses a password. This is what passwd -l does, and it's
commonly used for service accounts that should never log in
interactively, or to temporarily disable a compromised account
without deleting it entirely.
```

---

## Self-Assessment

**What I got right from memory:**
```
Group creation, user creation logic, -aG vs -G distinction, the
reasoning behind visudo, and the overall structure of password aging
with chage.
```

**What I had to look up / get corrected:**
```
- Always remembering -m when creating users with -d
- chage -E needs an actual date, not relative shorthand
- Exact sudoers line syntax (ALL placement, NOPASSWD: spelling)
- Difference between primary group (passwd) vs secondary group (group)
  when answering investigation-style questions
- Using awk to match an exact field value in passwd
- Locked account detection via the shadow password field
```




