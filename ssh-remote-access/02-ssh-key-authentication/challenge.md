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
```
**Security tradeoff explained:**
```
```

---

## Question 2
Copy that public key to a remote server for user `deployer`.
What file on the REMOTE server actually receives this key, and what
does adding it there technically mean in terms of access?

**Command:**
```
```
**Which remote file gets modified:**
```
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
```

---

## Question 4
Without running it for real, write the full sequence of commands
your teammate needs to run in that SECOND terminal to also avoid
being prompted, assuming the agent's environment variables aren't
automatically shared between terminals.

**Commands:**
```
```

---

## Question 5
Why would a security-conscious company REQUIRE passphrase-protected
keys for human engineers connecting interactively, but allow
passphrase-less keys for automated CI/CD service accounts? What is
the difference in risk between these two use cases?

**My explanation:**
```
```
