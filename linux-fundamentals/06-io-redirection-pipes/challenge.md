# Real-World DevOps Challenge — I/O Redirection and Pipes

## Scenario
You are building a system health report script. Everything must go to
files or pipelines — nothing should be left half-done on screen without
being captured or processed.

---

## Question 1
Save a full listing of `/etc` to a file called `/tmp/etc_report.txt`.
Then count how many files are in that listing.

**Commands:**
```
```

---

## Question 2
Run a command that will definitely produce errors (like `ls /fakepath`).
Capture the error message to a file. Verify the file contains the error.

**Commands:**
```
```

---

## Question 3
You want to see the 5 processes using the most memory.
Build a pipeline using `ps aux`, `sort`, and `head`.

**Command:**
```
```
**Output:**
```
```

---

## Question 4
You want to watch logs AND save new entries to a file at the same time.
Which command lets you do both? Write the command for `/var/log/syslog`.

**Command:**
```
```

---

## Question 5
Count how many lines in `/var/log/syslog` contain the word "kernel".
Build this as a pipeline — no intermediate files.

**Command:**
```
```
**Count:**
```
```

---

## Question 6
What does `2>/dev/null` do and why would a DevOps engineer use it?
Give a real example where this is useful.

**Explanation:**
```
```
**Example:**
```
```
