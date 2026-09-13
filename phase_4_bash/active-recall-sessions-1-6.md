# Active Recall — Sessions 1-6 (Bash Fundamentals through Case Statements)

Answer each question from memory before checking the answer key at the
bottom. Don't scroll ahead.

## Session 1 — Bash Fundamentals

1. What's the difference between what `$SHELL` tells you and what
   `ps -p $$` tells you? Which one can lie to you, and why?
2. Why does `./script.sh` require the execute permission bit, but
   `bash script.sh` does not?
3. What does the shebang line actually do, and when is it completely
   ignored?
4. Why do many production scripts use `#!/usr/bin/env bash` instead of
   `#!/bin/bash`?

## Session 2 — Variables and Quoting

5. Why does `name = "Selamawit"` (with spaces) fail, and what does Bash
   think you're trying to do instead?
6. What's the actual difference in behavior between single quotes and
   double quotes?
7. What does the backslash do in `echo "Cost: \$5"`, and what would print
   without it?
8. Why is `$(...)` preferred over backtick command substitution?
9. A script sets `API_KEY=abc123` (no export) and then calls a second
   script. Will the second script see `API_KEY`? Why or why not?
10. What happens if you try to reassign a `readonly` variable?

## Session 3 — Exit Codes and Conditions

11. What does an exit code of `0` always mean, regardless of which
    command produced it?
12. What does exit code `137` typically indicate, and why?
13. Run `type [` versus `type [[` — what's the fundamental difference
    between them, and what real bug does that difference cause?
14. Why does `[ $name = "John Smith" ]` fail with "too many arguments"
    when `$name` holds "John Smith", but `[[ $name = "John Smith" ]]`
    does not?

## Session 4 — If / Elif / Else and Conditions

15. In an if/elif/else chain, what happens once one branch's condition
    is found true — does Bash keep checking the rest?
16. Why are `-eq` and `==` not interchangeable, and what real-world value
    (give an example) demonstrates why the distinction matters?
17. What does the `-z` test check for? What does `-n` check for?
18. What's the difference between `&&` and `||` inside a `[[ ]]`
    condition?

## Session 5 — Loops

19. If a `for file in *.log` loop runs in a directory with zero matching
    files, what does Bash do by default, and what command fixes that
    behavior?
20. What's the practical difference between `while` and `until`?
21. What does `counter=$((counter + 1))` do, and why would forgetting
    this line inside a while loop be dangerous on a real server?
22. What's the difference between `break` and `continue`? Give one
    real-world scenario for each.

## Session 6 — Case Statements

23. What role does the `*)` branch play in a `case` statement, and why
    does a production script always want one even if you're confident
    about the input?
24. How would you write one `case` branch that matches both `y`, `Y`,
    `yes`, and `Yes`?
25. Does `case` support glob-style patterns like `*.log`, or only exact
    literal words?

---

# Answer Key

1. `$SHELL` is your stored login shell default — it doesn't update if you
   switch shells mid-session, so it can be stale. `ps -p $$` shows the
   actual running process for your current shell, which is always
   accurate.
2. `./script.sh` asks the kernel to execute the file directly, which
   requires the execute bit. `bash script.sh` runs the bash binary
   (which already has execute permission) and hands your script to it as
   plain text to read — only read permission is needed.
3. The shebang tells the kernel which interpreter to use when a script is
   executed directly. It's ignored when you explicitly run the script
   with an interpreter, e.g. `bash script.sh`.
4. `#!/bin/bash` assumes bash lives at exactly `/bin/bash`, which isn't
   guaranteed on every system (macOS, BSD, some containers).
   `#!/usr/bin/env bash` searches PATH instead, making the script portable.
5. Bash only recognizes `WORD=VALUE` with zero spaces as an assignment.
   With spaces, it reads `name` as a command to run, and fails with
   "command not found" since no such command exists.
6. Double quotes still allow expansion ($variable, $(command)). Single
   quotes disable all expansion — everything inside is literal text.
7. The backslash escapes the `$`, so it's printed literally instead of
   triggering expansion. Without it, Bash would try to expand `$5` (a
   positional parameter), usually resulting in silent, wrong output.
8. `$(...)` nests cleanly without escaping, and is visually unambiguous.
   Backticks require awkward escaping to nest and are easy to misread as
   a stray single quote.
9. No — `API_KEY` was never exported, so it only exists in the shell that
   created it. A child process (the second script) never receives it.
10. Bash rejects the reassignment with an error like
    "VARNAME: readonly variable" — the value cannot be changed.
11. Success, always, for any command, with no exceptions.
12. It typically means the process was killed by a signal — specifically
    128 + 9 (SIGKILL), commonly seen when a container is OOM-killed.
13. `[` is a shell builtin (an actual command), `[[` is a shell keyword
    parsed directly by Bash's grammar. Because `[` is a real command, an
    unquoted variable passed to it goes through word-splitting.
14. Because `[` is a command, `$name` gets expanded and word-split before
    `[` sees it, turning "John Smith" into two separate arguments — five
    total where three are expected. `[[` is parsed by Bash directly and
    never word-splits, so the value stays intact as one string.
15. No — Bash stops at the first true branch and skips everything else in
    the chain, including any later elif or else.
16. `-eq` compares numerically, `==` compares as text/characters. Version
    strings like "1.10" vs "1.9" demonstrate the issue: numerically 1.10
    is greater, but string comparison sorts them differently.
17. `-z` tests whether a string is empty. `-n` tests whether a string is
    NOT empty.
18. `&&` requires both conditions to be true. `||` requires at least one
    of them to be true.
19. By default, Bash passes the unmatched glob through literally, so the
    loop runs once with the pattern itself as a string. `shopt -s nullglob`
    makes an unmatched glob expand to nothing, so the loop simply doesn't run.
20. `while` runs as long as its condition is true. `until` runs as long as
    its condition is false (i.e., until it becomes true). Same logic,
    opposite phrasing — until often reads more naturally for "wait until X".
21. It's arithmetic expansion that increments counter by 1. Forgetting it
    means the loop's condition never changes, causing an infinite loop
    that can pin a CPU core or flood a log file for hours undetected.
22. `break` exits the loop entirely, no further iterations run at all.
    `continue` skips only the rest of the current iteration and moves to
    the next one. Example: `continue` past a server in maintenance mode
    while deploying; `break` immediately on a critical error that should
    stop the whole rollout.
23. `*)` is the catch-all, matching any input that didn't match an
    earlier pattern. Without it, unexpected input (a typo, an
    unsupported argument) silently matches nothing and the script does
    nothing with no error — a production script should always give clear
    feedback instead.
24. `y|Y|yes|Yes) ... ;;` — the pipe lets one branch match multiple
    values.
25. Yes — `case` supports the same glob syntax used in filename matching,
    e.g. `*.tar.gz)`, `*.log)`, not just exact literal words.
