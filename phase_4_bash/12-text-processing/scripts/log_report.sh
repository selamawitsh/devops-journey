#!/bin/bash
set -euo pipefail

LOG_FILE="logs/app.log"

echo "=== Log Report for $LOG_FILE ==="

total_lines=$(wc -l < "$LOG_FILE")
echo "Total lines: $total_lines"

error_count=$(grep -c "CRITICAL" "$LOG_FILE" || true)
echo "CRITICAL entries: $error_count"

echo ""
echo "CRITICAL entries with timestamps:"
awk '/CRITICAL/ {print $1, $2}' "$LOG_FILE"

echo ""
echo "Log level breakdown:"
awk '{print $3}' "$LOG_FILE" | sort | uniq -c
