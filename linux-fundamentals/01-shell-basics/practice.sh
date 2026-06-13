#!/bin/bash
# Topic: Shell basics
# These are the commands I ran today and what they do

# Show the name of this machine
hostname

# Show current date and time
date

# Show my user ID and group memberships
id

# Show a calendar for this month
cal

# Show the current year calendar
cal -y

# Show date in ISO format (clean, unambiguous)
date -I

# List files in /home directory
ls /home

# Long listing of /home — shows permissions, owner, size, date
ls -l /home

# Where am I right now? (print working directory)
pwd

# Change to /etc directory
cd /etc

# Confirm I moved
pwd

# Go back to home directory
cd ~

# Confirm I am home
pwd

# List hidden files (files starting with a dot)
ls -a ~
