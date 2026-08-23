# 10 — Ports & Firewalls

## Learning Objectives
By the end of this module you should be able to:
- Explain what a port is and how it lets one IP run many services
- Distinguish TCP vs UDP at a practical level
- Know common well-known ports on sight
- Understand stateful vs. stateless firewalls
- Write and test basic firewall rules with `ufw`/`iptables`

## Why This Matters
"Security groups" in AWS, "firewall rules" in GCP, and Kubernetes `NetworkPolicy` objects are all just friendlier front-ends over the exact concepts in this module. Once you can reason about ports and stateful filtering by hand, cloud security groups become obvious instead of magic.

## Core Concepts

### What a port actually is
An IP address gets traffic to the right *machine*. A **port** (0–65535) gets traffic to the right *application* on that machine. A connection is uniquely identified by the 4-tuple: `(source IP, source port, destination IP, destination port)` — that's how a server can handle thousands of simultaneous connections on the same port 443.

- **Well-known ports (0–1023)**: reserved for standard services — `22` SSH, `80` HTTP, `443` HTTPS, `53` DNS, `25` SMTP.
- **Registered ports (1024–49151)**: used by specific applications (e.g., `3306` MySQL, `5432` PostgreSQL).
- **Ephemeral ports (49152–65535)**: temporary, auto-assigned to the *client side* of a connection.

### TCP vs UDP
- **TCP**: connection-oriented, reliable, ordered. Involves a handshake (SYN, SYN-ACK, ACK) and retransmits lost data. Used for HTTP, SSH, databases — anything where correctness matters more than raw speed.
- **UDP**: connectionless, no delivery guarantee, no ordering. Lower overhead. Used for DNS queries, video/voice streaming, and anything latency-sensitive where a dropped packet is better than a delayed one.

### Stateless vs. stateful firewalls
- **Stateless**: evaluates every packet in isolation against a rule list. You must explicitly allow both the request *and* the reply traffic — clumsy and error-prone.
- **Stateful**: tracks active connections. If you allow an outbound request, the firewall automatically allows the matching inbound reply, without a separate rule. Almost all modern host firewalls (`iptables`/`ufw`/cloud security groups) are stateful.

### Default-deny principle
The security best practice: **deny everything by default, then explicitly allow only what's needed.** This is why a fresh cloud security group typically starts with zero inbound rules — you opt traffic *in*, not out.

## Key Commands Cheat Sheet
```bash
# ufw (simpler, wraps iptables)
sudo ufw status verbose
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw deny from 203.0.113.5
sudo ufw enable

# iptables (lower-level, more control)
sudo iptables -L -v -n
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -P INPUT DROP

# testing tools
nc -zv <host> <port>       # test if a port is open
curl -v telnet://<host>:<port>
```

---

## Lab Exercise (`firewall-rules.md`)

### Prerequisites
- A Linux VM or container you can freely lock yourself out of (don't do this on a machine you need SSH access to without a console/recovery option!)
- `ufw` installed (`sudo apt install ufw`)

### Steps
1. **Check current state**: `sudo ufw status verbose` — note it's likely inactive.
2. **Set default-deny policy**:
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```
3. **Allow only what you need**:
   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 80/tcp    # HTTP
   ```
4. **Enable the firewall**: `sudo ufw enable`, then confirm with `sudo ufw status numbered`.
5. **Test from another machine (or another terminal using localhost)**:
   ```bash
   nc -zv <target-ip> 22     # should succeed
   nc -zv <target-ip> 80     # should succeed
   nc -zv <target-ip> 3306   # should fail/timeout — not allowed
   ```
6. **Block a specific source**:
   ```bash
   sudo ufw deny from 203.0.113.5
   ```
   Test that traffic from that address is refused while others still work.
7. **Document your rule set** in `firewall-rules.md` — list each rule, the port/protocol, and *why* it exists. Treat this like a real change log; in production, undocumented firewall rules are a liability.
8. **Stretch — rate limiting**: `sudo ufw limit 22/tcp` throttles repeated connection attempts from the same IP, a basic defense against brute-force SSH attempts (you'll go deeper on SSH hardening in Module 12).

### Checkpoint Questions
1. Why does a stateful firewall let reply traffic through automatically, but a stateless one doesn't?
2. If you `ufw allow 80/tcp` but never opened `443/tcp`, what happens to HTTPS traffic?
3. What's the practical difference between "deny" and "reject" in a firewall rule (hint: does the sender get told, or does the connection just hang)?
4. Why is default-deny considered safer than default-allow, even though it's more setup work upfront?
