#!/bin/bash

servers=("web01" "web02" "web03" "web04" "web05")

for server in "${servers[@]}"; do
    if [[ "$server" == "web03" ]]; then
        echo "Skipping $server (maintenance mode)"
        continue
    fi
    if [[ "$server" == "web05" ]]; then
        echo "Critical error reached, stopping rollout"
        break
    fi
    echo "Deploying to $server"
done
