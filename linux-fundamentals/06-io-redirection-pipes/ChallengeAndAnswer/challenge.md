# Real-World DevOps Challenge — I/O Redirection and Pipes

## Scenario
You are building a system health report script. Everything must go to
files or pipelines — nothing should be left half-done on screen without
being captured or processed.

---

## Question 1

Save a full listing of `/etc` to a file called `/tmp/etc_report.txt`.
Then count how many files are in that listing.

### Commands

```bash
ls /etc > /tmp/etc_report.txt
wc -l /tmp/etc_report.txt
```

### Explanation

- `>` redirects output to a file.
- `wc -l` counts the number of lines in the file.

---

## Question 2

Run a command that will definitely produce errors (like `ls /fakepath`).
Capture the error message to a file. Verify the file contains the error.

### Commands

```bash
ls /fakepath 2> error.txt
cat error.txt
```

### Explanation

- `2>` redirects standard error (stderr) to a file.
- `cat error.txt` verifies the error was captured.

---

## Question 3

You want to see the 5 processes using the most memory.
Build a pipeline using `ps aux`, `sort`, and `head`.

### Command

```bash
ps aux | sort -rk 4 | head -5
```

### Explanation

- `ps aux` lists running processes.
- Column 4 is `%MEM`.
- `sort -rk 4` sorts by memory usage in reverse order.
- `head -5` shows the top 5 entries.

---

## Question 4

You want to watch logs AND save new entries to a file at the same time.
Which command lets you do both? Write the command for `/var/log/syslog`.

### Command

```bash
tail -f /var/log/syslog | tee syslog_live.log
```

### Explanation

- `tail -f` follows the log file live.
- `tee` displays output on the screen and writes it to a file simultaneously.

---

## Question 5

Count how many lines in `/var/log/syslog` contain the word "kernel".
Build this as a pipeline — no intermediate files.

### Command

```bash
grep 'kernel' /var/log/syslog | wc -l
```

### Count

```text
72549
```

### Explanation

- `grep` finds lines containing the word `kernel`.
- `wc -l` counts the matching lines.

---

## Question 6

What does `2>/dev/null` do and why would a DevOps engineer use it?
Give a real example where this is useful.

### Explanation

```text
2>/dev/null redirects standard error (stderr) to /dev/null.
Any error messages are discarded and do not appear on the screen.
```

### Example

```bash
find / -name "config.yaml" 2>/dev/null
```

### Why this is useful

When searching the entire system, many directories may produce
"Permission denied" errors. Redirecting stderr to `/dev/null`
suppresses those messages and displays only useful results.

---

## Bonus Knowledge

### Difference between `>` and `>>`

Overwrite a file:

```bash
ls > report.txt
```

Append to a file:

```bash
ls >> report.txt
```

- `>` replaces the contents of the file.
- `>>` adds new content to the end of the file.