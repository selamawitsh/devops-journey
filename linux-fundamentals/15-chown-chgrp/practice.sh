#!/bin/bash
# Topic: chown and chgrp
# Note: most of these require sudo on a real system

mkdir -p /tmp/ownership_practice
cd /tmp/ownership_practice

touch app.conf
touch deploy.sh
mkdir appdir

# Check current ownership
ls -la

# Who am I?
id

# Check ownership with stat
stat app.conf

# Change group (regular users can do this if they belong to the group)
# chown :developers app.conf

# With sudo — change owner and group
# sudo chown www-data:www-data app.conf
# sudo chown -R deploy:deploy appdir/

# After change, verify
# ls -la app.conf

# Practical: check who owns important system files
ls -l /etc/passwd
ls -l /etc/shadow
ls -l /var/log/syslog 2>/dev/null || ls -l /var/log/messages 2>/dev/null
ls -l /usr/bin/passwd

# Clean up
cd ~
rm -rf /tmp/ownership_practice
echo "done — note: chown as non-root is restricted, practice with sudo"
