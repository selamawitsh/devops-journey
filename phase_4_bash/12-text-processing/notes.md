# Notes — Text Processing

## find
find . -name "*.log"        recursive search by filename pattern (unlike ls,
                              which only looks in the current directory)
find . -type f                 regular files only
find . -type d                   directories only (includes the starting
                                   directory itself)
find . -mtime -1                   modified within the last 1 day (negative
                                     = less than)
find . -mtime +7                     modified more than 7 days ago (positive
                                       = more than) - sign flips the direction,
                                       easy to get backwards
find . -size +0c                       size greater than 0 bytes - note this
                                         means "has content," NOT "exists";
                                         an empty file created by touch fails
                                         this test even though it's a real file
find . -name "*.log" -exec CMD {} \;      runs CMD once per matched file, {}
                                            is replaced with the filename,
                                            \; marks the end of the command

Real pattern: find . -name "*.log" -mtime +7 -exec rm {} \; is the core of
most real log-rotation/cleanup scripts.

## grep
grep "PATTERN" file       lines containing PATTERN
grep -i                     case-insensitive
grep -c                       count of matching lines only, not the lines
grep -n                          show line numbers with each match
grep -v                             invert: show lines that do NOT match
grep -A N / -B N                       show N lines of context after/before
                                         each match - isolated error lines
                                         rarely tell the full story, context
                                         does

## sed
sed 's/OLD/NEW/' file         prints the transformed result to stdout ONLY -
                                the file itself is untouched by default
sed -i 's/OLD/NEW/' file          actually modifies the file in place

This default (no file changes without -i) is a safety feature: preview any
transformation on a real/production file before committing to -i. Running
-i blind without previewing is a common real way to corrupt a config file.

s/OLD/NEW/     replaces only the FIRST match per line
s/OLD/NEW/g      the g flag replaces ALL matches per line (same first-vs-all
                  logic as ${var/old/new} vs ${var//old/new} from Session 11)

## awk
awk 'PATTERN { ACTION }' file

awk automatically splits each line into fields by whitespace:
  $1, $2, $3...   individual fields, numbered from 1
  $0                the entire original line, untouched

$1/$2/etc here means something completely different from $1/$2 in a
script's arguments (Session 8) - same symbol, different meaning depending
on context, consistent with a pattern seen throughout this phase.

awk '{print $1}' file          print field 1 of every line
awk '/PATTERN/ {print $1}'       print field 1, but ONLY for lines matching
                                   PATTERN - this is grep's filtering and
                                   cut's column-picking combined in one tool

awk is a mechanical column-splitter - it has no awareness of meaning, only
position. A field number lines up differently depending on how many words
came before it on that specific line, so $4 can be a completely different
kind of value across lines with different sentence structures. Works best
on data with a consistent, predictable format.

## cut
cut -d ":" -f 1 file        -d sets the delimiter (what character separates
                              fields; default awk uses whitespace, cut needs
                              it specified explicitly)
                            -f picks which field number(s), e.g. -f 1,3 for
                              multiple fields

Real reason cut exists alongside awk: for a simple one-delimiter,
one-or-few-field job, cut is faster to write and read. awk is reached for
once you need pattern matching or more complex field logic.

## sort and uniq
uniq only removes CONSECUTIVE duplicate lines - not duplicates anywhere in
the file. Running uniq on unsorted input where matching lines aren't
adjacent does nothing useful; every line still prints, since none of the
duplicates happen to be next to each other.

sort file | uniq          sort first, so identical lines become adjacent,
                             THEN uniq can actually collapse them
sort file | uniq -c          same, but also prints a count of how many times
                                each unique line appeared

sort | uniq -c is genuinely one of the most common one-liners in all of
Linux - used constantly to count occurrences of anything: log levels,
HTTP status codes, IP addresses hitting a server.

## xargs vs find -exec
find . -name "*.log" | xargs echo "Processing:"
                                   batches ALL matched filenames into ONE
                                   command call - echo runs once total, with
                                   every filename appended as arguments

find . -name "*.log" -exec echo "Found:" {} \;
                                   runs echo SEPARATELY, once per matched
                                   file - one process spawned per match

For something cheap (echo) the difference is invisible. For something
expensive per file (compressing, uploading, calling an API), whether the
whole batch runs as one process or spawns one process per file is a real,
meaningful performance difference in production automation.
