#!/bin/bash
# Topic: chmod

mkdir -p /tmp/chmod_practice
cd /tmp/chmod_practice

# Create test files
touch script.sh
touch config.conf
touch secret.key
mkdir mydir

echo "Initial permissions:"
ls -la

# Add execute to a script (symbolic)
chmod u+x script.sh
ls -l script.sh

# Remove write from group and other
chmod go-w config.conf
ls -l config.conf

# Set exact permissions with octal
chmod 600 secret.key
ls -l secret.key

# Standard script permissions
chmod 755 script.sh
ls -l script.sh

# Standard config file permissions
chmod 644 config.conf
ls -l config.conf

# Private directory
chmod 700 mydir
ls -ld mydir

# Verify by decoding each
echo ""
echo "Final permissions:"
ls -la

# SSH key example (common mistake — wrong permissions)
touch fake_ssh_key
chmod 777 fake_ssh_key
echo "Wrong SSH key permissions:"
ls -l fake_ssh_key
chmod 600 fake_ssh_key
echo "Correct SSH key permissions:"
ls -l fake_ssh_key

# Clean up
cd ~
rm -rf /tmp/chmod_practice
echo "done"
