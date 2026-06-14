#!/bin/bash
# Topic: man Pages and Help

# Quick help for ls
ls --help | head -20

# One-line description of a command
whatis ls
whatis grep
whatis find

# Search for commands related to a topic
man -k "disk usage" 2>/dev/null | head -10
apropos "network" 2>/dev/null | head -10

# man pages open in less — practice navigating
# man ls       (press q to quit)
# man grep
# man find

# Section-specific man pages
# man 5 passwd    (format of passwd FILE, not the command)
# man 1 passwd    (the passwd command itself)

# Find which section a command is in
man -f passwd 2>/dev/null
man -f crontab 2>/dev/null
