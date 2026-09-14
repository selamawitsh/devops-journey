# Active Recall — Sessions 7-9 (Functions through Redirection)

Answer each question from memory before checking the answer key at the
bottom. Don't scroll ahead.

## Session 7 — Functions and Scope

1. Why does calling a function before its definition appear in the script
   fail, and what specific error does it produce?
2. If you call a function with no arguments, does `$1` inside it cause an
   error? What value does it actually hold?
3. Without `local`, what happens when a function assigns to a variable
   that shares a name with a global variable? Why is this the opposite of
   what most other languages do?
4. Why does `return $(( 200 + 100 ))` NOT give you 300 in `$?`? What
   value do you actually get, and why?
5. What is `return` actually for, and what is `echo` (with command
   substitution) actually for? Why can't you use `return` to hand back a
   computed value like a sum or a filename?

## Session 8 — Script Arguments

6. What does `$0` actually contain — a cleaned-up script name, or
   something else? What determines its exact value?
7. A script is called with 3 arguments but only ever references `$1` and
   `$2`. Is the third argument discarded by Bash, or still accessible?
8. What's the difference in behavior between unquoted `$@` and quoted
   `"$@"` when an argument contains a space?
9. Why is `"$@"` (quoted) specifically the safe choice when a wrapper
   script needs to forward its arguments to another command like
   `kubectl` or `docker`?
10. What does `shift` do to `$1`, `$2`, `$3`, and `$#` each time it's
    called?
11. In `getopts "e:v" opt`, what does the colon after `e` mean, and where
    does that flag's value end up?

## Session 9 — stdin/stdout/stderr and Redirection

12. What are the three default file descriptors, and what number is each
    one?
13. Why are stdout and stderr kept as separate streams instead of one
    combined stream?
14. What's the difference between `>` and `>>`? What real-world bug
    happens when a script uses `>` where it meant `>>`?
15. What does `2>&1` actually mean in plain English?
16. Why does `command > file.txt 2>&1` work correctly, but
    `command 2>&1 > file.txt` does not send stderr to the file?
17. What does a pipe (`|`) do, and why is chaining small commands with
    pipes preferred over one large command that does everything?

---

# Answer Key

1. Bash executes a script top to bottom with no hoisting — it hasn't seen
   the function definition yet when it hits the call, so it fails with
   "command not found," the same error as calling any undefined command.
2. No error — `$1` is simply an empty string, and `$#` would be `0`. A
   function that assumes an argument was provided without checking will
   run silently with blank values instead of failing clearly.
3. The global variable gets directly overwritten — Bash defaults to
   global scope for function-assigned variables. This is the opposite of
   Python, JavaScript, and Go, which default to local scope inside a
   function, which is exactly why it catches people off guard.
4. You get `44`, not `300`. `return` is capped at 0-255 because an exit
   code is a single byte — `300 mod 256 = 44`, and Bash wraps silently
   with no warning.
5. `return` is exclusively for the exit code — success/failure, or a
   small coded reason for failure, 0-255 only. `echo`, captured with
   `$(...)`, is how a function hands back real computed data. `return`
   physically cannot hold values above 255, so it's structurally
   incapable of being a general value-return mechanism.
6. It's exactly the text used to invoke the script — `./script.sh`,
   `script.sh`, or a full path — not a cleaned-up or normalized name. It
   depends entirely on how the script was called.
7. Still fully accessible as `$3` — Bash received and counted it (`$#`
   would show `3`). The script simply never referenced `$3` in its logic;
   Bash doesn't discard or validate arguments for you.
8. Unquoted `$@` word-splits the value, breaking "New York" into `New`
   and `York` as separate items. Quoted `"$@"` preserves each original
   argument intact as one string, spaces included.
9. Because unquoted `$@` would let word-splitting mangle any argument
   containing a space before the wrapped command receives it. `"$@"`
   guarantees each argument arrives exactly as the user originally typed
   it.
10. `shift` moves every positional argument down by one (`$2` becomes
    `$1`, `$3` becomes `$2`, etc.) and decreases `$#` by one. This lets a
    while loop process arguments one at a time until none remain, without
    needing to know the count in advance.
11. The colon means that flag requires a value to follow it on the
    command line; that value lands in the special variable `$OPTARG`. A
    letter with no colon is just a boolean on/off switch.
12. `0` = stdin (input), `1` = stdout (normal output), `2` = stderr
    (error output).
13. So normal output and error output can be handled independently — a
    script or cron job can capture clean output to parse or log, without
    error messages mixed into it.
14. `>` overwrites the target file completely every time it runs. `>>`
    appends to the end, preserving existing content. Using `>` where
    `>>` was intended wipes a script's entire log history on every
    single run — a common accidental data-loss bug in cron jobs.
15. "Send stream 2 (stderr) to wherever stream 1 (stdout) is currently
    pointing."
16. Redirections are applied left to right. In the working version, stdout
    is redirected to the file first, so when `2>&1` runs, stderr follows
    it into the file. In the broken version, `2>&1` runs first — at that
    point stdout is still pointing at the terminal, so stderr binds to
    the terminal. The later `> file.txt` only redirects stdout after
    that, leaving stderr still going to the screen.
17. A pipe sends one command's stdout directly into the next command's
    stdin, no intermediate file needed. Chaining small, focused tools
    (grep, sort, wc, awk, cut) is preferred because each tool does one
    thing well and the pieces can be recombined for different tasks,
    rather than needing one large, rigid command for every situation.
