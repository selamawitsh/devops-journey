# Notes — String Manipulation, Parameter Expansion, and Arrays

## Default value expansions
${var:-x}    use x if var is unset/empty, does NOT change var
${var:=x}    use x if var is unset/empty, AND assigns x to var permanently
${var:?msg}  error out with msg and STOP if var is unset/empty (script-ending guard)
${var:+x}    use x ONLY if var IS set; otherwise use nothing (ignores var's actual content)

Real use: ${ENVIRONMENT:-development} for a one-off fallback; ${API_KEY:?API_KEY must be set}
to hard-stop a script that cannot run without a required value, with a clear
custom error instead of a mysterious downstream failure.

## Prefix/suffix stripping
#   strip SHORTEST match from the FRONT
##  strip LONGEST match from the FRONT
%   strip SHORTEST match from the BACK
%%  strip LONGEST match from the BACK

path="/home/selamawit/backups/db_backup.tar.gz"
${path#*/}     -> home/selamawit/backups/db_backup.tar.gz   (shortest front match: just the leading /)
${path##*/}    -> db_backup.tar.gz                             (longest front match: everything through the last /, i.e. basename)
${path%/*}     -> /home/selamawit/backups                        (shortest back match: last / onward, i.e. dirname)
${path%%.*}    -> /home/selamawit/backups/db_backup                (longest back match: from the FIRST dot onward, strips .tar.gz)

${path##*/} and ${path%/*} replace basename/dirname as pure Bash, no
external process spawned — used constantly in real scripts processing
lists of file paths.

## String length
${#name}    number of characters in the variable's value

## Search and replace
${var/old/new}    replaces ONLY THE FIRST match
${var//old/new}    replaces EVERY match

Important: this single/double distinction means something DIFFERENT from
the #/## and %/%% pair (which is shortest/longest match). Here it's
first-occurrence vs all-occurrences. The lesson generalizes: don't assume
a symbol always means the same thing across different expansions — check
what it means for that specific one.

## Arrays
servers=("web01" "web02" "web03")
${servers[0]}       first element (zero-indexed)
${servers[@]}         every element
${#servers[@]}          count of elements (# means length here, same symbol
                          as string length, different meaning in this context)

servers+=("web04")        append without rebuilding the array

for i in "${!servers[@]}"; do ... done
                            "!" here means "give me the indexes, not the
                            values" — use when you need position, not just
                            value (numbering output, comparing neighbors)

## "${array[@]}" vs "${array[*]}"
Exactly the same rule as "$@" vs "$*" from Session 8, applied to arrays:

  servers=("web01" "web server two" "web03")

  "${servers[@]}"   -> each element preserved intact, even with internal
                        spaces: [web01] [web server two] [web03]
  "${servers[*]}"   -> all elements joined into ONE string:
                        [web01 web server two web03]

Rule: use quoted "${array[@]}" when looping over an array whose elements
might contain spaces — server names, file paths, anything from the real
world that isn't guaranteed to be one clean word.
