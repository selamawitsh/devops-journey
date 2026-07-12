#!/bin/bash
# Topic: umask

# Check current umask
umask

# Check in symbolic form
umask -S

# See the effect — create a file and directory with current umask
mkdir -p /tmp/umask_practice
cd /tmp/umask_practice

touch standard_file.txt
mkdir standard_dir
echo "With default umask:"
ls -la

# Change umask to 027 — more restrictive
umask 027
touch restricted_file.txt
mkdir restricted_dir
echo "With umask 027:"
ls -la

# Change umask to 077 — private only
umask 077
touch private_file.txt
mkdir private_dir
echo "With umask 077:"
ls -la

# Reset to standard
umask 022

# Show the math:
echo ""
echo "umask math:"
echo "default file max:  666"
echo "umask 022:       - 022"
echo "result:          = 644 (rw-r--r--)"
echo ""
echo "default dir max:   777"
echo "umask 022:       - 022"
echo "result:          = 755 (rwxr-xr-x)"

# Clean up
cd ~
rm -rf /tmp/umask_practice
echo "done"
