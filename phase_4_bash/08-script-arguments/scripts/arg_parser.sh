#!/bin/bash

environment=""
verbose=false

while getopts "e:v" opt; do
    case "$opt" in
        e)
            environment="$OPTARG"
            ;;
        v)
            verbose=true
            ;;
        *)
            echo "Usage: $0 [-e environment] [-v]"
            exit 1
            ;;
    esac
done

if [[ -z "$environment" ]]; then
    echo "No environment specified, defaulting to development"
    environment="development"
fi

echo "Environment: $environment"
echo "Verbose: $verbose"
