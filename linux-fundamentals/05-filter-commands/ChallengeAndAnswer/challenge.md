# Real-World DevOps Challenge — Filter Commands

## Scenario
The application logs are filling up and the team needs answers fast.
You only have the command line. No GUI, no log viewer tool.

---

## Question 1

Find all lines containing "error" (case insensitive) in `/var/log/syslog`.
How many error lines are there?

### Command to find them:

```bash
grep -i 'error' /var/log/syslog
```

### Command to count them:

```bash
grep -i 'error' /var/log/syslog | wc -l
```

### Explanation

- `grep` searches text.
- `-i` makes the search case-insensitive.
- `wc -l` counts the matching lines.

---

## Question 2

Show only the last 20 lines of `/var/log/syslog`.
Then watch the file live as new lines are added.

### Show last 20:

```bash
tail -20 /var/log/syslog
```

### Watch live:

```bash
tail -f /var/log/syslog
```

### Explanation

- `tail -20` shows the last 20 lines.
- `tail -f` follows the file and displays new lines as they are written.

---

## Question 3

How many user accounts are in `/etc/passwd`?
(Each line is one user account.)

### Command:

```bash
wc -l /etc/passwd
```

### Answer:

```text
52
```

### Explanation

Each line in `/etc/passwd` represents one user account.
`wc -l` counts the number of lines.

---

## Question 4

List all users in `/etc/passwd` who use `/bin/bash` as their shell.
Show only their usernames.

### Command:

```bash
grep '/bin/bash' /etc/passwd | cut -d: -f1
```

### Example Output:

```text
root
selamawit
```

### Explanation

- `grep '/bin/bash'` finds users whose shell is `/bin/bash`.
- `cut -d: -f1` extracts only the username field.

---

## Question 5

You have a log file with thousands of lines.
You want to see the first 3 lines and the last 3 lines without opening the whole file.

### First 3 lines:

```bash
head -3 filename
```

### Last 3 lines:

```bash
tail -3 filename
```

### Explanation

- `head -3` displays the first 3 lines.
- `tail -3` displays the last 3 lines.

---

## Bonus — Real DevOps Scenario

A service is writing logs to `/var/log/syslog`.
You want to watch only the lines that contain the word "FAILED" as they appear live.

### Command:

```bash
tail -f /var/log/syslog | grep 'FAILED'
```

### Case-insensitive version:

```bash
tail -f /var/log/syslog | grep -i 'FAILED'
```

### Explanation

- `tail -f` continuously follows the log file.
- `grep` filters only lines containing the word `FAILED`.
