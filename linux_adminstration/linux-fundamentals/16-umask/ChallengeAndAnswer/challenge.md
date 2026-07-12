# Real-World DevOps Challenge — umask

## Scenario
You are configuring a shared server for a development team. Files created
by team members should be accessible to the group but not to others.
You also need to configure a service that creates sensitive log files.

---

## Question 1
What is your current umask? What permissions will a new file get with
this umask? Calculate it manually then verify by creating a file.

**Current umask:**
```
```
**My manual calculation for files:**
```
666 - ___ = ___
```
**Verification:**
```
```

---

## Question 2
The development team needs files to be group-readable and group-writable
by default, but not accessible to others. What umask achieves this?
Verify by creating a file after setting it.

**umask value:**
```
```
**Commands:**
```
```
**Resulting file permissions:**
```
```

---

## Question 3
A security requirement says: files created by the `appservice` user
must not be readable by anyone except the owner. What umask should
be in the service startup script?

**umask:**
```
```
**Resulting permissions:**
```
```

---

## Question 4
How do you make a umask setting permanent for a user?
Write the exact command and which file it goes into.

**Command:**
```
```
**File:**
```
```

---

## Question 5
Calculate what permissions these umask values produce for both
files and directories. Do it without running anything first.

```
umask 022 → files: ___  dirs: ___
umask 027 → files: ___  dirs: ___
umask 077 → files: ___  dirs: ___
umask 002 → files: ___  dirs: ___
```
Then verify each with actual commands.
