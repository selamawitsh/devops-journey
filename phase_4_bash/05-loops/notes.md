# Notes — Loops

## for loops
for file in *.log; do ... done        # loops over glob-matched filenames
for server in web01 web02 web03; do ... done   # loops over a plain word list

## The nullglob gotcha
If *.log matches zero files, Bash's DEFAULT behavior is to pass the pattern
through unexpanded — the loop runs ONCE with file="*.log" literally, not
zero times as you'd expect.

Fix:
  shopt -s nullglob
With this set, an unmatched glob expands to nothing, so the loop body simply
never runs. Real-world relevance: a log-rotation/cleanup script run against
an already-empty directory can otherwise try to operate on a literal
"*.log" string instead of skipping cleanly.

## while vs until
while   -> runs AS LONG AS the condition is true
until   -> runs UNTIL the condition becomes true (loops while it's false)
Same underlying logic, different phrasing — until often reads more naturally
for "wait until X happens" patterns, e.g. waiting for a server to come back
after reboot:
  until ping -c 1 server01 &> /dev/null; do sleep 2; done

## Arithmetic expansion
counter=$((counter + 1))    # $(( )) does math directly, no external command
Different from $( ) which runs a command and captures its output.
Also written ((counter++)) — same effect, C-style syntax.

Forgetting to update the loop variable/condition inside a while/until loop
is one of the most common real production incidents: an infinite loop that
pins a CPU core and can silently run for hours, or flood a log file.

## break vs continue
break     -> exits the loop entirely, no further iterations at all
continue  -> skips the REST of the current iteration only, moves straight to
             the next iteration's condition check; the loop keeps running

Real-world case: looping through servers to deploy to — continue past a
server in maintenance mode (skip it, keep going), break immediately on a
critical error (stop the whole rollout).
