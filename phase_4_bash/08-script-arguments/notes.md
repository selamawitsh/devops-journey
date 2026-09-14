# Notes — Script Arguments

## $0, $1-$9, $#
$0   the exact text used to invoke the script (./script.sh, script.sh, or a
     full path — not a cleaned-up name)
$1.. positional arguments, in order
$#   count of arguments passed

Extra arguments beyond what the script explicitly references ($3 when the
script only echoes $1/$2) are NOT dropped by Bash — $# still counts them.
The script just never looked at them. Bash doesn't validate argument count
for you; the script must check $# itself if it needs to.

## $@ vs $*
Unquoted $@ and unquoted $* behave IDENTICALLY — both go through normal
word-splitting, so an argument containing a space ("New York") gets broken
into separate words (New, York). Quoting is what matters, not which symbol.

"$@"  -> each original argument preserved as its own separate string,
          exactly as passed in (spaces and all)
"$*"  -> all arguments joined into ONE single string, space-separated

Rule: use "$@" (always quoted) any time a script needs to forward its own
arguments to another command, e.g. a wrapper script around kubectl/docker/git:
  kubectl "$@"
Unquoted $@ here would mangle any argument value containing a space before
the wrapped command ever sees it.

## shift
shift moves every positional argument down by one: $2 becomes $1, $3
becomes $2, etc, and decreases $# by one each call.

  while [[ $# -gt 0 ]]; do
      echo "Processing: $1"
      shift
  done

This is the building block for scripts that accept an unknown number of
items (e.g. ./backup.sh file1.txt file2.txt file3.txt ...) — no need to
know the count in advance, just process $1 and shift until none remain.

## getopts
Parses proper flag-style arguments (-e value, -v).

  while getopts "e:v" opt; do
      case "$opt" in
          e) echo "Value: $OPTARG" ;;
          v) echo "Verbose on" ;;
          *) echo "Usage: $0 [-e value] [-v]"; exit 1 ;;
      esac
  done

In the option string "e:v" — a colon after a letter means that flag REQUIRES
a value, which lands in $OPTARG. No colon means it's a boolean switch.
getopts automatically rejects unrecognized flags itself ("illegal option"),
and routes them into the case statement's *) branch too — the same
defensive catch-all pattern from Session 6. This is how most real CLI tools
parse their flags.
