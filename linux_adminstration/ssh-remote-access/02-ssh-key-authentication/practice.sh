#!/bin/bash
# Topic: SSH Key-Based Authentication

# Generate a passphrase-less key pair (practice only — not for real prod use)
ssh-keygen -t rsa -f ~/.ssh/practice_key -N ""

# Look at what got created
ls -la ~/.ssh/practice_key ~/.ssh/practice_key.pub

# View the public key content (safe to share/print)
cat ~/.ssh/practice_key.pub

# Copy public key to a remote host (adjust target — or localhost to test)
# ssh-copy-id -i ~/.ssh/practice_key.pub user@remotehost

# Connect using that specific key
# ssh -i ~/.ssh/practice_key user@remotehost hostname

# Generate a SECOND key pair, this time WITH a passphrase
ssh-keygen -t rsa -f ~/.ssh/practice_key_protected
# (enter a passphrase when prompted — try '654321' for practice)

# Start ssh-agent and add the protected key
eval $(ssh-agent)
ssh-add ~/.ssh/practice_key_protected
# (it will prompt for the passphrase ONCE here)

# Now connect — should NOT prompt for passphrase again this session
# ssh -i ~/.ssh/practice_key_protected user@remotehost hostname

# List keys currently loaded in the agent
ssh-add -l

# Clean up practice keys when done
rm -f ~/.ssh/practice_key ~/.ssh/practice_key.pub
rm -f ~/.ssh/practice_key_protected ~/.ssh/practice_key_protected.pub
echo "cleaned up practice keys"
