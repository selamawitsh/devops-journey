# 13 — Load Balancing

## Learning Objectives
By the end of this module you should be able to:
- Explain what problem load balancing solves
- Distinguish Layer 4 vs. Layer 7 load balancing
- Describe common balancing algorithms and what health checks are for
- Configure a DNS-based traffic-distribution setup in Packet Tracer, and understand where its simulation limits are

## Why This Matters
This module is the payoff for everything before it. An AWS ALB, an NLB, an nginx `upstream` block, a Kubernetes `Service` — they're all load balancers, differing mainly in *layer* (L4 vs L7) and *where they run*.

## A Straight Answer on Packet Tracer's Limits Here
Before the lab: **Packet Tracer has no dedicated load-balancer device, and its DNS server does not perform real round-robin rotation, least-connections balancing, or automated health-check-driven failover.** This is a genuine gap in the tool, not something to work around by pretending otherwise. What you *can* do in PT is configure multiple backend servers behind one hostname and manually observe what "directing traffic to a pool" and "removing a failed server" look like at a config level — useful for the concepts, but it will not show you real balancing *behavior*. If you want to actually see round-robin rotation and automatic health checks working live, that requires real tooling (nginx/HAProxy) — the previous version of this module's lab used exactly that, with Docker Compose, and is worth doing separately if you have Docker available.

## Core Concepts

### The problem load balancing solves
A single server can only handle so much traffic, and if it goes down, everything depending on it goes down too. A **load balancer** sits in front of multiple backend servers, spreading requests across them — improving both capacity and availability.

### Layer 4 vs. Layer 7
- **L4**: balances based on IP/port only, without looking at application data. Fast, protocol-agnostic. Example: AWS NLB.
- **L7**: understands HTTP — can route by URL path, inspect headers, terminate SSL. Example: nginx, HAProxy, AWS ALB.

### Balancing algorithms
| Algorithm | How it works |
|---|---|
| Round robin | Requests cycle evenly across backends, in order |
| Least connections | New request goes to the backend with the fewest active connections |
| IP hash | Client's IP determines which backend they always hit |
| Weighted | Like round robin, but some backends get more traffic than others |

### Health checks
A load balancer periodically probes each backend. If a backend fails enough checks in a row, it's automatically pulled out of rotation — no human needs to intervene. This is the mechanism that turns "a server crashed" into "nobody noticed."

---

## Lab Exercise (Packet Tracer — closest available approximation)

### Topology
```
[PC1]---[Switch]---[Router]---[Switch]---[Server1] (HTTP: "Hello from Server 1")
                                    |
                                [Server2] (HTTP: "Hello from Server 2")
                                    |
                                [DNS Server]
```

### Steps
1. **Build**: a Router, a client PC, two backend Servers each running HTTP with a distinct page (edit each server's `index.html` under Services → HTTP → the file editor, so you can visually tell them apart), and a DNS server (can be a third server, or reuse one of the backends).
2. **On the DNS server**, add two A records with the **same name** — `app.labs.local` — one pointing at Server1's IP, one at Server2's IP.
3. **Point PC1's DNS Server field** at the DNS server's IP.
4. **Request the page repeatedly**: from PC1's Web Browser, load `http://app.labs.local` several times and note which server actually responds each time. In most Packet Tracer versions this will consistently return the **same** record rather than rotating — that's the limitation described above, made concrete.
5. **Simulate manual failover** (the closest PT gets to a "health check"): power off or disconnect whichever server is currently being resolved to, then re-test — the request should now fail. Manually delete or edit that server's DNS record so `app.labs.local` points at the surviving server, and re-test to confirm access is restored.
6. **Write a short note** (`load-balancing-notes.md` in this folder) contrasting what you just did with what a real load balancer adds automatically: continuous health probing, sub-second automatic failover with no manual DNS edit, and genuine algorithmic distribution (round robin / least connections) rather than a fixed answer.

### Checkpoint Questions
1. What specifically did Packet Tracer fail to simulate here compared to a real load balancer?
2. Why is "a human manually editing a DNS record after noticing a server is down" a much weaker solution than an automated health check?
3. Which concepts from this module — algorithms, health checks, L4 vs L7 — genuinely require real tooling (nginx/HAProxy/a cloud LB) to observe hands-on rather than just configure?
4. If you have Docker available, what would you expect to see differently if you repeated this exercise with an actual nginx `upstream` pool instead of DNS A records?
