#!/bin/bash

echo "Demonstrating return's 0-255 wraparound bug:"
add_numbers_broken() {
    local sum=$(( $1 + $2 ))
    return $sum
}
add_numbers_broken 200 100
echo "Exit code (WRONG - wrapped): $?"

echo ""
echo "Correct approach using echo + command substitution:"
add_numbers_correct() {
    local sum=$(( $1 + $2 ))
    echo "$sum"
}
result=$(add_numbers_correct 200 100)
echo "Actual sum (CORRECT): $result"
