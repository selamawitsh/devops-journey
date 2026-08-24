#!/bin/bash
# Topic: Pathnames and Navigation

# Where am I?
pwd

# Go to root
cd /
pwd

# Go to /etc using absolute path
cd /etc
pwd

# List what is in /etc and give me the firrst 20 entries
ls /etc | head -20

# Go back home using absolute path
cd /home
pwd

# Go home using tilde shortcut
cd ~
pwd

# Go up one level using relative path
cd ..
pwd

# Go back to where I was
cd -
pwd

# Navigate using relative path
cd ~
mkdir -p testdir/subdir
cd testdir/subdir
pwd

# Go up two levels using ..
cd ../..
pwd

# Clean up test directory
rm -rf testdir

# Explore key system paths
ls /var/log | head -10
ls /etc | grep -i host
cat /etc/hostname
