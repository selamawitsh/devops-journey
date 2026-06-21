#!/bin/bash
# Topic: SSH Fundamentals
# Some of these require a second machine or VM to actually connect to.
# If you only have one machine, you can SSH to yourself: ssh localhost

# Check if SSH server is installed and running
systemctl status sshd

# Connect to yourself as a quick test (uses current username)
# ssh localhost

# Connect specifying a different user
# ssh someuser@localhost

# Run a single remote command without an interactive shell
# ssh localhost hostname

# See who is currently logged in (works locally too)
w
w --from

# Look at your known_hosts file (may not exist yet if you've never SSH'd out)
cat ~/.ssh/known_hosts 2>/dev/null || echo "no known_hosts yet"

# Look at the server's own host key fingerprints
ls /etc/ssh/*key.pub
ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub 2>/dev/null
ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub 2>/dev/null

# If you ever need to remove a single host's old key (safer than editing manually)
# ssh-keygen -R hostname

# Practice scp — copy a file to a remote machine (adjust target)
# echo "test file" > /tmp/testfile.txt
# scp /tmp/testfile.txt user@remotehost:/tmp/
