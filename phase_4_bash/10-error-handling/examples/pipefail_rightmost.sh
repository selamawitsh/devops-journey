#!/bin/bash

echo "Pipeline where the LAST command also fails (grep finds nothing):"
set -o pipefail
ls /this/does/not/exist | grep "txt"
echo "Exit code: $? (this is grep's failure, not ls's - both failed, grep is rightmost)"

echo ""
echo "Pipeline where the LAST command succeeds regardless (wc -l):"
ls /this/does/not/exist | wc -l
echo "Exit code: $? (pipefail correctly surfaces ls's failure here since wc never fails)"
