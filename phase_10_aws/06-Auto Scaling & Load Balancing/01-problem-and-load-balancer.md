# Session 06 (1/5): The Problem + Load Balancer Fundamentals

## Two distinct failure modes, one fix

"One server isn't enough" hides two separate problems:

1. **Availability failure** — the server crashes, an AZ has a bad day, an OS
   patch needs a reboot. With one server, any single failure takes 100% of
   traffic down with it.
2. **Capacity ceiling** — even a healthy server has a hardware limit.
   **Vertical scaling** (a bigger instance type) raises that ceiling, but
   there's always a biggest instance type available, resizing usually means a
   stop/start, and — the part people forget — a bigger single server is still
   a single point of failure. Vertical scaling does nothing for problem #1.

**Horizontal scaling** (more servers, not bigger ones) fixes both at once: no
hard ceiling, and no single point of failure.

## The gotcha horizontal scaling introduces: session state

More than one server means: which server does a user's *next* request land
on? If login sessions live in server memory, a user authenticated on server A
gets bounced to server B and appears logged out — B never saw that session.
Two real fixes: **sticky sessions** at the load balancer (pin a client to one
server by cookie — uneven load, breaks if that server dies), or
**externalize session state** to something every server can read, usually
Redis.

**JWT-based auth sidesteps this entirely.** A JWT carries the user's identity
in the signed token itself — any server verifies it independently against the
shared secret, nothing to look up, nothing tied to a specific instance. This
is why JWT is the standard choice for anything sitting behind a load
balancer.

## Load balancer — the "one stable address" detail

Without a load balancer, each server has its own IP. If it dies, users who
had that IP stranded have no way to be redirected. A load balancer gives one
DNS name that never changes while servers behind it come and go freely.

**Operational trap:** an ALB's underlying IP addresses can and do change over
time. Always point DNS at the load balancer's *name*, never a captured IP —
hardcoding the IP causes a mysterious outage whenever AWS rotates it.

## ALB vs NLB vs GWLB — the actual mechanism

- **ALB — Layer 7 (HTTP/HTTPS).** Reads the request: routes `/api` vs
  `/images` to different target groups, reads the `Host` header, terminates
  TLS. Parsing HTTP costs a small amount of latency.
- **NLB — Layer 4 (TCP).** Blind to packet contents, just forwards
  connections — this is exactly why it's extremely fast and handles millions
  of connections. Also offers a static IP per AZ, which ALB does not. Reach
  for NLB when you need a fixed IP (a partner firewall needs to allowlist
  you), you're balancing non-HTTP traffic (a game server, a database proxy),
  or you need the lowest possible latency at extreme scale.
- **GWLB** sits transparently in the path, routing traffic through security
  appliances (firewalls, intrusion detection) before it reaches your app — a
  networking/security concern more than an app-team one.

