# Real-World DevOps Challenge — SSH Key-Based Authentication

## No hints. No Google. No AI.

## Scenario
You are setting up a CI/CD deployment user that needs to SSH into
production servers automatically, with no human present to type a
password or passphrase. You're also helping a teammate who is
confused about why their passphrase-protected key keeps prompting
them every single time, even though they thought they "fixed" that.

---

## Question 1
Generate a brand-new SSH key pair specifically for a deployment
automation user, saved as `~/.ssh/deploy_key`, with NO passphrase
(since no human will be present to type one during automated runs).
Then explain the real security tradeoff you just made.

**Command:**
```
ssh-keygen -t rsa -f ~/.ssh/deploy_key -N ""
```
**Security tradeoff explained:**
```
removing the passphrase means the file itself is the only protection. If it leaks, the attacker has immediate access no second factor to stop them.
```

---

## Question 2
Copy that public key to a remote server for user `deployer`.
What file on the REMOTE server actually receives this key, and what
does adding it there technically mean in terms of access?

**Command:**
```
ssh-copy-id -i ~/.ssh/deploy_key.pub deployer@remote server
```
**Which remote file gets modified:**
```
~/.ssh/authorized_keys in the deployer user's home directory. That file is a list of public keys that the server trusts. Being in that file means: "whoever proves they hold the matching private key gets in."
```

---

## Question 3
Your teammate has a passphrase-protected key. They ran `ssh-add` in
one terminal window successfully — no more prompts there. But in a
SECOND terminal window, doing the exact same ssh command, they're
asked for the passphrase again. They think ssh-agent is broken.
What is actually going on?

**My explanation:**
```
the new terminal doesn't have the SSH_AUTH_SOCK environment variable, so it can't find the agent's socket. Without that address, it doesn't know the agent exists.
```

---

## Question 4
Without running it for real, write the full sequence of commands
your teammate needs to run in that SECOND terminal to also avoid
being prompted, assuming the agent's environment variables aren't
automatically shared betwe
# Connect using that specific en terminals.

**Commands:**
```
# 1. Find the agent socket
ls /tmp/ssh-*/agent.*

# 2. Set the address in this terminal (use actual path from step 1)
export SSH_AUTH_SOCK=/tmp/ssh-ABcDeF123/agent.4521

# 3. Confirm the agent is reachable
ssh-add -l

# 4. Load the key only if step 3 showed "no identities"
ssh-add ~/.ssh/id_ed25519

# 5. Connect — no prompt now
ssh user@remoteserver
```

```
Is /tmp/ssh-*/agent.* there?
│
├── YES → export SSH_AUTH_SOCK=<that path>
│         ssh-add -l  (check if key is loaded)
│         └── not loaded? → ssh-add ~/.ssh/id_ed25519
│
└── NO  → eval "$(ssh-agent -s)"   ← starts it fresh
          ssh-add ~/.ssh/id_ed25519
```

---

## Question 5
Why would a security-conscious company REQUIRE passphrase-protected
keys for human engineers connecting interactively, but allow
passphrase-less keys for automated CI/CD service accounts? What is
the difference in risk between these two use cases?

**My explanation:**
```
If a human engineer loses their laptop, anyone who finds it can just use the private key to get into the company's servers  unless the key has a passphrase, because then the key file alone is useless without the password that only lives in the engineer's head. That's why companies require it for humans. But for CI/CD automation, nobody is sitting there at 3am typing a passphrase every time a deployment runs — if you required one, you'd have to write it down somewhere, which defeats the whole point. Plus the key isn't on some laptop that can get stolen, it's locked inside a secure secrets manager that never goes anywhere. So the risk is completely different — passphrase for humans because they carry stuff around and lose it, no passphrase for automation because the key never leaves a locked vault and there's nobody to type it anyway.
```
