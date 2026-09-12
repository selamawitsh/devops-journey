# Notes — Variables and Quoting

## Declaring variables
name="Selamawit"        # correct — zero spaces around =
name = "Selamawit"       # wrong — Bash reads "name" as a command to run, "=" and
                          # "Selamawit" as its arguments, then fails with
                          # "command not found"

Bash's parser only recognizes WORD=VALUE (no spaces at all) as an assignment.
Any space breaks that pattern. This is one of the most common first-week bugs
for anyone coming from Python, JS, or Go, all of which allow spaces around =.

## Single vs double quotes
"double quotes"   -> expansion still happens ($variable, $(command))
'single quotes'   -> nothing expands, 100% literal text

Rule of thumb: default to single quotes, only use double quotes when you
specifically need something inside to expand. Double quotes open the door to
expansion, which can behave unexpectedly on input you don't fully control
(filenames with $ in them, variables containing shell metacharacters).

## Escaping
Inside double quotes, a backslash cancels the special meaning of the next
character only.
  echo "Cost: \$5"   -> Cost: $5
Without the backslash, Bash would try to expand $5 (a positional parameter,
covered in Session 8), which is usually empty — producing wrong output with
no error at all. Silent bad output is worse than a crash.

## Command substitution
today=$(date)      # preferred, modern
today2=`date`       # legacy backtick syntax, still POSIX-valid

Always use $(...). Reasons:
- Nests cleanly: $(echo $(date)) vs unreadable escaped backticks
- Backtick characters are easy to misread as a stray single quote
- Every modern style guide (including Google's shell style guide) mandates $(...)
Backticks in a script you're maintaining are a signal the script is old and
may have other outdated patterns worth checking.

## Local variables vs exported (environment) variables
Every command you run spawns a new child process. A plain variable
(myvar="value") only exists in the shell that created it — a child process
never sees it. export myvar="value" copies the variable into every child
process spawned from that point on.

  plain_var="not exported"
  export env_var="exported"
  bash -c 'echo $plain_var'   -> empty, child never received it
  bash -c 'echo $env_var'     -> prints, child received a copy at spawn time

Real-world relevance: this is exactly how environment variables work in
Docker containers and CI/CD pipelines (GitHub Actions, Jenkins, etc). A
pipeline step only sees a variable if an earlier step explicitly exported it.
Setting a variable without export and expecting a called script to see it is
one of the most common "why did my env var disappear" bugs in automation.

## readonly
readonly PI=3.14159
PI=3.14                # bash: PI: readonly variable

Once declared readonly, any later assignment to that name fails with an
error rather than silently changing it. Used for constants that should never
be reassigned partway through a script (e.g. a fixed config path).
