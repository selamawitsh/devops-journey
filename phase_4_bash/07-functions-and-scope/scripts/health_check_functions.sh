#!/bin/bash

check_disk_space() {
    local usage=$1
    if [[ $usage -ge 90 ]]; then
        echo "CRITICAL: disk at ${usage}%"
        return 1
    else
        echo "OK: disk at ${usage}%"
        return 0
    fi
}

check_memory() {
    local usage=$1
    if [[ $usage -ge 85 ]]; then
        echo "WARNING: memory at ${usage}%"
        return 1
    else
        echo "OK: memory at ${usage}%"
        return 0
    fi
}

disk_message=$(check_disk_space 95)
disk_status=$?

memory_message=$(check_memory 60)
memory_status=$?

echo "Disk: $disk_message (exit: $disk_status)"
echo "Memory: $memory_message (exit: $memory_status)"
