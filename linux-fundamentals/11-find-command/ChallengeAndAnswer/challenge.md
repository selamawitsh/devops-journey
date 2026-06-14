# Real-World DevOps Challenge — find Command

## Scenario
The server disk is nearly full. You need to investigate and clean up.
You also need to run a security check on file permissions.

---

## Question 1
Find all files in `/var` that are larger than 50MB.
List them with their sizes.

**Command:**
```
```
**Output:**
```
```

---

## Question 2
Find all `.log` files in `/var/log` that have not been modified
in more than 30 days. These are candidates for archiving.

**Command:**
```
```

---

## Question 3
Find all files in `/etc` that are owned by root and have
world-writable permissions (this would be a security problem).

**Command:**
```
```
**Output (should hopefully be empty):**
```
```

---

## Question 4
Find all symbolic links under `/usr/bin`.
How many are there?

**Command to find them:**
```
```
**Command to count them:**
```
```
**Count:**
```
```

---

## Question 5
Find all files in `/tmp` older than 7 days.
Write the command that would delete them (don't run it yet — just write it).

**Find command:**
```
```
**Delete command:**
```
```
**Why you should be careful before running the delete:**
```
```

---

## Question 6
Find all files on the entire system that have the setuid bit set.
Why is this important from a security perspective?

**Command:**
```
```
**Why setuid files matter for security:**
```
```
