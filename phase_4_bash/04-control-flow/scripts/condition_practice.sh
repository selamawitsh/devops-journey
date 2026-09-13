#!/bin/bash

count=$1

if [[ -z "$count" ]]; then
    echo "No argument given, defaulting to 0"
    count=0
fi

if [[ $count -gt 3 ]]; then
    echo "count is greater than 3"
elif [[ $count -eq 3 ]]; then
    echo "count is exactly 3"
else
    echo "count is 3 or less"
fi
