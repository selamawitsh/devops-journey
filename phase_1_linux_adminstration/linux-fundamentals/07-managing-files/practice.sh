#!/bin/bash
# Topic: Managing Files

# Create a directory
mkdir -p /tmp/devops_practice/configs /tmp/devops_practice/logs

# Create empty files
touch /tmp/devops_practice/configs/app.conf
touch /tmp/devops_practice/configs/db.conf
touch /tmp/devops_practice/logs/app.log

# List what we created
ls -la /tmp/devops_practice/
ls -la /tmp/devops_practice/configs/

# Copy a file
cp /tmp/devops_practice/configs/app.conf /tmp/devops_practice/configs/app.conf.bak

# Copy a directory recursively
cp -r /tmp/devops_practice/configs /tmp/devops_practice/configs_backup

# Rename a file
mv /tmp/devops_practice/configs/db.conf /tmp/devops_practice/configs/database.conf

# Move file to another directory
mv /tmp/devops_practice/configs/database.conf /tmp/devops_practice/

# Verify the move
ls /tmp/devops_practice/configs/
ls /tmp/devops_practice/

# Delete a single file
rm /tmp/devops_practice/database.conf

# Delete a directory and all contents
rm -r /tmp/devops_practice/configs_backup

# Clean up everything
rm -rf /tmp/devops_practice
echo "cleanup done"
