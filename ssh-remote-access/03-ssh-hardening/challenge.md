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
```

---

## Question 2
Explain in your own words why disabling direct root SSH login improves
both security AND auditability — these are two separate benefits.
Give a concrete scenario for each.

**Security benefit + scenario:**
```
```
**Auditability benefit + scenario:**
```
```

---

## Question 3
Write the exact sshd_config line that would allow root to log in
ONLY with an SSH key, never with a password. Why might a team choose
this middle-ground option instead of fully disabling root login?

**Config line:**
```
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
```
