# Notes — Control Flow

## if / elif / else
Bash checks conditions top to bottom and runs the FIRST one that's true,
then stops — it never checks the remaining elif/else branches after a match.
else has no condition; it's the catch-all when nothing above matched.

## Numeric vs string comparison
Numeric:  -eq -ne -gt -ge -lt -le   (compares as numbers)
String:   ==  !=  -z   -n            (compares as text)

-z tests "is this string empty"
-n tests "is this string non-empty"

These are NOT interchangeable. "5" == "5" and 5 -eq 5 look similar but
compare differently — matters especially for version-like strings
("1.10" vs "1.9") where string comparison sorts them lexically instead of
numerically.

## File tests
-f   regular file
-d   directory
-e   exists (file or directory)
-r   readable
-w   writable
-x   executable

Real-world use: gate any file/directory operation on these instead of
letting the script fail partway through. Example: checking a backup
directory exists before writing to it, creating it with mkdir -p if not.

## Combining conditions
[[ CONDITION1 && CONDITION2 ]]   both must be true
[[ CONDITION1 || CONDITION2 ]]   at least one must be true
Lets you check multiple things in one condition instead of nesting ifs.
