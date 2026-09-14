#!/bin/bash

echo "Unquoted \$@:"
for arg in $@; do
    echo "  [$arg]"
done

echo "Quoted \"\$@\" (correct for forwarding args):"
for arg in "$@"; do
    echo "  [$arg]"
done

echo "Quoted \"\$*\" (joins into one string):"
for arg in "$*"; do
    echo "  [$arg]"
done
