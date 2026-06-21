# Real-World DevOps Challenge — SSH Tunneling

## No hints. No Google. No AI.

## Scenario
Your company's PostgreSQL database server only accepts connections
from localhost for security — it is never exposed to the network
directly. You need to connect to it from your laptop using a local
GUI database tool. Separately, a teammate is demoing a website running
on their laptop and wants to share it temporarily with a client over
the internet, using a server that already has a public IP.

---

## Question 1
The database listens on `localhost:5432` on a server called `dbhost`.
Write the SSH command that lets you connect your LOCAL database tool
to `localhost:5433` on your own laptop, tunneling through to the real
database.

**Command:**
```
```
**Which direction is this — local or remote forwarding? Why?**
```
```

---

## Question 2
Your teammate's website runs on `localhost:3000` on their own laptop.
They want to expose it as port `8080` on a server called
`public-server` (which has a real public IP), so a client anywhere
can access it temporarily.

**Command:**
```
```
**Which direction is this — local or remote forwarding? Why?**
```
```

---

## Question 3
Explain the directional difference between `-L` and `-R` without using
the words "local" or "remote" in your explanation — describe it purely
in terms of which machine ends up being reachable from which.

**My explanation:**
```
```

---

## Question 4
You SSH with `-X` into a server to use a GUI tool, but the graphical
window never appears. List two specific configuration things you
would check first, and where you'd check them.

**Check 1:**
```
```
**Check 2:**
```
```

---

## Question 5
Why would a company prefer SSH tunneling to reach an internal database
over just opening that database's port directly in the firewall? Give
a real security reasoning, not just "it's more secure."

**My explanation:**
```
```
