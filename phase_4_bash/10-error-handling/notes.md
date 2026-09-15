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
