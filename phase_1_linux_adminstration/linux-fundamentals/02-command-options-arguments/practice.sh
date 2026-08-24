#!/bin/bash
# Topic: Command Options and Arguments

# Short option
ls -l /home

# Long option — same result
ls --all /home

# Combining options
ls -la /home

# Human-readable file sizes
ls -lh /var/log

# Date in ISO format (short option)
date -I

# Date in ISO format (long option — same thing)
date --iso-8601

# Calendar for this year
cal -y

# List only specific file types (argument)
ls -l /etc/hosts

# Multiple arguments — lists both
ls -l /etc/hosts /etc/passwd
