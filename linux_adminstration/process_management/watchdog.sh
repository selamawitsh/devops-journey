#!/bin/bash

# ==========================================================================
# watchdog.sh
# Phase 1 - Linux Mastery - Process Management project
#
# What this does:
#   Scans running processes, finds any exceeding a CPU% threshold,
#   kills them, and logs the action with a timestamp.
#
# Why this matters in real ops:
#   A runaway process (bad code, infinite loop, memory leak) can take
#   down a server. A watchdog is a basic, always-on safety net.
# ==========================================================================

# --- Configuration (variables) ---
# No spaces around "=" -- bash will error if you add them.
CPU_THRESHOLD=80          # percent CPU that counts as "runaway"
LOG_FILE="$HOME/watchdog.log"

# --- Log helper function ---
# A function is just a named block of commands you can call by name,
# instead of retyping the same lines every time.
log_action() {
    # $1 refers to the first argument passed to this function.
    # date +"..." formats the current time for the log line.
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log_action "Watchdog check started. Threshold: ${CPU_THRESHOLD}%"

# --- Gather process data ---
# ps -eo pid,comm,%cpu   -> print PID, command name, CPU% only (clean columns)
# --sort=-%cpu            -> sort by CPU%, highest first
# tail -n +2              -> skip the header line ps prints
ps -eo pid,comm,%cpu --sort=-%cpu | tail -n +2 | while read -r pid comm cpu; do

    # CPU comes back as a decimal like "12.3". Bash can't compare decimals
    # natively (it only does integer math), so we use awk to do the
    # comparison and print 1 (true) or 0 (false).
    exceeds=$(awk -v cpu="$cpu" -v limit="$CPU_THRESHOLD" 'BEGIN { print (cpu > limit) ? 1 : 0 }')

    if [ "$exceeds" -eq 1 ]; then
        log_action "RUNAWAY DETECTED: PID $pid ($comm) using ${cpu}% CPU. Killing it."

        # Try a polite SIGTERM first.
        kill "$pid" 2>/dev/null

        # Give it 2 seconds to exit cleanly, then check if it's still alive.
        sleep 2
        if ps -p "$pid" > /dev/null 2>&1; then
            log_action "PID $pid did not respond to SIGTERM. Sending SIGKILL."
            kill -9 "$pid" 2>/dev/null
        fi
    fi
done

log_action "Watchdog check finished."
