#!/bin/bash
# Topic: vi Editor
# These are notes — vi must be practiced interactively

# Open vi and practice these steps manually:

# 1. Open a new file
#    vi /tmp/vi_practice.txt

# 2. Press 'i' to enter insert mode
# 3. Type some text:
#    Hello from vi
#    This is line two
#    DevOps engineer in training

# 4. Press Esc to go back to command mode
# 5. Type ':w' to save
# 6. Type 'dd' to delete current line
# 7. Type 'yy' to copy a line
# 8. Type 'p' to paste it
# 9. Type '/Hello' to search for Hello
# 10. Type ':wq' to save and quit

# Verify the file was saved
cat /tmp/vi_practice.txt 2>/dev/null || echo "file not created yet — practice vi interactively"

# Other useful vi commands to practice:
echo "---"
echo "Open vi with: vi /tmp/myconfig.conf"
echo "Remember: i = insert, Esc = command mode, :wq = save+quit, :q! = quit no save"
