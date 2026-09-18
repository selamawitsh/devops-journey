
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
