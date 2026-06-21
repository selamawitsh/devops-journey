# Real-World DevOps Challenge — SSH Fundamentals

## No hints. No Google. No AI.

## Scenario
You are on call. A teammate says "someone weird connected to
prod-server-03, can you check?" You also need to onboard a new
contractor who will connect to a server for the first time, and later
that same server gets rebuilt after a disk failure.

---

## Question 1
You SSH into a server. Without running any extra monitoring tools,
how do you see exactly who else is logged in right now, and from
which IP address?

**Command:**
```
```

---

## Question 2
A brand-new contractor connects to a server for the very first time.
What message does SSH show them, and what choice are they making
when they type "yes"? Where does that information get permanently
stored after they accept?

**My explanation:**
```
```

---

## Question 3
Three months later, that same server's hard drive fails and it gets
rebuilt from scratch. The contractor tries to SSH in again and gets a
big scary warning instead of a normal prompt. What is SSH actually
warning them about, and is it definitely an attack?

**My explanation:**
```
```
**What is the SAFE next step to take (not the dangerous shortcut)?**
```
```

---

## Question 4
What is the correct, surgical command to remove just ONE specific
host's old key from known_hosts, without wiping out every other
saved host you've ever connected to?

**Command:**
```
```
**Why is this better than deleting the whole known_hosts file?**
```
```

---

## Question 5
Explain in your own words why SSH needs TWO different key concepts
in play during a connection: the SERVER's host key, and (later) the
USER's own key pair for authentication. What problem does each one
solve, and are they the same thing?

**My explanation:**
```
```
