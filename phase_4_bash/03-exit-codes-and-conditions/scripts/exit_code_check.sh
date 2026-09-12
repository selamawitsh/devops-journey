#!/bin/bash

ls /home/selamawit > /dev/null
echo "Checking home directory, exit code: $?"

ls /this/does/not/exist > /dev/null 2>&1
echo "Checking fake path, exit code: $?"

if [[ -n "$USER" ]]; then
    echo "USER variable is set to: $USER"
fi
