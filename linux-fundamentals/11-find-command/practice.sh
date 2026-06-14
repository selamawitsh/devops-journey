#!/bin/bash
# Topic: find Command

# Find all .conf files in /etc
find /etc -name '*.conf' -type f | head -10

# Find all directories in /var owned by root
find /var -type d -user root | head -10

# Find files larger than 1MB in /var
find /var -size +1M -type f 2>/dev/null | head -10

# Find files modified in last 1 day
find /var/log -mtime -1 -type f 2>/dev/null | head -10

# Find all symbolic links in /usr/bin
find /usr/bin -type l | head -10

# Find and show details (like ls -li)
find /etc -name 'hosts' -type f -ls

# Suppress permission errors
find / -name 'passwd' -type f 2>/dev/null

# Find files with setuid permission (security check)
find /usr/bin -perm /4000 -type f 2>/dev/null

# Find empty files
find /tmp -size 0 -type f 2>/dev/null | head -5

# Find and execute command on results
find /tmp -name '*.tmp' -type f -exec echo "Found: {}" \; 2>/dev/null
