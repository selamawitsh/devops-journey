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

## sed — transforming text

    sed 's/OLD/NEW/' file        prints the TRANSFORMED result to the
                                   screen only — the file itself is
                                   UNTOUCHED by default
    sed -i 's/OLD/NEW/' file        actually modifies the file in place

Visual — sed's default behavior is "preview, don't commit":

    real file on disk:  ERROR ...
                            |
                      sed 's/ERROR/CRITICAL/'
                            |
                            v
              screen shows: CRITICAL ...    (just a preview)
                            |
              real file on disk still says: ERROR ...   (unchanged)

    only with -i:
                      sed -i 's/ERROR/CRITICAL/'
                            |
                            v
              real file on disk NOW says: CRITICAL ...   (changed for real)

This is a genuine safety feature, not a limitation: preview any
transformation on a real config file first, and only add -i once you're
confident it's doing exactly what you want. Running -i blind, unpreviewed,
on something that matters is a common real way to corrupt a production
config file.

    s/OLD/NEW/       replaces only the FIRST match on each line
    s/OLD/NEW/g        the g (global) flag replaces EVERY match on each
                         line — same first-vs-all idea as
                         ${var/old/new} vs ${var//old/new} from Session 11

## awk — processing STRUCTURED text, by column

awk automatically splits every line into fields wherever it sees
whitespace, and numbers them starting from 1:

    Selamawit   DevOps   Ethiopia
        |          |          |
       $1         $2         $3

    $0   means the WHOLE original line, untouched

Important: $1, $2 etc here mean something COMPLETELY different from $1,
$2 in a script's arguments (Session 8). Same symbols, different meaning —
always check what a symbol means in its specific context, a pattern that
keeps showing up across this whole phase.

On a real log line:

    2026-09-22   09:03:22   ERROR   Database   connection   failed
        $1           $2       $3        $4         $5          $6

    awk '{print $1}' app.log     -> every line's date
    awk '{print $3}' app.log       -> every line's log level (INFO, ERROR, WARN)

awk is a MECHANICAL column-splitter with no awareness of meaning — $4
is just "whichever word happens to be 4th," so it can be a totally
different KIND of value on lines with a different sentence structure
after the timestamp. Works best on data with a consistent format.

The real power — filtering by PATTERN, then printing a column, in one
tool:

    awk 'PATTERN { ACTION }' file

    awk '/ERROR/ {print $1, $2}' app.log
             |            |
      only touch lines   then print just
      matching ERROR      fields 1 and 2

This does grep's filtering job AND cut's column-picking job, together,
in a single command:

    all lines
        |
    /ERROR/  (pattern, like a built-in grep)
        |
    only ERROR lines survive
        |
    {print $1, $2}   (action: print just these 2 fields)
        |
    just the timestamps of the errors

## cut — simple delimiter-based field extraction

    echo "web01:running:8080" | cut -d ":" -f 1

    -d ":"   sets the DELIMITER (what character separates fields — cut
              needs this told explicitly; awk defaults to whitespace)
    -f 1       which FIELD NUMBER(S) to print — -f 1,3 for multiple

    web01 : running : 8080
      1        2        3
    cut -f 1   -> web01
    cut -f 2     -> running
    cut -f 1,3     -> web01:8080

Why cut exists alongside awk: for a simple "split on ONE character, grab
a field" job, cut is faster to write and read than a full awk command.
awk is what you reach for once you need pattern matching or more complex
logic on top.

## sort and uniq — almost always used together

uniq only removes CONSECUTIVE duplicate lines — not duplicates anywhere
in the file. If matching lines aren't already sitting next to each
other, uniq does nothing useful.

    Unsorted file:            After sort:
    banana                    apple
    apple                     apple
    banana                    banana
    apple                     banana
                               orange
    orange
        |                         |
    uniq (no effect,          uniq (works! - identical
    nothing adjacent            lines are now adjacent)
    matches)                        |
        |                           v
        v                     apple
    banana                    banana
    apple                     orange
    banana
    apple
    orange

    sort file | uniq          collapse to unique lines
    sort file | uniq -c         same, plus a COUNT of how many times each
                                  line appeared

sort | uniq -c is one of the single most common one-liners in all of
Linux — used constantly to count occurrences of anything: log levels,
HTTP status codes, IP addresses hitting a server.

## xargs — turning piped input into command ARGUMENTS

    printf "file1\nfile2\nfile3\n" | xargs echo

Think of it as: "take whatever lines came through the pipe, and feed them
as arguments to this command, all at once."

    file1
    file2      -->  xargs echo  -->  echo file1 file2 file3
    file3                              (ONE command call, all 3 filenames
                                        bundled in as arguments)

Compare to find -exec, which runs the command SEPARATELY per match:

    find . -name "*.log" | xargs echo "Processing:"
                                    ONE echo call total, every filename
                                    appended after it

    find . -name "*.log" -exec echo "Found:" {} \;
                                    ONE echo call PER matched file

For something cheap like echo the difference is invisible. For something
expensive per file (compressing, uploading, calling an API), whether the
whole batch runs as 1 process or spawns N processes is a real,
meaningful performance difference in production automation.

A real safety detail worth knowing: filenames can contain spaces or
special characters, which can confuse a plain pipe into xargs (a
filename with a space looks like TWO separate arguments). The safe
pattern for real scripts:

    find . -name "*.log" -print0 | xargs -0 ls -lh

-print0 separates filenames with a null byte instead of a newline, and
-0 tells xargs to expect that — null bytes can never appear inside a
real filename, so this is the one separator that's always unambiguous,
no matter what the filename contains.

## Tool roles, at a glance

    find    ->  locate FILES, by name/type/age/size
    grep    ->  locate LINES, by content pattern
    cut     ->  extract specific FIELDS, simple delimiter split
    awk     ->  extract/filter FIELDS, with pattern matching built in
    sed     ->  TRANSFORM text (search and replace)
    sort    ->  order lines, so identical ones become adjacent
    uniq    ->  collapse or COUNT adjacent duplicate lines
    xargs   ->  turn piped output into ARGUMENTS for another command

## The full pipeline mindset

A real one-line log analysis command, built entirely from tools in this
session:

    grep "ERROR" app.log | awk '{print $4}' | sort | uniq -c

             app.log
                |
          grep "ERROR"          keep only ERROR lines
                |
          awk '{print $4}'        pull out just field 4 from those lines
                |
              sort                  group identical values together
                |
             uniq -c                  count how many times each appears
                |
                v
         a ranked breakdown of what's actually going wrong, and how often

This chaining mindset — narrow down, extract, group, count — is exactly
what carries forward into CI/CD log analysis, monitoring dashboards, and
the health-check project later in this phase.
