# Notes — Error Handling

## set -e
Default Bash behavior: if a command fails, the script keeps running the
remaining lines anyway. set -e stops the script immediately at the first
command that returns a non-zero exit code.

Real-world danger without it: a deploy script running git pull, then tests,
then deploy — if git pull fails silently, the script proceeds to test and
deploy STALE code with no warning. set -e turns silent, cascading failure
into an immediate stop.

## set -u
Default Bash behavior: referencing an undefined variable silently evaluates
to an empty string, no error. set -u makes this an immediate error instead:
"VARNAME: unbound variable".

Real-world danger without it: rm -rf "$backup_dir/temp" where $backup_dir
was never set becomes rm -rf "/temp" — a valid, real, catastrophic path,
executed with no warning at all. A typo'd variable name or a variable that
failed to get set earlier in the script becomes a silent path to disaster
rather than a loud, immediate failure at the exact problem line.

## set -o pipefail (and set +o pipefail to turn it off)
Default Bash behavior: a pipeline's exit code ($?) is ONLY the exit code of
the LAST command in the chain, even if an earlier command in that same
pipeline failed.
  ls /missing | wc -l   -> ls fails (2), wc -l succeeds on empty input (0)
                            $? without pipefail = 0 (wc's status, wrong signal)
                            $? with pipefail    = 2 (ls's real failure, surfaced)

Precise rule: pipefail reports the RIGHTMOST command in the pipeline that
failed, not necessarily the first/root cause. If multiple commands in the
chain fail, whichever is furthest right wins — pipefail tells you THAT
something failed, not definitively WHICH one is the real root story if more
than one link broke.

set/unset persist for the whole shell session or script (not just the next
line) until explicitly reversed with set +o pipefail (or set +e, set +u).

Real-world danger without it: curl https://api/data | jq '.results' — if
curl fails (API down), jq may still exit 0 on empty input, and the script
proceeds as if it got real data.

## set -euo pipefail
The combined line seen at the top of nearly every serious production Bash
script. Each flag closes a different gap:
  -e            stop on any failed command
  -u            stop on any undefined variable
  -o pipefail   don't hide a failure inside a pipeline behind the last command
Together: "don't silently continue when something goes wrong."

## trap
Runs a specified function/command when the script's process ends — for ANY
reason: normal completion, a failure caught by set -e, or manual
interruption (Ctrl+C).

  cleanup() { rm -f /tmp/tempfile; }
  trap cleanup EXIT

EXIT is the catch-all signal (covers virtually every way a script can end).
Specific signals can also be trapped, e.g. trap cleanup SIGINT (Ctrl+C
only) or trap cleanup ERR (only on a failing command).

Real-world danger without it: a backup script that creates a lock directory
at the start and removes it at the end. If the script is killed halfway
(reboot, Ctrl+C, an unrelated set -e failure) with no trap, the lock is
never released — every future run thinks a backup is still in progress and
refuses to start, requiring manual cleanup.
