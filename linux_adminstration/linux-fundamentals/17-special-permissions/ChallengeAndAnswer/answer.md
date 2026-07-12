# Real-World DevOps Challenge — Special Permissions Solutions

## Question 1
**Commands:**
mkdir /tmp/teamwork
chown :developers /tmp/teamwork
chmod 3770 /tmp/teamwork
# or using symbolic:
# chmod g+rwxs,o-rwx,+t /tmp/teamwork

**Resulting permissions:**
drwxrws--T 2 user developers ... /tmp/teamwork
# or with sticky bit: drwxrws--T

**Explanation of each bit you set:**
3 (setgid + sticky) or 3770:
- setgid (2): New files inherit the 'developers' group
- sticky bit (1): Only file owners can delete their own files
- 770: Owner and group have full rwx, others have nothing

---

## Question 2
**Command:**
find /usr/bin -perm -4000 -ls 2>/dev/null

**Output (example):**
-rwsr-xr-x 1 root root /usr/bin/passwd
-rwsr-xr-x 1 root root /usr/bin/sudo
-rwsr-xr-x 1 root root /usr/bin/su

**Why unexpected setuid files are dangerous:**
An unexpected setuid binary allows any user to execute a program with
the file owner's privileges (often root). Attackers can exploit this
for privilege escalation — running commands as root, accessing sensitive
files, or taking complete control of the system.

---

## Question 3
**Permissions of /usr/bin/passwd:**
-rwsr-xr-x 1 root root ... /usr/bin/passwd

**My step-by-step explanation:**
1. Regular user executes /usr/bin/passwd
2. The setuid bit (s) makes the process run with root's effective UID
3. The passwd program can now write to /etc/shadow (root-only file)
4. The program validates the user's old password
5. It writes the new password hash to /etc/shadow
6. The program exits, and the user returns to normal privileges
7. The user never directly accesses /etc/shadow — only through this
   trusted setuid binary

---

## Question 4
**My explanation:**
Lowercase 's': Execute bit IS set for that permission level.
               Setuid/setgid is ACTIVE and EXECUTABLE.
Uppercase 'S': Execute bit is NOT set for that permission level.
               Setuid/setgid is PRESENT but NOT EXECUTABLE.
               This is usually a mistake/broken configuration.

**Example of each:**
rwsr-xr-x → lowercase s: owner has setuid AND execute (correct passwd)
rwSr-xr-x → uppercase S: owner has setuid but NO execute (broken)
rwxr-sr-x → lowercase s: group has setgid AND execute (correct)
rwxr-Sr-x → uppercase S: group has setgid but NO execute (broken)

---

## Question 5
**Symbolic:**
chmod g+s testdir

**Octal:**
chmod 2755 testdir
# or for full rwx: chmod 2770 testdir

**Verification:**
ls -ld testdir
# Output: drwxr-sr-x 2 user group ... testdir