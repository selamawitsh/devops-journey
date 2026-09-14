# Notes — Functions and Scope

## Defining and calling
greet() {
    echo "Hello"
}
greet

function greet2 {
    echo "Hello"
}
greet2

Both styles work identically. No hoisting: Bash executes top to bottom, so
a function must be DEFINED before the line that calls it, or it fails with
"command not found" — same error as running any undefined command.

## Function arguments
deploy() {
    echo "$1"       # first argument passed TO THIS FUNCTION CALL
    echo "$#"        # count of arguments passed to this function call
}
deploy "web01" "production"

A function's $1, $2, $# are its own, based on what was passed when it was
called — NOT automatically the script's own $1/$2. Calling a function with
no arguments doesn't error; $1 is just an empty string and $# is 0 — a
function that assumes arguments were provided without checking will run
silently with blank values instead of failing clearly.

## local and scope
Without local: a variable assigned inside a function overwrites a global
variable of the same name directly. This is the OPPOSITE of most languages
(Python, JS, Go all default to local scope in a function) and is a real
trap.

local name="value"   inside a function creates a variable that exists ONLY
inside that function call. Once the function returns, it's gone, and any
global variable of the same name is untouched.

Rule: use local for every variable that only needs to exist inside a
function. Real-world relevance: in a health-check script with many small
check_* functions, a missed local on a variable like "count" or "status"
can silently corrupt the global variable of the same name — the script
doesn't crash, it just produces a quietly wrong final report.

## return vs echo
return is EXCLUSIVELY for the function's exit code — 0-255 only, since an
exit code is a single byte. It is not a general value-return mechanism.
  add_numbers() { return $(( $1 + $2 )); }
  add_numbers 200 100; echo $?   -> 44, NOT 300 (300 mod 256 = 44, silent wrap)

echo is how a function hands back real data — capture it with command
substitution:
  add_numbers() { echo $(( $1 + $2 )); }
  result=$(add_numbers 200 100)   -> result is 300, correct

Combined real-world pattern (used in Project 2, the health checker):
  check_disk_space() {
      if [[ $1 -ge 90 ]]; then
          echo "CRITICAL: disk at ${1}%"
          return 1
      else
          echo "OK: disk at ${1}%"
          return 0
      fi
  }
  message=$(check_disk_space 95)
  status=$?
echo delivers the human-readable message, return delivers the pass/fail
signal — both used together, for different purposes.
