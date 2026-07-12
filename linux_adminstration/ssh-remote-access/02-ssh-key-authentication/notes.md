# SSH Key-Based Authentication (Passwordless Access)

## Why move away from passwords
Passwords can be guessed, phished, or brute-forced. A securely stored
private key is much harder to compromise. Key-based auth also enables
automation (scripts, CI/CD) to connect without a human typing anything.

## How it actually works
1. You generate a key PAIR on your client machine: private + public
2. You copy the PUBLIC key to the remote server (it's not secret)
3. When you connect, the server challenges your client using that
   public key
4. Only your matching PRIVATE key can answer correctly
5. If it answers correctly, you're authenticated — no password needed

## Generating a key pair
  ssh-keygen -t rsa
  ssh-keygen                      # same, rsa is often default
  ssh-keygen -f ~/.ssh/key2       # custom filename instead of id_rsa

You'll be asked for a PASSPHRASE (optional but recommended):
- No passphrase = pure convenience, but if someone steals the private
  key file, they can use it immediately, no extra barrier
- With passphrase = private key is encrypted at rest; even if stolen,
  it's useless without the passphrase too

## Copying your public key to a server
  ssh-copy-id user@remotehost
  ssh-copy-id -i ~/.ssh/key2.pub user@remotehost

This appends your public key into the remote user's
~/.ssh/authorized_keys file — that's literally the whole mechanism.

## Connecting with a specific key
  ssh -i ~/.ssh/key2 user@remotehost
  ssh -i ~/.ssh/key2 user@remotehost hostname    # one command, no shell

## The passphrase problem and ssh-agent
If your key has a passphrase, you'd normally have to type it every
single time you connect — annoying for someone connecting often.

ssh-agent solves this: it's a background program that holds your
decrypted key in memory for the duration of your login session.

  eval $(ssh-agent)         # start the agent, set env vars
  ssh-add ~/.ssh/key2       # unlock the key once, agent remembers it

After this, ssh connections using that key won't prompt for the
passphrase again — until you log out, which clears the agent's memory.

## Important — agent is per-session
If you open a NEW terminal/shell that didn't start the agent itself,
that new shell does NOT know about the cached key. You'll be prompted
for the passphrase again there, even though it "worked" in the first
terminal.

## Why this matters in DevOps
CI/CD pipelines, deployment scripts, and automation tools all rely on
key-based SSH auth — no human is typing a password during an automated
deploy. Understanding passphrase + agent tradeoffs is core to setting
this up securely instead of leaving unprotected keys lying around.
