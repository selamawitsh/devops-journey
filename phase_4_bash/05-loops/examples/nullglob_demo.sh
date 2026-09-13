#!/bin/bash

echo "Without nullglob, in an empty directory:"
for file in /tmp/nonexistent_dir_xyz/*.log; do
    echo "Matched: $file"
done

shopt -s nullglob
echo "With nullglob set:"
for file in /tmp/nonexistent_dir_xyz/*.log; do
    echo "Matched: $file"
done
echo "Loop finished cleanly, zero matches"
