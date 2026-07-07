# Real-World DevOps Challenge — SSH Hardening

## No hints. No Google. No AI.

## Scenario
You are hardening a freshly provisioned production server before it
goes live. Security wants root login disabled and password auth
disabled entirely. You have exactly one admin user account so far.

---

## Question 1
What is the single most dangerous mistake you could make while doing
this hardening work, in what order would it happen, and how do you
avoid it completely?

**My explanation:**
```
the most dangerous mistake is disabling password auth before setting up key
the order should be 
1. Generate your key on your machine
2. Copy it to the server
3. Open a NEW terminal and confirm login works with NO password prompt
4. Only THEN disable root login
5. Only THEN disable password auth
```

---

## Question 2
Explain in your own words why disabling direct root SSH login improves
both security AND auditability — these are two separate benefits.
Give a concrete scenario for each.

**Security benefit + scenario:**
```
The security benefit is that root is a known username on every Linux server in the world. An attacker doesn't need to guess the username — they already know it. They only need to guess the password. Disabling root login means even if they guess the correct password, the server refuses them. They'd need to know a real named user account that exists on your specific server, which is much harder.
```
**Auditability benefit + scenario:**
```
a bot scans the internet, finds your server's open SSH port, and immediately starts trying root with thousands of common passwords. With PermitRootLogin no, every single attempt is refused before it even checks the password. Attack over.
```

---

## Question 3
Write the exact sshd_config line that would allow root to log in
ONLY with an SSH key, never with a password. Why might a team choose
this middle-ground option instead of fully disabling root login?

**PermitRootLogin without-password:**
```
This tells the server: root can log in, but only with an SSH key, never with a password.
Why would a team choose this instead of fully disabling root? Because some legacy automation tools or old scripts were written to run as root directly. Changing all of them to use a named user would take weeks of work. So the team compromises — they remove the password risk (brute force becomes impossible) while keeping root SSH access for the automation that needs it.

PermitRootLogin yes               # anyone can try root with password (dangerous)
PermitRootLogin without-password  # root allowed but only with a key (middle ground)
PermitRootLogin no                # root cannot SSH in at all (most secure)
```
**Reasoning:**
```
```

---

## Question 4
You open `/etc/ssh/sshd_config` and see this line:
```
#PubkeyAuthentication yes
```
The `#` makes it look "disabled." Is public key authentication
actually active or not on this server? Explain the rule you're
applying to answer this.

**My answer:**
```
The # means this line is not being read by the server. But the server still has a built-in default for PubkeyAuthentication — and that default is yes. So the feature is on, just being controlled by the default rather than by this line.
```

---

## Question 5
After changing `PasswordAuthentication` to `no` and reloading sshd,
a teammate without a configured SSH key tries to connect and it fails
instantly with no password prompt at all. Walk through, step by step,
why there's no fallback to a password prompt in this case — connect
this to how SSH normally tries multiple auth methods in sequence.

**My step-by-step explanation:**
```
The # means this line is not being read by the server. But the server still has a built-in default for PubkeyAuthentication — and that default is yes. So the feature is on, just being controlled by the default rather than by this line.


SSH client connects to server
         │
         ▼
Step 1: Try key-based auth
         │
         ├── key found and accepted? → logged in
         │
         └── no key? → move to next method
         │
         ▼
Step 2: Try password auth
         │
         ├── password correct? → logged in
         │
         └── wrong password? → refused

Now here's what happens when PasswordAuthentication no is set:

SSH client connects to server
         │
         ▼
Step 1: Try key-based auth
         │
         ├── key found and accepted? → logged in
         │
         └── no key? → move to next method
         │
         ▼
Step 2: Password auth — REMOVED. Does not exist.
         │
         └── connection refused immediately. No prompt.
```
