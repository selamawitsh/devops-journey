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
