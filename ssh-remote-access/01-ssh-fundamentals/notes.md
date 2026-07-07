# SSH Fundamentals

## The core problem SSH solves
Old remote login tools (telnet, rsh) sent everything — including
passwords — as plain text over the network. Anyone watching the
network traffic could read it. SSH (Secure Shell) encrypts the entire
session so a connection between two machines is private even over an
untrusted network.

## Public/private key theory (why two keys, not one)
Traditional encryption used ONE shared password — both sides need
the same secret, which means you have to somehow share that secret
safely first. That's the chicken-and-egg problem.

SSH (and GPG) solve this with key PAIRS:
- A private key — never leaves your machine, never shared
- A public key — freely given to anyone

The mathematical trick: something encrypted with one key can ONLY be
decrypted with the other key in the pair. So if I encrypt a message
using YOUR public key, only YOUR private key can open it — not even
mine. This is how secure communication happens without ever
transmitting a shared secret over the network.

Note (how SSH uses the pair): when using key-based SSH login, the *client*
keeps the private key and the *server* stores the public key in
`~/.ssh/authorized_keys`. During authentication the client proves it
holds the private key; the server only needs the public key to verify.

## Installing SSH
  sudo apt install openssh-server    # to host/accept connections
  sudo apt install openssh-client    # to connect out to other machines

## Basic connection
  ssh username@hostname
  ssh hostname                  # uses current local username
  ssh user@host command         # run one command, no interactive shell
  scp source user@host:/path    # secure copy a file to a remote machine

## Identifying who is logged in — the w command
  w                # shows logged in users, where from, idle time
  w --from         # explicitly shows the FROM column (IP/hostname)

Useful during an incident: "who is actually on this box right now,
from where, and how long have they been idle."

## SSH host keys — server identity verification
Every SSH server has its OWN key pair (separate from user keys).
When you connect for the first time, the server sends its PUBLIC key.
Your client saves it in:
  ~/.ssh/known_hosts          (per-user)
  /etc/ssh/ssh_known_hosts    (system-wide)

Next time you connect, ssh compares the key the server sends against
what's saved. If they MATCH — fine, proceed. If they DON'T match —
ssh assumes something is wrong (man-in-the-middle attack, or the
server was legitimately reinstalled) and warns you loudly.

## Verifying a host key fingerprint manually
  ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub

This lets you confirm a server's identity out-of-band (e.g. the admin
reads you the fingerprint over the phone) before you trust it blindly.

## StrictHostKeyChecking
Set in ~/.ssh/config or /etc/ssh/ssh_config:
  StrictHostKeyChecking yes

Forces ssh to ABORT the connection if the key doesn't match — instead
of just warning and letting you choose. Used in security-sensitive
environments where silent acceptance is too risky.

## When a server's key legitimately changes
If hardware fails and a server gets rebuilt, its key pair changes.
You must remove the OLD entry from known_hosts for that specific host
(not wipe the whole file) so ssh can record the new, correct key:
  ssh-keygen -R hostname        # safer than manually editing the file

## Why this matters in DevOps
You will SSH into servers constantly — for deployments, debugging,
log checking, emergency fixes. Understanding host key verification
means you won't blindly accept a connection that could be compromised,
and you'll know exactly what to do when a server is legitimately
rebuilt and its key changes.

## Prerequisites
- A recent `openssh-client` (usually present on developer machines).
- `openssh-server` on machines you expect to accept incoming SSH.
- `ssh-keygen`, `ssh-copy-id`, and a basic shell (bash/zsh).

## Quick ~/.ssh/config example
Use this to simplify common hosts and to control options per-host:

  Host prod-web
    HostName prod.example.com
    User deploy
    IdentityFile ~/.ssh/id_rsa_deploy
    StrictHostKeyChecking ask

## Handy commands
- Install your public key to a server (safe, automated):
  `ssh-copy-id user@host`
- Show public key fingerprints on the server:
  `ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key.pub`

## Troubleshooting
- Permissions: `~/.ssh` must be 700 and `~/.ssh/authorized_keys` usually 600.
- Firewall: ensure port 22 (or configured SSH port) is open on the server.
- Service: `systemctl status sshd` (or `ssh`) and check `/var/log/auth.log`.
- If a host key changed unexpectedly, don't accept it until you verify out-of-band.

## See also
- `man ssh`
- `man sshd_config`
- `man ssh-keygen`
