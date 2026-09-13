#!/bin/bash

backup_dir="/tmp/practice_backup"

if [[ -d "$backup_dir" ]]; then
    echo "Backup directory already exists"
else
    echo "Backup directory missing, creating it"
    mkdir -p "$backup_dir"
fi

if [[ -f "$backup_dir" && -r "$backup_dir" ]]; then
    echo "This won't print, it's a directory not a file"
fi
