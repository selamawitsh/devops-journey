#!/bin/bash

servers=("web01" "web server two" "web03")

echo "Quoted \"\${servers[@]}\" - each element preserved:"
for s in "${servers[@]}"; do
    echo "  [$s]"
done

echo "Quoted \"\${servers[*]}\" - joined into one string:"
for s in "${servers[*]}"; do
    echo "  [$s]"
done
