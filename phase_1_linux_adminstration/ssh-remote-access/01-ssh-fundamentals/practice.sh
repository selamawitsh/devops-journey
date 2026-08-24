#!/usr/bin/env bash
# Topic: SSH Fundamentals
# Safe, read-only checks and examples for learning. Many commands are
# commented out because they require another host or root privileges.

set -euo pipefail

# Helper: detect whether we can use systemctl name for sshd
check_sshd() {
	if systemctl status sshd >/dev/null 2>&1; then
		systemctl status sshd --no-pager
	elif systemctl status ssh >/dev/null 2>&1; then
		systemctl status ssh --no-pager
	else
		echo "systemd service 'sshd' or 'ssh' not found or requires sudo." >&2
	fi
}

# Basic information checks (safe to run)
echo "== SSH server status (may require sudo) =="
check_sshd || true

echo "\n== Who is logged in (local checks) =="
w || true
w --from || true

echo "\n== known_hosts and host key fingerprints =="
cat ~/.ssh/known_hosts 2>/dev/null || echo "no known_hosts yet"
ls /etc/ssh/*key.pub 2>/dev/null || true
ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub 2>/dev/null || true
ssh-keygen -l -f /etc/ssh/ssh_host_rsa_key.pub 2>/dev/null || true

# Example: install your public key onto a server (uncomment to use)
# ssh-copy-id user@host

# Example: run a single command on a remote host (uncomment to use)
# ssh user@host uptime

# Check ssh directory permissions (common troubleshooting)
if [ -d "$HOME/.ssh" ]; then
	echo "~/.ssh permissions:" && ls -ld "$HOME/.ssh"
	echo "authorized_keys permissions:" && ls -l "$HOME/.ssh/authorized_keys" 2>/dev/null || true
else
	echo "No ~/.ssh directory yet. Generate keys with: ssh-keygen -t ed25519" 
fi

echo "\nDone. Review the file and run only the lines you understand."

