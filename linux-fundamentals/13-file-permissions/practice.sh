#!/bin/bash
# Topic: File Permissions

# View permissions on files
ls -l /etc/passwd
ls -l /etc/shadow
ls -l /usr/bin/passwd

# View permissions on a directory
ls -ld /home
ls -ld /tmp
ls -ld /root

# Create test files and observe default permissions
mkdir -p /tmp/perm_practice
cd /tmp/perm_practice
touch myfile.txt
mkdir mydir

# View what we created
ls -la

# What are the default permissions on a new file?
stat myfile.txt

# What about a new directory?
stat mydir

# Look at various system files and understand their permissions
ls -l /etc/hosts      # world-readable config
ls -l /etc/shadow     # very restricted — sensitive
ls -l /usr/bin/ls     # executable program
ls -l /tmp            # sticky bit example

# Clean up
cd ~
rm -rf /tmp/perm_practice
echo "done"
