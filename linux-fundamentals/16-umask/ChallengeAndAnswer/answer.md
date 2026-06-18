# Real-World DevOps Challenge — umask Solutions

## Question 1
**Current umask:**
umask
# Output (example): 0022

**My manual calculation for files:**
666 - 022 = 644
# Result: rw-r--r--

**Verification:**
touch testfile
ls -l testfile
# Output: -rw-r--r-- 1 user group 0 Jun 18 10:00 testfile

---

## Question 2
**umask value:**
002

**Commands:**
umask 002
touch teamfile
ls -l teamfile

**Resulting file permissions:**
-rw-rw-r-- 1 user group ... teamfile
# 666 - 002 = 664 (rw-rw-r--)

---

## Question 3
**umask:**
077

**Resulting permissions:**
Files: 600 (rw-------) — 666 - 077 = 600
Dirs:  700 (rwx------) — 777 - 077 = 700

---

## Question 4
**Command:**
echo "umask 002" >> ~/.bashrc
# or for all users: echo "umask 002" >> /etc/profile

**File:**
~/.bashrc (user-specific) or /etc/profile (system-wide)

---

## Question 5
**Manual calculations:**
umask 022 → files: rw-r--r-- (644)  dirs: rwxr-xr-x (755)
umask 027 → files: rw-r----- (640)  dirs: rwxr-x--- (750)
umask 077 → files: rw------- (600)  dirs: rwx------ (700)
umask 002 → files: rw-rw-r-- (664)  dirs: rwxrwxr-x (775)

**Verification:**
umask 022
touch file022; mkdir dir022
ls -ld file022 dir022
# file022: -rw-r--r--  dir022: drwxr-xr-x

umask 027
touch file027; mkdir dir027
ls -ld file027 dir027
# file027: -rw-r-----  dir027: drwxr-x---

umask 077
touch file077; mkdir dir077
ls -ld file077 dir077
# file077: -rw-------  dir077: drwx------

umask 002
touch file002; mkdir dir002
ls -ld file002 dir002
# file002: -rw-rw-r--  dir002: drwxrwxr-x