#!/bin/bash

log_file="script_run.log"

echo "$(date): script started" >> "$log_file"

ls /home/selamawit > "$log_file.tmp" 2>> "$log_file"
if [[ $? -eq 0 ]]; then
    echo "$(date): home directory listed successfully" >> "$log_file"
else
    echo "$(date): failed to list home directory" >> "$log_file"
fi

rm -f "$log_file.tmp"
echo "$(date): script finished" >> "$log_file"

cat "$log_file"
