# Notes — Exit Codes and Conditions

## $? — the exit code
Every command that finishes leaves a number 0-255 in $?, checked immediately
after the command runs (it gets overwritten by the next command).
  0        -> success, always, for any command
  non-zero -> failure, and the specific number often encodes what kind

Common conventions:
  1        general/catch-all error
  2        misuse of command (bad arguments, invalid path)
  126      file found but not executable
  127      command not found
  128 + N  killed by signal N (137 = 128+9 = SIGKILL, e.g. Docker OOM-kill)

Real-world relevance: kubectl describe pod showing exit code 137 immediately
tells an engineer "OOM-killed" instead of a vague "something broke."

## true and false
Commands whose entire purpose is producing an exit code and nothing else.
  true   -> always exits 0
  false  -> always exits 1
Used constantly for intentional infinite loops:
  while true; do ...; done

## test, [ ], and [[ ]]
type [     -> "[ is a shell builtin"    (an actual command)
type test  -> "test is a shell builtin" (same thing, different name)
type [[    -> "[[ is a shell keyword"   (part of bash's grammar, not a command)

Because [ is a real command, Bash expands variables before [ ever sees them,
going through normal word-splitting. An unquoted variable containing spaces
gets split into multiple arguments:

  name="John Smith"
  [ $name = "John Smith" ]     -> "too many arguments"
                                    ([ actually receives: John Smith = "John Smith")
  [[ $name = "John Smith" ]]   -> works, no splitting, treated as one value

Rule: always quote variables inside test expressions - "$name" - regardless
of which bracket form you use. [ ] is POSIX-standard, works in any shell
(sh, dash — common on minimal container images). [[ ]] is bash-only but adds
built-in protection against word-splitting plus pattern matching and regex
(=~), covered later. Use [ with quotes for portable scripts, [[ for bash-only
scripts (most of what we'll build here).
