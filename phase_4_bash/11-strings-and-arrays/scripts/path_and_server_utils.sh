#!/bin/bash

backup_path="/home/selamawit/backups/db_backup.tar.gz"

filename="${backup_path##*/}"
directory="${backup_path%/*}"
name_no_ext="${filename%%.*}"

echo "Full path: $backup_path"
echo "Filename: $filename"
echo "Directory: $directory"
echo "Name without extension: $name_no_ext"

echo ""

environment="${DEPLOY_ENV:-development}"
echo "Deploying to environment: $environment"

echo ""

servers=("web01" "web02" "web03")
echo "Servers to check (${#servers[@]} total):"
for i in "${!servers[@]}"; do
    echo "  [$i] ${servers[$i]}"
done
