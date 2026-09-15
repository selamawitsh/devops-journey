# Notes — String Manipulation, Parameter Expansion, and Arrays

## Parameter expansion overview

    $variable          simple value substitution
    ${variable}          same thing, just explicit braces
    ${variable ...}         braces unlock MANIPULATION of the value:
                              length, defaults, stripping, replacing

Instead of piping out to an external tool (wc, sed, basename, cut), Bash
can transform the string directly, inside the shell itself — no extra
process spawned. That's the whole point of parameter expansion.

## Default value expansions

    ${var:-x}    use x if var is unset/empty  -> does NOT change var
    ${var:=x}    use x if var is unset/empty  -> ALSO assigns x to var
    ${var:?msg}  ERROR + STOP the script if var is unset/empty
    ${var:+x}    use x ONLY if var IS set     -> ignores var's real content

Visual:

    var unset or empty?
           |
      +----+----+
      |         |
     YES        NO
      |         |
      |    (:-  -> prints var itself, unchanged)
      |    (:=  -> prints var itself, unchanged)
      |    (:?  -> prints var itself, unchanged)
      |    (:+  -> prints the replacement x)
      |
      +-- :-   print x, var stays empty/unset
      +-- :=   print x, AND var is now permanently set to x
      +-- :?   print msg to stderr, STOP the script, non-zero exit
      +-- :+   print nothing (x only applies when var IS set)

A subtlety worth knowing: the colon is what makes these check for BOTH
"unset" and "empty string". Drop the colon - ${var-x} instead of
${var:-x} - and the check becomes "unset ONLY". A variable that was
explicitly set to "" (empty) would NOT trigger ${var-x}'s fallback, only
${var:-x}'s. In practice, :- (with the colon) is what you want almost all
the time, since an intentionally-empty variable and a never-set variable
usually should be treated the same way.

Real use case: ${ENVIRONMENT:-development} for a one-off fallback that
doesn't need to stick. ${API_KEY:?API_KEY must be set before running this
script} to hard-stop a script that cannot function without a required
value, with a clear custom error instead of a confusing failure three
steps later.

## Arrays

    servers=("web01" "web02" "web03")

              index    value
                0       web01
                1       web02
                2       web03

    ${servers[0]}        first element (zero-indexed)
    ${servers[@]}          every element
    ${#servers[@]}            count of elements
    ${#servers[0]}              length of just element 0 (character count,
                                  NOT element count — same # symbol, context
                                  changes the meaning again)

    servers+=("web04")            append without rebuilding the array

    for i in "${!servers[@]}"; do ... done
                                     "!" here means "give me the INDEXES,
                                     not the values" — use when you need
                                     position, not just value

## "${array[@]}" vs "${array[*]}"

Exactly the "$@" vs "$*" rule from Session 8, applied to arrays:

    servers=("web01" "web server two" "web03")

    "${servers[@]}"  ->  [web01]  [web server two]  [web03]
                          each element preserved intact, spaces included

    "${servers[*]}"  ->  [web01 web server two web03]
                          all elements joined into ONE string

Rule: use quoted "${array[@]}" whenever looping over an array whose
elements might contain spaces — server names, file paths, anything from
the real world that isn't guaranteed to be one clean word.

## Session 11 mental model

                     Bash variable
                           |
              +------------+------------+
              |                         |
          one value                 many values
              |                         |
      parameter expansion             array
              |                         |
        +-----+-----+             +-----+-----+
        |     |     |             |     |     |
     length default strip       access loop  count
        |     |     |
        |     |     +-- ${var#x} ${var##x} ${var%x} ${var%%x}
        |     +-------- ${var:-x} ${var:=x} ${var:?x} ${var:+x}
        +-------------- ${#var}

    DevOps connection:

    parameter expansion -> clean filenames, clean paths, defaults,
                            configuration, environment variables
    arrays               -> lists of servers, services, files, ports,
                            checks -> the health checker and deployment
                            helper projects are built on this

## Cheat sheet — Session 11

    Defaults
      ${var:-x}    unset/empty -> x (var unchanged)
      ${var:=x}    unset/empty -> x (var now SET to x)
      ${var:?msg}  unset/empty -> error + stop script
      ${var:+x}    IS set -> x, otherwise nothing

    Strip prefix (front)
      ${var#pattern}     shortest match
      ${var##pattern}    longest match

    Strip suffix (back)
      ${var%pattern}     shortest match
      ${var%%pattern}    longest match

    Length
      ${#var}            characters in var
      ${#array[@]}        elements in array

    Replace
      ${var/old/new}      first match only
      ${var//old/new}     all matches

    Arrays
      arr=("a" "b" "c")    declare
      ${arr[0]}              access by index (zero-based)
      "${arr[@]}"              loop-safe, preserves spaces
      "${arr[*]}"                joins into one string
      arr+=("d")                    append
      "${!arr[@]}"                    loop over indexes, not values
