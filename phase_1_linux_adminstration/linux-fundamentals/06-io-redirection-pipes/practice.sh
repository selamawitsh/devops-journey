#!/bin/bash
# Topic: I/O Redirection and Pipes

# Redirect stdout to a file (overwrites each time)
date > /tmp/datefile.txt
cat /tmp/datefile.txt

# Append to a file
hostname >> /tmp/datefile.txt
cat /tmp/datefile.txt

# Redirect stderr to a file
ls /fakedir 2> /tmp/errors.txt
cat /tmp/errors.txt

# Redirect both stdout and stderr to same file
ls /etc /fakedir &> /tmp/all_output.txt
cat /tmp/all_output.txt

# Discard error messages (send to /dev/null)
ls /etc /fakedir 2> /dev/null

# Pipe — count users in /etc/passwd
cat /etc/passwd | wc -l

# Pipe — find bash users and count them
grep 'bash' /etc/passwd | wc -l

# Pipe — sort processes by memory usage (top 5)
ps aux | sort -rn -k 4 | head -5

# Pipe — find errors in logs and count them
grep -i 'error' /var/log/syslog 2>/dev/null | wc -l

# tee — save to file AND display on screen
ls /etc | tee /tmp/etc_list.txt | head -5

# Read from file instead of keyboard
sort < /etc/passwd | head -5

# Clean up temp files
rm -f /tmp/datefile.txt /tmp/errors.txt /tmp/all_output.txt /tmp/etc_list.txt
