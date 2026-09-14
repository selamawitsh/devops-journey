# Notes — stdin, stdout, stderr, and Redirection

## The three streams
0 = stdin   input coming into a command
1 = stdout  normal output
2 = stderr  error output

They're separate specifically so normal output and errors can be handled
independently. A script or cron job can redirect stdout to a clean data/log
file while letting stderr surface separately (or be captured on its own) —
without errors contaminating output meant to be parsed.

## > vs >>
> log.txt    overwrites the file completely, every single time
>> log.txt    appends to the end, keeping existing content

Real-world consequence: a script that logs with > instead of >> wipes its
own log history on every run. This is a common accidental data-loss bug in
cron jobs and monitoring scripts that are supposed to accumulate a history.

## Redirecting stderr, and the 2>&1 gotcha
2> errors.txt              sends ONLY stderr to a file, stdout still shows on screen
> out.txt 2>&1               sends stdout to out.txt, THEN tells stderr to follow
                               stdout — both land in the same file
2>&1 > out.txt                WRONG ORDER — stderr binds to wherever stdout was
                                pointing at that moment (the terminal), THEN stdout
                                gets redirected. Result: errors still print to the
                                screen, only stdout goes to the file.

Rule: redirect stdout first, then point stderr at it with 2>&1 — order matters
because each redirection is applied left to right, and 2>&1 means "wherever
stream 1 currently points," not "wherever it will point later."

## Pipes
command1 | command2
Sends command1's stdout directly into command2's stdin, no file involved.
This is the single most-used pattern in Linux/DevOps work — chaining small,
focused tools (grep, sort, wc, awk, cut) instead of one command doing
everything. Directly connects to the log-parsing work from the Linux phase.
