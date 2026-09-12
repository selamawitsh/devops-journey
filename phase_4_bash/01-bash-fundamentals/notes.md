# Notes — Bash Fundamentals

## Shell vs Bash
A shell sits between you and the kernel, turning what you type into system calls. Bash is one specific shell — the default on most Linux distros and servers.

Why it matters: scripts written assuming Bash-only features can silently break when run with sh or dash (common on minimal Docker base images like Alpine). Check which shell is actually running with `ps -p $$`, not `$SHELL` — the env var is just your login default and doesn't update if you switch shells mid-session.

## Running a script: two different mechanisms
- `./script.sh` — the kernel executes the file directly. Requires the execute bit (chmod +x) on that file. The kernel then reads the shebang to know which interpreter to hand the rest of the file to.
- `bash script.sh` — you're executing the bash binary itself (already has execute permission), and your script is just a text file being read line by line. Execute permission on the script is never required here, only read permission.

Real-world relevance: after a git clone, execute bits sometimes don't survive the transfer (especially from Windows checkouts). `bash deploy.sh` is the immediate workaround while chmod +x gets fixed properly.

## The shebang line
#!/bin/bash tells the kernel exactly which interpreter to use — but only when the file is executed directly. It's ignored when you run bash file.sh, since bash is already the interpreter.

#!/usr/bin/env bash is preferred in production code because it doesn't assume bash lives at /bin/bash. It searches PATH instead, so the same script works across systems where bash is installed somewhere else (some macOS/BSD setups, custom container images).

## echo
echo prints its arguments to stdout.
- echo "text" — prints with a trailing newline
- echo -n "text" — suppresses the trailing newline
- echo -e "line1\nline2" — enables interpretation of escape sequences like \n

Small builtin, but it's the first tool for logging output inside real scripts, before we build proper INFO/WARN/ERROR logging later in the automation-patterns topic.
