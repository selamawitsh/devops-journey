# Real-World DevOps Challenge — Filter Commands

## Scenario
The application logs are filling up and the team needs answers fast.
You only have the command line. No GUI, no log viewer tool.

---

## Question 1
Find all lines containing "error" (case insensitive) in `/var/log/syslog`.
How many error lines are there?

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

## Question 2
Show only the last 20 lines of `/var/log/syslog`.
Then watch the file live as new lines are added (hint: tail has a flag for this).

**Show last 20:**
```
```
**Watch live:**
```
```

---

## Question 3
How many user accounts are in `/etc/passwd`?
(Each line is one user account.)

**Command:**
```
```
**Answer:**
```
```

---

## Question 4
List all users in `/etc/passwd` who use `/bin/bash` as their shell.
Show only their usernames (hint: grep, then think about what you see).

**Command:**
```
```
**Output:**
```
```

---

## Question 5
You have a log file with thousands of lines. You want to see the
first 3 lines and the last 3 lines without opening the whole file.
Show both with separate commands.

**First 3 lines:**
```
```
**Last 3 lines:**
```
```

---

## Bonus — real DevOps scenario
A service is writing logs to `/var/log/syslog`. You want to watch
only the lines that contain the word "FAILED" as they appear live.
How would you combine tail and grep to do this?

**Command:**
```
```
