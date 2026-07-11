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
ssh -L 5433:localhost:5432 youruser@dbhost

```
**Which direction is this — local or remote forwarding? Why?**
```
You are reaching through dbhost to touch something dbhost can see on its own localhost,
that you otherwise couldn't reach.
```

---

## Question 2
Your teammate's website runs on `localhost:3000` on their own laptop.
They want to expose it as port `8080` on a server called
`public-server` (which has a real public IP), so a client anywhere
can access it temporarily.

**Command:**
```
 ssh -R 8080:localhost:3000 user@public-server

```
**Which direction is this — local or remote forwarding? Why?**
```
This is remote forwarding (-R). public-server opens
port 8080 on itself; anything that connects there gets tunneled back to
the teammate's laptop on port 3000.
```

---

## Question 3
Explain the directional difference between `-L` and `-R` without using
the words "local" or "remote" in your explanation — describe it purely
in terms of which machine ends up being reachable from which.

**My explanation:**
```
-L:

You run the SSH command from your machine.
You connect to another machine.
That other machine can reach something (like a database on its own localhost).
After you use -L, your machine can now reach that same thing too.

-R:

You run the SSH command from your machine.
You connect to another machine.
Your machine can reach something (like a website running on your own laptop).
After you use -R, that other machine can now reach that same thing too.

One line each:

-L = the thing the other machine could already reach becomes reachable by you too.
-R = the thing you could already reach becomes reachable by the other machine too.
```

---

## Question 4
You SSH with `-X` into a server to use a GUI tool, but the graphical
window never appears. List two specific configuration things you
would check first, and where you'd check them.

**Check 1 — server side, /etc/ssh/sshd_config**
Confirm the line "X11Forwarding yes" is present and not commented out.
If you change it, you must restart sshd (sudo systemctl restart sshd)
for it to take effect. Also run "which xauth" on the server — if xauth
isn't installed, X11 forwarding fails even with the config line correct,
usually with no useful error.

**Check 2 — client side, after connecting**
Run ssh -X user@host, then once inside, run: echo $DISPLAY
If it's empty, the forwarding never actually negotiated — check
"ssh -v" output for an xauth-related warning. If DISPLAY IS set but the
window still doesn't appear, the problem has moved: you need a real X
server running on your end to receive it. On plain Linux at a desktop
session this is automatic. On WSL you need VcXsrv or X410 running first.
On macOS you need XQuartz open first.

---

## Question 5
Why would a company prefer SSH tunneling to reach an internal database
over just opening that database's port directly in the firewall? Give
a real security reasoning, not just "it's more secure."

**My explanation:**
```
Guess your password over and over (a brute-force attack)
Attack a known bug in the database software itself — this can work even before they get a password right

If you use an SSH tunnel instead:
The database port is never open to the internet at all. The only way to reach it is through SSH first. So instead of having two doors to guard (SSH and the database), you only have one — SSH — and that's usually the one you already lock down the hardest (keys instead of passwords, limited login attempts, and so on).
```
