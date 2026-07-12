#!/bin/bash
# Topic: Special Permissions

# See setuid in the wild — passwd command
ls -l /usr/bin/passwd
echo "Notice the 's' in owner execute position"

# See sticky bit in the wild — /tmp
ls -ld /tmp
echo "Notice the 't' in other execute position"

# Find all setuid files on the system (security audit)
echo "Setuid files:"
find /usr/bin -perm /4000 -type f 2>/dev/null | head -10

# Find all setgid files
echo "Setgid files:"
find /usr/bin -perm /2000 -type f 2>/dev/null | head -5

# Practice — create a shared directory with setgid
mkdir -p /tmp/shared_team
chmod 2770 /tmp/shared_team
ls -ld /tmp/shared_team
echo "setgid directory — files created here inherit the group"

# Practice — set sticky bit
mkdir -p /tmp/sticky_test
chmod 1777 /tmp/sticky_test
ls -ld /tmp/sticky_test
echo "sticky bit — only file owner can delete their files"

# Show octal with 4-digit representation
echo ""
echo "4-digit octal examples:"
echo "chmod 4755 = setuid + 755"
echo "chmod 2770 = setgid + 770"
echo "chmod 1777 = sticky + 777"
echo "chmod 0755 = remove special + 755"

# Clean up
rm -rf /tmp/shared_team /tmp/sticky_test
echo "done"
