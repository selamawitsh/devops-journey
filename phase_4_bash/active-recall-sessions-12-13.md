# Active Recall — Sessions 12-13 (Text Processing through Automation Patterns)

Answer each question from memory before checking the answer key at the
bottom. Don't scroll ahead.

## Session 12 — Text Processing

1. Why does `find . -name "*.log"` return results from subdirectories,
   while `ls *.log` only looks in the current directory?
2. Why must the pattern in `find . -name "*.log"` be quoted?
3. What's the difference between `find . -mtime -1` and
   `find . -mtime +7`? Which direction does the sign flip?
4. Does `find . -size +0c` mean "this file exists," or something more
   specific? What would a file created by `touch` show up as here?
5. What does `find . -name "*.log" -exec echo "{}" \;` actually do —
   what does `{}` represent, and what does `\;` mark?
6. What's the difference between `grep -c "ERROR" file` and
   `grep "ERROR" file | wc -l`? Do they give the same answer?
7. What does `grep -v "ERROR" file` show you, compared to plain
   `grep "ERROR" file`?
8. Why would you use `grep -A 1` instead of just `grep` alone when
   debugging a real error in a log?
9. If you run `sed 's/ERROR/CRITICAL/' logs/app.log` and then
   immediately `cat logs/app.log`, will the file show `CRITICAL` or
   `ERROR`? What flag would change that?
10. What's the difference between `sed 's/ERROR/CRITICAL/'` and
    `sed 's/ERROR/CRITICAL/g'`?
11. In `awk '{print $3}' app.log`, what does `$3` actually mean? Is it
    guaranteed to always represent the same KIND of value on every line?
12. What does `awk '/CRITICAL/ {print $1, $2}' app.log` do — break down
    the pattern part and the action part separately.
13. What's the practical difference between using `cut` and using `awk`
    for extracting a field from a line?
14. Why does `uniq servers_status.txt` (run directly, without sorting
    first) often do nothing useful?
15. What does `sort file | uniq -c` give you that plain `sort file | uniq`
    doesn't?
16. What's the difference in how many times a command runs between
    `find . -name "*.log" | xargs echo "Processing:"` and
    `find . -name "*.log" -exec echo "Found:" {} \;`?
17. Why would `find ... -print0 | xargs -0 ...` be safer than a plain
    `find ... | xargs ...` pipe, in a real script?

## Session 13 — Automation Patterns

18. What's the precise definition of an idempotent script?
19. Why does plain `mkdir /tmp/app_config` fail the second time it's
    run, and what are two different ways to fix that specifically?
20. What's the difference between the "BAD mindset" and the "BETTER
    mindset" described for writing automation — commands vs. what?
21. In a dry-run implementation, why is it dangerous to write two
    completely separate code paths (one that echoes a description, one
    that runs the real command) instead of one function that does both?
22. What does `${1:-}` accomplish in a dry-run script's argument check,
    and why does it matter specifically when `set -u` is active?
23. Which log level(s) go to stdout, and which go to stderr, in a
    standard log_info/log_warn/log_error setup?
24. If you run a script as `./script.sh 2>/dev/null`, and it calls both
    log_info and log_error internally, what will actually show up on
    screen?
25. What does `source config.sh` actually do to the variables inside
    config.sh — are they isolated to a subprocess, or do they become
    available in the current script?
26. What's the real-world benefit of separating configuration into its
    own file, instead of hardcoding values directly in the script?

---

# Answer Key

1. find searches RECURSIVELY through the entire directory tree starting
   from the given path. ls only lists the contents of the exact
   directory it's run in, with no awareness of subdirectories at all.
2. Without quotes, Bash itself would expand *.log against files in the
   CURRENT directory before find ever receives the pattern — potentially
   matching the wrong files, or erroring if nothing matches locally.
   Quoting passes the literal pattern to find, which then applies it at
   every level of the tree.
3. -mtime -1 means modified within the last 1 day (less than). -mtime +7
   means modified more than 7 days ago (greater than). The sign flips
   the direction of the comparison — easy to get backwards.
4. It means "has actual content" (size strictly greater than 0 bytes),
   not "exists." A file created by touch is empty (0 bytes) and would
   FAIL this test even though it's a completely real file on disk.
5. {} is a placeholder that gets replaced with each matched filename.
   \; marks the end of the command being run for -exec. The whole thing
   runs the given command once per matched file.
6. Yes, same answer — both count matching lines. -c is simpler to type
   for a plain count; the piped wc -l version is more flexible since you
   can insert additional filtering steps into the pipeline before
   counting.
7. grep -v inverts the match — it shows every line that does NOT contain
   the pattern, the opposite of plain grep.
8. -A 1 shows the matching line plus 1 line of context after it. An
   isolated error line often doesn't tell the full story on its own;
   the surrounding context (what happened right after) helps diagnose
   what actually went wrong.
9. It will still show ERROR — sed only prints the transformed result to
   the screen by default, it never modifies the file unless you add the
   -i flag (in-place editing).
10. Without g, only the FIRST match on each line gets replaced. With g
    (global), EVERY match on each line gets replaced.
11. $3 means "whichever word ends up in position 3 when the line is
    split by whitespace" — purely mechanical, no awareness of meaning.
    It is NOT guaranteed to represent the same kind of value across
    different lines if those lines have different sentence structures
    or numbers of words before that position.
12. /CRITICAL/ is the PATTERN — it filters awk down to only the lines
    that contain "CRITICAL", the same idea as grep's matching. {print $1,
    $2} is the ACTION — for each line that survived the filter, print
    just fields 1 and 2. Together: filter rows, then pick columns, in
    one tool.
13. cut is simpler and faster to write for a basic "split on ONE
    delimiter character, grab a field" job. awk is used once you need
    pattern matching (filtering which lines even get processed) or more
    complex logic beyond a simple split.
14. uniq only removes CONSECUTIVE duplicate lines. If matching lines
    aren't already sitting next to each other in the file (which is
    common in an unsorted file), uniq finds no adjacent duplicates to
    collapse and effectively does nothing.
15. uniq -c adds a COUNT showing how many times each unique line
    appeared, not just the deduplicated list of lines themselves.
16. xargs bundles ALL matched filenames into ONE single command call
    (echo runs once total, with every filename as an argument). -exec
    runs the command SEPARATELY, once per matched file (N filenames = N
    separate command invocations).
17. Filenames can contain spaces or special characters, which a plain
    newline-based pipe into xargs can misinterpret as multiple separate
    arguments. -print0 separates filenames with a null byte instead of a
    newline, and -0 tells xargs to expect that — null bytes can never
    appear inside a real filename, making this separator always
    unambiguous regardless of what the filename contains.
18. A script is idempotent if running it once, or running it any number
    of times, produces the same final state, with no errors caused
    purely by "the desired outcome is already true."
19. Because mkdir errors out if the target directory already exists —
    the second run has nothing new to create. Fix 1: check first with
    an if [[ -d ... ]] guard before calling mkdir. Fix 2: use mkdir -p,
    which is already idempotent on its own for this specific case.
20. BAD mindset: "what commands should I run?" (assumes a clean starting
    point every time). BETTER mindset: "what STATE do I want the system
    to end up in?" (checks whether that state is already true before
    acting, and only acts on what's actually missing).
21. Because the two paths can drift out of sync over time — if someone
    updates the real command later but forgets to update the separately
    hand-written dry-run description to match, the preview will lie
    about what the script actually does, defeating the entire purpose of
    trusting a dry-run before running for real.
22. ${1:-} supplies an empty-string fallback if no first argument was
    given at all, instead of referencing $1 directly. Under set -u, an
    unset/never-provided $1 would trigger an "unbound variable" error
    and stop the script; ${1:-} avoids that by always safely evaluating
    to something (empty string, if nothing was passed).
23. log_info goes to stdout. log_warn and log_error both go to stderr
    (using >&2).
24. Only the log_info output — 2>/dev/null discards stderr entirely, and
    since log_error writes to stderr, its output vanishes along with any
    log_warn output; only stdout (log_info) remains visible.
25. They become available directly in the CURRENT shell/script's
    environment, exactly as if you'd typed those variable assignments
    yourself. source does NOT run the file in an isolated subprocess —
    there's no separation at all.
26. Settings (paths, retention periods, environment names, etc.) can be
    changed by editing a plain variable-assignment file, without
    touching or risking the actual script logic — safe even for someone
    who doesn't know Bash, and avoids needing to edit/redeploy the
    script itself just to change a value.
