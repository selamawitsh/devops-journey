#!/bin/bash
# Topic: Filter Commands

# less — browse a file (q to quit)
# less /etc/passwd

# grep — find lines containing "root" in passwd file
grep 'root' /etc/passwd

# grep — case insensitive search
grep -i 'root' /etc/passwd

# grep — show line numbers
grep -n 'bash' /etc/passwd

# grep — lines that do NOT contain a pattern
grep -v 'nologin' /etc/passwd

# grep — lines starting with a pattern (anchor to start)
grep '^root' /etc/passwd

# wc — count everything (lines, words, characters)
wc /etc/passwd

# wc — count lines only
wc -l /etc/passwd

# head — first 5 lines
head -5 /etc/passwd

# tail — last 5 lines
tail -5 /etc/passwd

# tail -f — follow a log file live (Ctrl+C to stop)
# tail -f /var/log/syslog

# sort — alphabetical sort
sort /etc/passwd | head -5

# sort — reverse sort
sort -r /etc/passwd | head -5

# sort — numeric sort on second field
# sort -n -k 2 filename
