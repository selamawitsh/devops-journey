#!/bin/bash
# Topic: Wildcards and Brace Expansion

mkdir -p /tmp/wildcard_practice
cd /tmp/wildcard_practice

# Create test files using brace expansion
touch app{1..5}.log
touch config{1..3}.conf
touch README.txt
touch deploy.sh
touch test_app.py

ls

# Wildcard: all .log files
ls *.log

# Wildcard: all .conf files
ls *.conf

# Wildcard: files starting with 'app'
ls app*

# Wildcard: exactly one char after 'app'
ls app?.log

# Wildcard: files starting with letter a-d
ls [a-d]*

# Wildcard: files NOT starting with 'app'
ls [!a]*

# Brace expansion to create directories
mkdir {dev,staging,production}
ls -d */

# Brace expansion with range
echo file{1..5}.txt

# Copy all log files to dev directory
cp *.log dev/
ls dev/

# Remove all .log files
rm *.log
ls

# Clean up
cd ~
rm -rf /tmp/wildcard_practice
echo "done"
