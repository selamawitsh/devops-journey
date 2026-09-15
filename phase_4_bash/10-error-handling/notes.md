# Notes — Error Handling

## set -e

Default Bash behavior — script keeps going even after a failure:

    Step 1 (ok)
        |
    Step 2 (FAILS)
        |
    Step 3 (still runs)
        |
    Step 4 (still runs)

With set -e — script stops the instant a command fails:

    Step 1 (ok)
        |
    Step 2 (FAILS)
        |
       STOP
    (Step 3 and 4 never run)

Real-world danger without it: a deploy script running
git pull -> run tests -> deploy to production.
If git pull fails silently, the script proceeds to test and deploy STALE
code with no warning at all. set -e turns silent, cascading failure into
an immediate, loud stop at the exact line where things went wrong.

## set -u

Default Bash behavior — an undefined variable silently becomes an empty
string:

    $backup_dir     (never set, so it's just "")
        |
    "$backup_dir/temp"
        |
    becomes: "/temp"     <- a real, valid, top-level path
        |
    rm -rf "/temp"        <- executed with no warning

With set -u — Bash refuses to let an undefined variable pass silently:

    $backup_dir     (never set)
        |
    Bash checks: has this variable ever been assigned?
        |
       NO
        |
    STOP: "backup_dir: unbound variable"

Real-world danger without it: a typo'd variable name, or a variable that
failed to get set earlier due to an unrelated bug, silently turns into a
catastrophic wildcard path instead of an immediate, diagnosable failure.

## set -o pipefail (turn off with set +o pipefail)

Default Bash behavior — a pipeline's exit code is only ever the LAST
command's exit code, even if an earlier command in the same pipeline
failed:

    ls /missing  |  wc -l
    exit 2          exit 0
       (fails)      (succeeds on empty input)
                       |
                       v
              $? reports 0   <- WRONG signal, ls's failure is invisible

With pipefail — the pipeline reports the RIGHTMOST command that failed,
not just whatever the last command happened to return:

    ls /missing  |  wc -l
    exit 2          exit 0
       (fails)      (succeeds)
       |
       v
    pipefail scans right-to-left for a failure
       |
       v
    $? reports 2   <- ls's real failure, correctly surfaced

Important precision: "rightmost command that failed" is not the same as
"root cause" or "first thing that broke." If TWO commands in a pipeline
both fail, pipefail reports whichever one is furthest right in the chain —
that may or may not be the command that actually caused the problem.
Example:

    ls /missing  |  grep "txt"
    exit 2          exit 1
       (fails)      (also fails - found nothing to match)
                       |
                       v
              pipefail reports 1, not 2
              (grep is rightmost, even though ls is the real story)

pipefail tells you THAT a pipeline failed, not definitively WHICH command
in it is the one worth investigating first.

Real-world danger without pipefail: curl https://api/data | jq '.results'
— if curl fails (API down), jq may still exit 0 on empty input, and the
script proceeds to use garbage/empty data as if the whole thing succeeded.

## set -euo pipefail

The standard combined line at the top of nearly every serious production
Bash script:

    -e             stop on any failed command
    -u             stop on any undefined variable
    -o pipefail    don't let pipeline failures hide behind the last command

Together, in plain English: "don't silently continue when my script
screws up."

set/unset options are session-wide or script-wide, not line-scoped — once
set, they stay active for everything after that point until explicitly
reversed (set +e, set +u, set +o pipefail).
