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

## trap — running cleanup no matter how the script ends

### The problem trap solves

Scripts often create temporary state while running: temp files, lock
files, partial output. If the script finishes normally, cleanup at the
bottom handles it. But if the script is interrupted halfway (Ctrl+C,
a set -e failure, a server reboot), that cleanup code at the bottom never
gets reached — the temp state is left behind.

### Basic syntax

    trap COMMAND SIGNAL

Example:

    trap cleanup EXIT

Read as: "Bash, whenever this script's process is ending, run the
cleanup function first." Notice cleanup is never called directly anywhere
in the main script body — trap is what invokes it, automatically, at
the right moment.

### The full flow, normal completion

    script starts
        |
    create /tmp/demo_tempfile
        |
    do work
        |
    sleep
        |
    work finishes normally
        |
    script exits
        |
    trap sees EXIT
        |
    cleanup() runs
        |
    temp file removed

### The full flow, interrupted with Ctrl+C

           script
             |
      +------+------+
      |             |
  normal exit   interrupted (Ctrl+C)
      |             |
      +------+------+
             |
     trap cleanup EXIT
             |
        cleanup() runs
             |
     temp file removed either way

Both paths converge on the same cleanup step. That's the entire point:
trap makes cleanup unconditional, not dependent on the script reaching
its last line normally.

### Common signals to trap

    EXIT     runs when the script's process ends, for ANY reason at all —
             normal completion, a set -e failure, or after being killed.
             This is the catch-all, and the one used almost everywhere.

    INT      "interrupt" - specifically Ctrl+C (SIGINT)

    TERM     a termination request, commonly sent via: kill <PID>

### An important distinction worth getting exactly right

It's tempting to think:

    trap cleanup EXIT   ->   "this catches Ctrl+C"

That's not quite accurate. It catches EXIT specifically — the moment the
process actually ends. When you press Ctrl+C, the shell sends the script
a SIGINT signal; Bash's default response to SIGINT is to terminate the
script, and THAT termination is what triggers the EXIT trap. So the EXIT
trap doesn't intercept the keypress itself — it fires as a downstream
consequence of the process ending, no matter what caused the ending.

This is why trap cleanup EXIT alone is enough to cover Ctrl+C, a set -e
failure, and normal completion all at once — you don't need three
separate traps for the common case, just one on EXIT.

### Mental model: the emergency cleanup crew

    cleanup() is like a cleanup crew on standby.
    It doesn't matter whether the job finished on schedule
    or got called off halfway through —
    the crew still gets dispatched the moment work stops.

### Real-world case: a deployment lock file

    #!/bin/bash

    LOCK_FILE="/tmp/deploy.lock"

    cleanup() {
        rm -f "$LOCK_FILE"
    }

    trap cleanup EXIT

    touch "$LOCK_FILE"
    echo "Deploying..."
    # ...deployment work...

Without trap: someone presses Ctrl+C mid-deploy, /tmp/deploy.lock is
left behind. The next deployment attempt checks:

    if [ -f "$LOCK_FILE" ]; then
        echo "Deployment already running!"
        exit 1
    fi

and now every future deploy falsely refuses to run, blocked by a lock
file from a deployment that isn't actually running anymore — someone has
to notice, SSH in, and manually delete the lock file before deploys work
again. trap closes this gap entirely by guaranteeing the lock is released
regardless of how the script exits.

### Session 10, full picture combined

    #!/bin/bash
    set -euo pipefail

    cleanup() {
        # remove temp files
        # release locks
        # clean up partial state
    }
    trap cleanup EXIT

    # rest of the script

Core mental model to carry forward:
set -e catches failed commands.
set -u catches missing variables.
pipefail catches failures hidden inside pipelines.
trap guarantees cleanup runs no matter how the script's process ends.
