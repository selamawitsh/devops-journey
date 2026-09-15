#!/bin/bash
set -euo pipefail

TEMP_FILE="/tmp/safe_script_practice_$$"

cleanup() {
    echo "Cleaning up temp file: $TEMP_FILE"
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

echo "Creating temp file"
touch "$TEMP_FILE"

echo "Doing work..."
echo "sample data" > "$TEMP_FILE"
cat "$TEMP_FILE"

echo "Script finished successfully"
