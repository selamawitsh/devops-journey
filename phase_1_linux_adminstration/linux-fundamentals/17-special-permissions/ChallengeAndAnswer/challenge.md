# Real-World DevOps Challenge — Special Permissions

## Scenario
You are setting up a shared workspace for your development team and
running a security audit on a production server.

---

## Question 1
Create a shared directory `/tmp/teamwork` where:
- All team members can read, write, and enter the directory
- Files created inside automatically belong to the `developers` group
- Only the creator of a file can delete it

What permissions and special bits achieve all three requirements?

**Commands:**
```
```
**Resulting permissions:**
```
```
**Explanation of each bit you set:**
```
```

---

## Question 2
Run a security audit: find all setuid files in `/usr/bin`.
List them. Why might an unexpected setuid file be a security concern?

**Command:**
```
```
**Output:**
```
```
**Why unexpected setuid files are dangerous:**
```
```

---

## Question 3
Look at `/usr/bin/passwd` permissions. Explain step by step how a
regular user can change their own password even though `/etc/shadow`
is only writable by root.

**Permissions of /usr/bin/passwd:**
```
```
**My step-by-step explanation:**
```
```

---

## Question 4
What is the difference between `s` (lowercase) and `S` (uppercase)
when you see them in permission strings?

**My explanation:**
```
```
**Example of each:**
```
```

---

## Question 5
Set setgid on a test directory using BOTH symbolic and octal methods.
Verify the result looks correct.

**Symbolic:**
```
```
**Octal:**
```
```
**Verification:**
```
```
