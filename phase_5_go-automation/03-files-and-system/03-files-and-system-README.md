# Module 03: Files and System

Phase 5, Go for DevOps automation.

## Overview

Every lesson so far has lived entirely inside the running program: hardcoded server lists, in-memory structs, printed output. Real DevOps tools read their input from files (a server list, a config file), write their output to files (a report, a log), and ask the operating system questions about itself (hostname, OS, environment variables). This module covers all three.

## Learning objectives

By the end of this module you can:

- Read a whole file at once, or line by line, and handle the errors that come with it
- Write a new file, or append to an existing one, safely
- Understand basic file permissions and why `0644` vs `0755` matters
- Create directories and list what's inside them
- Pull basic system information: hostname, OS, architecture, environment variables

## Folder structure

```text
03-files-and-system/
 |-- README.md             <- this file
 |-- 01-lesson-notes.md    <- big picture + detailed notes
 |-- 02-active-recall.md   <- short-answer drill
 |-- 03-practical-lab.md   <- hands-on labs, one per sub-project
 |-- file-reader/
 |-- file-writer/
 `-- system-info/
```

## What you'll build

| Folder | What it does |
|---|---|
| `file-reader/` | Reads a list of servers from `servers.txt` and prints them, with proper error handling |
| `file-writer/` | Writes a health-check report to a log file, both overwriting and appending |
| `system-info/` | Gathers and prints the machine's own hostname, OS, architecture, and environment variables |

These three combine directly into the shape a real tool needs: read input from a file, check it, write a report, and stamp that report with information about the machine that ran it.

## Progress checklist

- [ ] `01-lesson-notes.md` read
- [ ] `02-active-recall.md` completed, 80%+ on day 7
- [ ] `file-reader` lab built and reviewed
- [ ] `file-writer` lab built and reviewed
- [ ] `system-info` lab built and reviewed
- [ ] All three committed and pushed
