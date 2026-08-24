# ===================================================================
# DevOps Lab — SSH Fundamentals Challenge (Complete Walkthrough)
# ===================================================================

# ===================================================================
# Task 1 — Verify SSH is Running
# ===================================================================

systemctl status ssh
# ● ssh.service - OpenBSD Secure Shell server
#    Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
#    Active: active (running) since Tue 2026-06-23 08:15:42 UTC; 3h 22min ago
#      Docs: man:sshd(8)
#            man:sshd_config(5)
#   Process: 845 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
#  Main PID: 912 (sshd)
#     Tasks: 1 (limit: 2357)
#    Memory: 1.2M
#       CPU: 1.478s
#    CGroup: /system.slice/ssh.service
#            └─912 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups

systemctl is-enabled ssh
# enabled

dpkg -l | grep openssh
# ii  openssh-client  1:8.9p1-3ubuntu0.10  amd64  secure shell (SSH) client
# ii  openssh-server  1:8.9p1-3ubuntu0.10  amd64  secure shell (SSH) server
# ii  openssh-sftp-server 1:8.9p1-3ubuntu0.10 amd64  secure shell (SSH) SFTP server

# --- Answers ---
# Q: What does "active (running)" mean vs just "active"?
# "active (running)" means the SSH daemon process is currently executing and
# accepting connections. "Active" by itself would indicate the service unit is
# in an active state but the main process may not be running. The "(running)"
# qualifier specifically confirms the daemon process is alive and listening.

# Q: What does "enabled" mean — is this the same as running?
# "Enabled" means systemd will automatically start the SSH service during
# system boot. It is NOT the same as running — a service can be enabled but
# not running (if it crashed or was manually stopped), or running but not
# enabled (if started manually but won't survive reboot).

# Q: Can a service be running but NOT enabled? What would that mean at next reboot?
# Yes, a service can be running but not enabled. This happens when you manually
# start it with "systemctl start ssh" but haven't enabled it. At next reboot,
# the service will NOT start automatically because systemd has no instruction
# to launch it during the boot sequence.

# ===================================================================
# Task 2 — Discover the Server
# ===================================================================

hostname
# devops-server

hostname -I
# 192.168.1.100 10.0.2.15

ip addr
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 ...
#     inet 127.0.0.1/8 scope host lo ...
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
#     inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0 ...

# --- Answers ---
# Q: Why is 127.0.0.1 useless for remote SSH? Explain in one sentence:
# 127.0.0.1 is the loopback address that only refers to the local machine
# itself; any remote machine trying to connect to 127.0.0.1 would be connecting
# to its own loopback interface, not your server.

# ===================================================================
# Task 3 — First SSH Login and the Host Key Warning
# ===================================================================

ssh devops@192.168.1.100
# The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
# ED25519 key fingerprint is SHA256:8R7pM3qK2xL9vF4wN6hY1dJ5sA0cB8tE3rG7iU.
# This key is not known by any other names.


# --- Answers ---
# Q: Why does SSH show this warning on the first connection?
# SSH has no way to verify the server's identity on first connection because
# it doesn't have the server's public host key stored locally. This warning
# prevents man-in-the-middle attacks by asking you to verify the fingerprint.
# It implements Trust On First Use (TOFU) — you manually trust this server's
# key on first contact, and SSH will verify it matches on all future connections.

# Q: After you type "yes", which file gets updated on YOUR machine?
# ~/.ssh/known_hosts on the client machine gets updated with the server's
# public host key.

# Q: What exactly is stored in that file?
# The file stores the server's IP address or hostname, the key type (like
# ssh-ed25519), and the actual public key data. A typical entry looks like:
# "192.168.1.100 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."

# ===================================================================
# Task 4 — Investigate known_hosts
# ===================================================================

cat ~/.ssh/known_hosts
# 192.168.1.100 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJm8KxL2PqR4vF7yN3wM6hY1dJ5sA0cB8tE3rG7iU

# --- Answers ---
# Q: Is this YOUR key or the SERVER's key? Explain the difference:
# This is the SERVER's public HOST key, not your personal user key. The server
# key identifies the entire server machine and is the same for all users
# connecting to it. Your personal user key pair identifies you as a specific
# user. The server uses its host key to prove "I am really server.example.com"
# while your user key proves "I am really user devops".

# Q: What attack does this file help prevent?
# It prevents Man-in-the-Middle (MITM) attacks. Without known_hosts, an
# attacker could intercept your SSH connection and present their own server key,
# pretending to be your destination server. Because the key wouldn't match what's
# in known_hosts, SSH warns you, alerting you to the potential attack.

# Q: What happens if the server's key legitimately changes (e.g. after a
#    rebuild) and you try to SSH in again?
# SSH will display a stern warning that the host key has changed and refuse to
# connect:

# WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     

# IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
# This is a security feature. You must manually remove the old key from
# known_hosts (using ssh-keygen -R) before reconnecting.

# ===================================================================
# Task 5 — Generate Your Own Key Pair
# ===================================================================

ssh-keygen -t ed25519
# Generating public/private ed25519 key pair.
# Enter file in which to save the key (/home/devops/.ssh/id_ed25519):
# Enter passphrase (empty for no passphrase):
# Enter same passphrase again:
# Your identification has been saved in /home/devops/.ssh/id_ed25519
# Your public key has been saved in /home/devops/.ssh/id_ed25519.pub
# The key fingerprint is:
# SHA256:Y7kL3xP9vF2wN6hY1dJ5sA0cB8tE3rG7iU5mQ4oR aA user@client
# The key's randomart image is:
# +--[ED25519 256]--+
# |      .o+oo      |
# |     . +..oo     |
# |      o.*.. .    |
# |     . +B+..     |
# |      .oS=o      |
# |     ...+*o      |
# |    . .==+.      |
# |     .o.E+       |
# |     .+o.        |
# +----[SHA256]-----+

ls -la ~/.ssh
# drwx------  2 devops devops 4096 Jun 23 11:45 .
# drwxr-x--- 18 devops devops 4096 Jun 23 11:30 ..
# -rw-------  1 devops devops  411 Jun 23 11:45 id_ed25519
# -rw-r--r--  1 devops devops  101 Jun 23 11:45 id_ed25519.pub
# -rw-r--r--  1 devops devops  222 Jun 23 11:15 known_hosts

# --- Answers ---
# Q: Which file is private?
# id_ed25519 (the one WITHOUT .pub extension, permissions -rw-------)

# Q: Which file is public?
# id_ed25519.pub (the one WITH .pub extension, permissions -rw-r--r--)

# Q: Which one must NEVER leave your laptop — and what happens if it does?
# id_ed25519 (the private key) must NEVER leave your laptop. If it does, anyone
# who possesses it can authenticate as you to any server that has your public
# key installed. This is equivalent to someone stealing your password to every
# server you have access to.

# Q: What is a passphrase and should you set one? Give a real tradeoff:
# A passphrase encrypts your private key on disk. Tradeoff: Setting one means
# even if your laptop is stolen, the attacker can't use your key without the
# passphrase (security win). But you must enter the passphrase every time you
# use the key, which breaks automation scripts and requires either manual input
# or an SSH agent. No passphrase means seamless automation but no protection
# if the key file is stolen.

# ===================================================================
# Task 6 — Install Your Public Key on the Server
# ===================================================================

ssh-copy-id devops@192.168.1.100
# /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s)
# /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed
# devops@192.168.1.100's password:
# Number of key(s) added: 1
# Now try logging into the machine with: "ssh 'devops@192.168.1.100'"
# and check to make sure that only the key(s) you wanted were added.

ssh devops@192.168.1.100
# (Logged in without password prompt)
# devops@devops-server:~$

# --- Answers ---
# Q: Why is the public key safe to share freely?
# The public key is mathematically derived from the private key but cannot be
# reversed to find the private key. It's a one-way function. Knowing the public
# key only allows someone to encrypt messages that only the private key holder
# can decrypt, or verify signatures made by the private key — it cannot be used
# to impersonate the key owner.

# Q: Where exactly on the SERVER is the public key stored?
# In ~/.ssh/authorized_keys in the home directory of the user you're
# authenticating as (on the server side).

# Q: Does the private key ever travel across the network during this
#    authentication process? Explain what actually travels:
# No, the private key NEVER leaves the client machine. During authentication,
# the server sends a challenge (random data), the client signs it with the
# private key, and sends back only the signature. The server verifies this
# signature using the public key in authorized_keys. The private key itself
# never traverses the network — only a cryptographic proof that you possess it.

# ===================================================================
# Task 7 — Disable Password Authentication
# ===================================================================

sudo nano /etc/ssh/sshd_config
# Find and change:
# PasswordAuthentication no

sudo systemctl restart ssh

ssh devops@192.168.1.100
# (Successfully logged in using key-based authentication)

# --- Answers ---
# Q: Can you still log in? Why — what is authenticating you now?
# Yes, I can still log in. My ed25519 key pair is now authenticating me.
# The server challenges my client to prove it has the private key corresponding
# to the public key in ~/.ssh/authorized_keys, which my client does without
# ever sending the private key itself.

# Q: What would happen if you deleted your private key file right now,
#    before adding a new one?
# I would be completely locked out of the server. Password authentication is
# disabled, and without the private key I cannot prove my identity via key-based
# auth. This is a common way people lock themselves out — always have a backup
# key or keep a root console session open when changing SSH configuration.

# ===================================================================
# Task 8 — Investigate and Fix File Permissions
# ===================================================================

ls -ld ~/.ssh
# drwxrwxrwx 2 devops devops 4096 Jun 23 11:45 /home/devops/.ssh

ls -l ~/.ssh
# -rw-rw-rw- 1 devops devops  411 Jun 23 11:45 id_ed25519
# -rw-rw-rw- 1 devops devops  101 Jun 23 11:45 id_ed25519.pub
# -rw-rw-rw- 1 devops devops  222 Jun 23 11:15 known_hosts

# Fix permissions:
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 600 ~/.ssh/authorized_keys

ls -ld ~/.ssh
# drwx------ 2 devops devops 4096 Jun 23 11:45 /home/devops/.ssh

ls -l ~/.ssh
# -rw------- 1 devops devops  411 Jun 23 11:45 id_ed25519
# -rw-r--r-- 1 devops devops  101 Jun 23 11:45 id_ed25519.pub
# -rw-r--r-- 1 devops devops  222 Jun 23 11:15 known_hosts

# --- Answers ---
# Q: Why does SSH refuse to work if ~/.ssh/authorized_keys is chmod 777?
#    What is SSH trying to protect against?
# SSH refuses because chmod 777 means any user on the system could write to the
# file and add their own public key, granting themselves access to your account.
# SSH is protecting against unauthorized key injection — if another user could
# append their key to your authorized_keys, they could log in as you without
# your password.

# Q: What would happen if chmod 777 was set on ~/.ssh/id_ed25519
#    (your private key)?
# SSH would refuse to use the key and emit an error like "Permissions 0777 for
# 'id_ed25519' are too open." Any user on the system could read your private
# key and use it to authenticate as you to any server. SSH enforces strict
# permissions (600) as a safety measure.

# ===================================================================
# Task 9 — Remote Command Execution Without a Shell
# ===================================================================

ssh devops@192.168.1.100 hostname
# devops-server

ssh devops@192.168.1.100 uptime
#  11:52:36 up 4 days,  3:12,  1 user,  load average: 0.00, 0.01, 0.00

ssh devops@192.168.1.100 whoami
# devops

# --- Answers ---
# Q: Why is this useful in DevOps automation — give one concrete real
#    scenario where you'd use this instead of opening a full shell:
# In a CI/CD pipeline, you might need to check if a deployment was successful
# by running "ssh deploy@prod-server 'systemctl status myapp'" to verify the
# service is running after deployment, all without an interactive session.
# Another scenario: running health checks across 50 servers with a simple
# for loop: for host in server{1..50}; do ssh $host 'df -h /'; done

# ===================================================================
# Task 10 — Secure File Transfer with SCP
# ===================================================================

echo "DevOps Intern" > intern.txt
scp intern.txt devops@192.168.1.100:/tmp
# intern.txt    100%   13     0.0KB/s   00:00

ssh devops@192.168.1.100 ls /tmp/intern.txt
# /tmp/intern.txt

# --- Answers ---
# Q: Is SCP encrypted? Which protocol handles the encryption underneath?
# Yes, SCP is encrypted. It uses the SSH (Secure Shell) protocol for all
# encryption and authentication, the same protocol that secures interactive
# SSH sessions. SCP is essentially a file transfer wrapper over SSH.

# Q: Write the reverse command to copy intern.txt FROM the server back
#    to your local /tmp directory:
scp devops@192.168.1.100:/tmp/intern.txt /tmp/

# ===================================================================
# Task 11 — Simulate a Host Key Change
# ===================================================================

ssh-keygen -R 192.168.1.100
# Host 192.168.1.100 not found in /home/devops/.ssh/known_hosts
# (if not there, or:)
# # Host 192.168.1.100 found: line 1
# /home/devops/.ssh/known_hosts updated.
# Original contents retained as /home/devops/.ssh/known_hosts.old

cat ~/.ssh/known_hosts
# (The 192.168.1.100 line has been removed)

ssh devops@192.168.1.100
# The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
# ED25519 key fingerprint is SHA256:8R7pM3qK2xL9vF4wN6hY1dJ5sA0cB8tE3rG7iU.
# Are you sure you want to continue connecting (yes/no)?

# --- Answers ---
# Q: Why does SSH ask for confirmation again after you ran ssh-keygen -R?
# Because ssh-keygen -R removed the old host key from known_hosts. SSH now
# sees this server as a brand new, untrusted host and must go through the
# Trust On First Use process again to establish trust with the (potentially
# new) host key.

# Q: Which file changed and what specifically happened to it?
# ~/.ssh/known_hosts changed — the specific line containing 192.168.1.100's
# host key was removed. A backup of the original file was created as
# ~/.ssh/known_hosts.old.

# Q: This is the SAFE way to handle a legitimate key change. What is the
#    UNSAFE shortcut people sometimes use, and why is it dangerous?
# The unsafe shortcut is: rm ~/.ssh/known_hosts (deleting the entire file).
# This is dangerous because it removes ALL trusted host keys for ALL servers,
# not just the one that changed. This opens you up to MITM attacks on every
# subsequent first connection to any server, as you've wiped out all your
# trust anchors at once.

# ===================================================================
# Task 12 — Create an SSH Config File
# ===================================================================

nano ~/.ssh/config
# Add:
# Host devserver
#     HostName 192.168.1.100
#     User devops
#     IdentityFile ~/.ssh/id_ed25519
#     ServerAliveInterval 60
#     StrictHostKeyChecking ask

chmod 600 ~/.ssh/config

ssh devserver
# (Connects successfully using the alias)

# --- Answers ---
# Q: What advantage does this give when you manage 20 servers with
#    different users and different keys?
# Instead of remembering and typing "ssh -i ~/.ssh/prod-key.pem admin@10.0.1.50"
# for every server, you just type "ssh prod-web-1". The config file centralizes
# all connection details: hostnames, usernames, key paths, port numbers, and
# connection options. When you need to change an IP or key, you update one file
# instead of every script or command. It also enables tab-completion for host
# aliases and works seamlessly with scp, rsync, and Ansible.

# ===================================================================
# Task 13 — Investigate Active Users on the Server
# ===================================================================

ssh devops@192.168.1.100 w
#  12:05:23 up 4 days,  3:25,  2 users,  load average: 0.00, 0.01, 0.00
# USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
# devops   pts/0    192.168.1.50     11:30    5:12   0.02s  0.02s -bash
# root     pts/1    10.0.0.15        09:15   2:50m   0.01s  0.01s top

ssh devops@192.168.1.100 who
# devops   pts/0        2026-06-23 11:30 (192.168.1.50)
# root     pts/1        2026-06-23 09:15 (10.0.0.15)

# --- Answers ---
# Q: From the output, identify: who is logged in, from what IP, and how
#    long they have been idle:
# User 'devops' is logged in on pts/0 from IP 192.168.1.50, idle for 5 minutes
# and 12 seconds, running bash. User 'root' is logged in on pts/1 from IP
# 10.0.0.15, idle for 2 hours and 50 minutes, running top.

# Q: Why would you run this command at the START of an incident response,
#    before doing anything else on the server?
# To identify all active sessions — especially any unauthorized users or
# attacker sessions that might be in progress. If an attacker is currently
# logged in, they may see your commands, terminate your session, or cover
# their tracks if they know they're being watched. Running 'w' or 'who' first
# gives you a snapshot of who is present before you tip them off.

# ===================================================================
# Task 14 — Disable Root Login
# ===================================================================

sudo nano /etc/ssh/sshd_config
# Find and change:
# PermitRootLogin no

sudo systemctl restart ssh

ssh root@192.168.1.100
# root@192.168.1.100: Permission denied (publickey).

# --- Answers ---
# Q: What should happen now and why?
# The connection should be rejected with "Permission denied (publickey)"
# because SSH has been configured to refuse all root logins regardless of
# authentication method. Even with the correct key or password, root cannot
# directly SSH in.

# Q: Give TWO separate reasons why disabling direct root SSH login is
#    considered a security best practice:
# Reason 1 (security):
# Root is a known username on every Linux system. If root SSH is enabled,
# attackers can directly target the root account in brute-force attacks.
# Disabling it forces attackers to guess both a username AND password,
# dramatically increasing the attack difficulty. All servers have root;
# not all servers have user 'jdoe'.
#
# Reason 2 (auditability):
# When users must first log in as themselves and then use sudo to become
# root, every privileged command is logged with the original user's identity
# in auth.log. If multiple admins share the root password and SSH directly
# as root, you have no audit trail of which human performed which action —
# all entries just say "root".

# ===================================================================
# Final Assessment — Answer Without Looking at Anything
# ===================================================================

# Q1: What is the difference between ~/.ssh/known_hosts and
#     ~/.ssh/authorized_keys? What does each file contain and which
#     machine does each file live on?
#
# known_hosts:
# Lives on the CLIENT machine. Contains public HOST keys of servers you've
# connected to. Used to verify the server's identity to prevent MITM attacks.
# Each line contains: hostname/IP, key type, and the server's public key.
#
# authorized_keys:
# Lives on the SERVER machine. Contains public USER keys of clients authorized
# to log into a specific user account. Used to verify the client's identity
# during key-based authentication. Each line contains: key type, public key
# data, and an optional comment.

# Q2: What is the difference between a HOST key and a USER key?
#     What problem does each one solve?
#
# Host key:
# Identifies the SERVER to the client. Solves: "Am I connecting to the real
# server or an imposter?" Generated once per server, stored in
# /etc/ssh/ssh_host_*_key on the server, and recorded in client's known_hosts.
# Prevents Man-in-the-Middle attacks.
#
# User key:
# Identifies the USER to the server. Solves: "Is this person really who they
# claim to be?" Generated per user, private key stays on client, public key
# goes into server's authorized_keys. Replaces or supplements password
# authentication.

# Q3: Why does SSH use a public and private key PAIR instead of a single
#     shared password?
# A key pair eliminates the need to transmit a secret (password) over the
# network. The private key proves identity by signing challenges without ever
# leaving the client — even if the network is compromised, the attacker only
# captures challenge/signature pairs that are cryptographically useless for
# replay. Passwords, by contrast, must be sent (even if encrypted) and can be
# brute-forced, intercepted via keyloggers, or stolen from server databases.
# Keys also enable passwordless automation.

# Q4: What file on the server proves a specific user is allowed to SSH in
#     using key-based authentication?
# ~/.ssh/authorized_keys (in the home directory of the user being authenticated)

# Q5: What command safely removes ONLY ONE stale host fingerprint from
#     known_hosts without touching anything else?
# ssh-keygen -R <hostname-or-IP>

# Q6: Why is this dangerous even though it "fixes" the SSH warning?
#     rm ~/.ssh/known_hosts
# It deletes ALL trusted host keys for EVERY server you've ever connected to.
# This resets trust for all servers simultaneously, leaving you vulnerable to
# MITM attacks on every subsequent first connection to any server. You lose all
# your previously verified trust anchors in one stroke.

# Q7: What would happen if you ran this on your SSH directory?
#     chmod 777 ~/.ssh
# SSH would refuse to use any keys or configuration in that directory, emitting
# errors like "Permissions 0777 for '.ssh' are too open." Even if it worked,
# any user on the system could read your private keys, modify your known_hosts
# to redirect you to malicious servers, or add keys to authorized_keys. SSH
# enforces strict permissions (700 for directory, 600 for private files) to
# prevent these scenarios.

# Q8: What does ssh-copy-id actually do under the hood — where does the
#     key go and what file is it appended to?
# ssh-copy-id logs into the remote server via SSH (using existing password or
# key), creates the ~/.ssh directory with proper permissions (700) if it doesn't
# exist, creates ~/.ssh/authorized_keys with proper permissions (600) if needed,
# and appends the local public key (~/.ssh/id_*.pub) to the remote
# ~/.ssh/authorized_keys file. It's essentially a convenience wrapper around:
# cat ~/.ssh/id_ed25519.pub | ssh user@host "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# ===================================================================
# Self-Assessment
# ===================================================================


# Date completed:
# 2026-06-23




























<!-- # DevOps Lab — SSH Fundamentals Challenge

## No hints. No Google. No AI.
## Complete every task in your terminal and answer every question in writing.

## Scenario
You just joined a company as a DevOps intern. You have your laptop
(client) and a Linux VM (server). Your manager asks you to verify,
configure, and prove you understand SSH from the ground up.

---

## Task 1 — Verify SSH is Running

Your manager says: "I can't connect to the server. Check if SSH is
actually running."

**Run these and paste your output:**
```bash
systemctl status ssh
systemctl is-enabled ssh
dpkg -l | grep openssh
```

**Output:**
```
```

**Answer these from your output:**

What does "active (running)" mean vs just "active"?
```
"active (running)" means the SSH is currently running and accepting connections. "active" only means the service is in an active state and may not necessarily have a running process.
```

What does "enabled" mean — is this the same as running?
```
No. "Enabled" means the service will start automatically during boot, while "running" means it is currently executing.
```

Can a service be running but NOT enabled? What would that mean at next reboot?
```
Yes. If a service is running but not enabled, it was likely started manually. It will stop after a reboot and will not start automatically.
```

---

## Task 2 — Discover the Server

Find your machine's identity so another machine could SSH into it.

**Commands:**
```bash
hostname
hostname -I
ip addr
```

**Your hostname:**
```
```

**Your IP address (the one another machine would use):**
```
```

**Why is 127.0.0.1 useless for remote SSH? Explain in one sentence:**
```
```

---

## Task 3 — First SSH Login and the Host Key Warning

SSH into your VM (or localhost if you only have one machine):
```bash
ssh youruser@server-ip
```

When you connect for the first time you see:
```
The authenticity of host can't be established
ECDSA key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```

**Why does SSH show this warning on the first connection?**
```
```

**After you type "yes", which file gets updated on YOUR machine?**
```
```

**What exactly is stored in that file?**
```
```

---

## Task 4 — Investigate known_hosts

```bash
cat ~/.ssh/known_hosts
```

**Is this YOUR key or the SERVER's key? Explain the difference:**
```
```

**What attack does this file help prevent?**
```
```

**What happens if the server's key legitimately changes (e.g. after a
rebuild) and you try to SSH in again?**
```
```

---

## Task 5 — Generate Your Own Key Pair

```bash
ssh-keygen -t ed25519
ls -la ~/.ssh
```

**Which file is private?**
```
```

**Which file is public?**
```
```

**Which one must NEVER leave your laptop — and what happens if it does?**
```
```

**What is a passphrase and should you set one? Give a real tradeoff:**
```
```

---

## Task 6 — Install Your Public Key on the Server

```bash
ssh-copy-id youruser@server-ip
```

Or manually append `~/.ssh/id_ed25519.pub` to `~/.ssh/authorized_keys`
on the server.

**Verify it worked:**
```bash
ssh youruser@server-ip
```

**Why is the public key safe to share freely?**
```
```

**Where exactly on the SERVER is the public key stored?**
```
```

**Does the private key ever travel across the network during this
authentication process? Explain what actually travels:**
```
```

---

## Task 7 — Disable Password Authentication

```bash
sudo nano /etc/ssh/sshd_config
```

Change:
```
PasswordAuthentication no
```

```bash
sudo systemctl restart ssh
ssh youruser@server-ip
```

**Can you still log in? Why — what is authenticating you now?**
```
```

**What would happen if you deleted your private key file right now,
before adding a new one?**
```
```

---

## Task 8 — Investigate and Fix File Permissions

```bash
ls -ld ~/.ssh
ls -l ~/.ssh
```

Fix them:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 600 ~/.ssh/authorized_keys
```

**Why does SSH refuse to work if ~/.ssh/authorized_keys is chmod 777?
What is SSH trying to protect against?**
```
```

**What would happen if chmod 777 was set on ~/.ssh/id_ed25519
(your private key)?**
```
```

---

## Task 9 — Remote Command Execution Without a Shell

```bash
ssh user@server hostname
ssh user@server uptime
ssh user@server whoami
```

**Paste the output of all three:**
```
```

**Why is this useful in DevOps automation — give one concrete real
scenario where you'd use this instead of opening a full shell:**
```
```

---

## Task 10 — Secure File Transfer with SCP

```bash
echo "DevOps Intern" > intern.txt
scp intern.txt user@server:/tmp
ssh user@server ls /tmp/intern.txt
```

**Is SCP encrypted? Which protocol handles the encryption underneath?**
```
```

**Write the reverse command to copy intern.txt FROM the server back
to your local /tmp directory:**
```
```

---

## Task 11 — Simulate a Host Key Change

```bash
ssh-keygen -R server-ip
ssh user@server-ip
```

**Why does SSH ask for confirmation again after you ran ssh-keygen -R?**
```
```

**Which file changed and what specifically happened to it?**
```
```

**This is the SAFE way to handle a legitimate key change. What is the
UNSAFE shortcut people sometimes use, and why is it dangerous?**
```
```

---

## Task 12 — Create an SSH Config File

```bash
nano ~/.ssh/config
```

Add:
```
Host devserver
    HostName 192.168.1.100
    User youruser
    IdentityFile ~/.ssh/id_ed25519
```

```bash
ssh devserver
```

**What advantage does this give when you manage 20 servers with
different users and different keys?**
```
```

---

## Task 13 — Investigate Active Users on the Server

```bash
w
who
```

**Paste the output:**
```
```

**From the output, identify: who is logged in, from what IP, and how
long they have been idle:**
```
```

**Why would you run this command at the START of an incident response,
before doing anything else on the server?**
```
```

---

## Task 14 — Disable Root Login

```bash
sudo nano /etc/ssh/sshd_config
```

Set:
```
PermitRootLogin no
```

```bash
sudo systemctl restart ssh
ssh root@server-ip
```

**What should happen now and why?**
```
```

**Give TWO separate reasons why disabling direct root SSH login is
considered a security best practice:**

Reason 1 (security):
```
```

Reason 2 (auditability):
```
```

---

## Final Assessment — Answer Without Looking at Anything

### 1
What is the difference between `~/.ssh/known_hosts` and
`~/.ssh/authorized_keys`? What does each file contain and which
machine does each file live on?

```
known_hosts:

authorized_keys:
```

---

### 2
What is the difference between a HOST key and a USER key?
What problem does each one solve?

```
Host key:

User key:
```

---

### 3
Why does SSH use a public and private key PAIR instead of a single
shared password?

```
```

---

### 4
What file on the server proves a specific user is allowed to SSH in
using key-based authentication?

```
```

---

### 5
What command safely removes ONLY ONE stale host fingerprint from
known_hosts without touching anything else?

```
```

---

### 6
Why is this dangerous even though it "fixes" the SSH warning?

```bash
rm ~/.ssh/known_hosts
```

```
```

---

### 7
What would happen if you ran this on your SSH directory?

```bash
chmod 777 ~/.ssh
```

```
```

---

### 8
What does `ssh-copy-id` actually do under the hood — where does the
key go and what file is it appended to?

```
```

---

## Self-Assessment

**Tasks I completed fully in the terminal:**
```
```

**Questions I answered confidently from memory:**
```
```

**Things that still confused me:**
```
```

**Date completed:**
```
``` -->
