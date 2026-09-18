# Notes — Text Processing

## Why this session matters

A server produces logs like this, constantly:

    2026-09-22 09:00:01 INFO Application started
    2026-09-22 09:03:22 ERROR Database connection failed
    2026-09-22 09:05:43 WARN High memory usage

Nobody reads thousands of lines by hand. The real skill in this session
isn't memorizing 8 separate commands — it's learning to CHAIN small tools
together, each doing one simple job:

    raw log file
        |
    find/grep   -> narrow down to the lines or files that matter
        |
    cut/awk/sed   -> pull out or transform just the piece you need
        |
    sort            -> group identical things together
        |
    uniq              -> collapse or count the groups
        |
    an actual answer

## find — locating files

    find .                    everything under the current directory, recursively
    find . -type f              regular files only
    find . -type d                directories only (includes "." itself)
    find . -name "*.log"             filename pattern match

Why "*.log" is quoted: without quotes, BASH itself would try to expand
*.log against files in your CURRENT directory before find ever runs —
possibly the wrong files, or an error if none match here. Quoting hands
the literal pattern *.log to find, which then applies it at every level
of the directory tree, not just the current one.

    find . -iname "*.log"       same as -name, but case-insensitive
                                  matches app.log, APP.LOG, App.Log alike

    find . -mtime -1               modified within the last 1 day
    find . -mtime +7                 modified MORE than 7 days ago
                                       (sign flips the direction: - = less
                                       than, + = more than — easy to get
                                       backwards)
    find . -size +0c                   size greater than 0 bytes — this
                                         means "has content," not "exists";
                                         a file created by touch (empty)
                                         fails this test

    find . -name "*.log" -exec CMD {} \;
                                          runs CMD once PER matched file.
                                          {} is replaced with the filename,
                                          \; marks where the command ends.

Visual — what -exec actually does with 3 matches:

    find finds: a.log, b.log, c.log
                  |        |       |
               exec CMD  exec CMD  exec CMD     <- 3 separate command runs
               on a.log  on b.log  on c.log

Real pattern: find . -name "*.log" -mtime +7 -exec rm {} \; is the core
of most real log-rotation and cleanup scripts.

## grep — searching file CONTENTS (not filenames)

    grep "ERROR" app.log        lines containing ERROR
    grep -i "error" app.log       case-insensitive (matches ERROR, error,
                                    Error, eRrOr, all the same)
    grep -c "ERROR" app.log         COUNT of matching lines only, not the
                                      lines themselves
    grep -n "ERROR" app.log           show LINE NUMBERS with each match —
                                        useful for jumping straight to the
                                        spot in a big log instead of
                                        scrolling manually
    grep -v "ERROR" app.log             INVERT: show lines that do NOT
                                          match
    grep -A 1 "ERROR" app.log             match plus 1 line of context
                                            AFTER it (-B for before) — an
                                            isolated error line rarely
                                            tells the full story, context
                                            does
    grep -r "ERROR" .                       RECURSIVE: search every file
                                              under a directory tree, not
                                              just one file
    grep "ERROR" *.log                        search multiple files at once
                                                by wildcard

Visual — grep is a FILTER, narrowing a stream of lines down to only the
ones that match:

    all lines in the file
    ------------------------
    INFO  ...
    ERROR ...      <-- kept
    INFO  ...
    ERROR ...      <-- kept
    WARN  ...
    ------------------------
           |
       grep "ERROR"
           |
           v
    ERROR ...
    ERROR ...
