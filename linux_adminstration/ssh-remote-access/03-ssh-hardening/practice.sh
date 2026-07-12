#!/bin/bash
# Topic: SSH Hardening
# WARNING: practice this on a VM or test machine, NOT a server you only
# have one way into. If you disable both password auth AND haven't
# confirmed key auth works first, you can lock yourself out completely.

# Step 1 — confirm key auth works BEFORE touching anything else
# ssh-keygen -t rsa
# ssh-copy-id youruser@remotehost
# ssh youruser@remotehost hostname    # should NOT ask for a password

# Step 2 — view current sshd_config settings
sudo grep -E '^PermitRootLogin|^PasswordAuthentication|^PubkeyAuthentication' /etc/ssh/sshd_config
echo "---"
echo "if these lines are commented out (#) they are using system defaults"
grep -E '^#?PermitRootLogin|^#?PasswordAuthentication|^#?PubkeyAuthentication' /etc/ssh/sshd_config

# Step 3 — disable direct root login
# sudo vi /etc/ssh/sshd_config
# change: PermitRootLogin no
sudo systemctl reload sshd
echo "reloaded sshd after disabling root login"

# Step 4 — test that root login now fails
# ssh root@remotehost     # should be refused

# Step 5 — disable password authentication entirely
# sudo vi /etc/ssh/sshd_config
# change: PasswordAuthentication no
sudo systemctl reload sshd
echo "reloaded sshd after disabling password auth"

# Step 6 — test both scenarios
# ssh keyuser@remotehost          # should still work — has a key configured
# ssh nokeyuser@remotehost        # should fail — no key, and passwords are off now

# Step 7 — verify final state
sudo grep -E '^PermitRootLogin|^PasswordAuthentication' /etc/ssh/sshd_config
