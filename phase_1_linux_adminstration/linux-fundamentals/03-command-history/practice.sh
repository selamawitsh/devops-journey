#!/bin/bash
# Topic: Command History
# Run these manually — observe what each shortcut does

# View your full history
history

# View last 10 commands only
history 10

# Run these commands to build up some history to practice with
pwd
hostname
date -I
ls -la ~
id
cal

# Press Up arrow — scroll back through what you just ran
# Press Ctrl+R then type "date" — find the date command in history
# Type !! — this repeats your very last command
# Type !ls — this repeats the most recent ls command
# Type !cal — repeats most recent cal command
# Press Esc+. — pastes the last argument from previous command
# Press Ctrl+A on a typed command — jumps to beginning
# Press Ctrl+E — jumps to end
