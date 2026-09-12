#!/bin/bash

name="John Smith"

echo "Testing unquoted [ ] (will fail):"
if [ $name = "John Smith" ]; then
    echo "match"
fi

echo "Testing [[ ]] (safe, no quotes needed):"
if [[ $name = "John Smith" ]]; then
    echo "match"
fi

echo "Testing quoted [ ] (safe too):"
if [ "$name" = "John Smith" ]; then
    echo "match"
fi
