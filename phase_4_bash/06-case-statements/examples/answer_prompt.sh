#!/bin/bash

read -p "Continue? (y/n): " answer

case "$answer" in
    y|Y|yes|Yes)
        echo "Proceeding..."
        ;;
    n|N|no|No)
        echo "Cancelled."
        ;;
    *)
        echo "Please answer y or n."
        ;;
esac
