#!/bin/bash
# Topic: Links and Inodes

mkdir -p /tmp/link_practice
cd /tmp/link_practice

# Create a test file
echo "This is the original file" > original.txt

# Show its inode number
ls -li original.txt

# Create a hard link
ln original.txt hardlink.txt

# Both have the same inode number and link count is now 2
ls -li original.txt hardlink.txt

# Verify they share the same content
cat hardlink.txt

# Delete original — data still accessible via hardlink
rm original.txt
cat hardlink.txt
ls -li hardlink.txt

# Create a new file for symlink practice
echo "Target file content" > target.txt

# Create a symbolic link
ln -s target.txt symlink.txt

# ls -l shows symlink with arrow
ls -l symlink.txt

# Access through symlink
cat symlink.txt

# Delete the target — symlink breaks
rm target.txt
ls -l symlink.txt
# cat symlink.txt   # this will fail — broken link

# Real-world example: symlink to config
ln -s /etc/hosts myhosts_link
ls -l myhosts_link
cat myhosts_link

# Clean up
cd ~
rm -rf /tmp/link_practice
echo "done"
