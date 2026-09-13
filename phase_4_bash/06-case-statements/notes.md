# Notes — Case Statements

## Basic structure
case "$variable" in
    pattern1)
        commands
        ;;
    pattern2)
        commands
        ;;
    *)
        default commands
        ;;
esac

Case checks the value against each pattern top to bottom and runs the first
match. ;; ends each branch. esac closes the whole statement (case spelled
backwards, same trick as if/fi).

## The *) catch-all
Same role as else in an if chain — matches anything not caught by an earlier
pattern. Real-world reason to always include it: the input often comes from
outside your control (a command-line argument, user input). Without *), an
unexpected value (a typo, an unsupported option) matches nothing and the
case statement silently does nothing — no output, no error, no clue
anything went wrong. With *), the user gets an immediate, clear message.

## Matching multiple values with |
y|Y|yes|Yes)
    echo "Proceeding..."
    ;;
One branch handles every acceptable spelling of the same intent. The
equivalent if/elif chain would need repeated || comparisons and gets
unreadable past two or three options.

## Glob patterns inside case
*.tar.gz)  echo "Compressed tarball archive" ;;
*.log)     echo "Log file" ;;
*.sh)      echo "Shell script" ;;
case doesn't require exact literal words — it accepts the same glob syntax
used in filename matching. Common real use: deciding how to handle a file
based on its extension in a backup or deployment script.

## Real-world connection
Most classic Linux service scripts (systemctl/init-style) are built around
exactly this pattern: case "$1" in start|stop|restart|status) ... esac.
The deployment helper project later in this phase uses this same mechanism.
