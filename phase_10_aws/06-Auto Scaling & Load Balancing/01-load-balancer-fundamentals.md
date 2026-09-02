# The Problem + Load Balancer Fundamentals

*Session 06 (1/5) — Linux/DevOps Curriculum*

Before load balancers make sense as a tool, it helps to be precise about *why* one server is never enough — it's actually two separate problems, not one.

---

## Table of Contents

1. [Two distinct failure modes, one fix](#1-two-distinct-failure-modes-one-fix)
2. [The gotcha horizontal scaling introduces: session state](#2-the-gotcha-horizontal-scaling-introduces-session-state)
3. [Load balancer — the "one stable address" detail](#3-load-balancer--the-one-stable-address-detail)
4. [ALB vs NLB vs GWLB — the actual mechanism](#4-alb-vs-nlb-vs-gwlb--the-actual-mechanism)

---

## 1. Two distinct failure modes, one fix

"One server isn't enough" is really hiding two separate problems:

### Problem 1: Availability failure

The server crashes. An AZ has a bad day. An OS patch needs a reboot. With only one server, **any single failure takes 100% of traffic down with it** — there's nothing behind it to catch the load.

### Problem 2: Capacity ceiling

Even a perfectly healthy server has a hardware limit. **Vertical scaling** (moving to a bigger instance type) raises that ceiling, but it comes with real limits:

- There's always a biggest instance type available — the ceiling still exists, just higher up
- Resizing usually means a stop/start, i.e. downtime
- **The part people forget:** a bigger single server is *still* a single point of failure. Vertical scaling does nothing at all for Problem 1.

### The fix: horizontal scaling

**Horizontal scaling** — more servers, not bigger ones — fixes both problems at once:

- No hard ceiling (add another server)
- No single point of failure (one server dying doesn't take everything down)

---

## 2. The gotcha horizontal scaling introduces: session state

Horizontal scaling isn't free — it introduces a new question: with more than one server, **which server does a user's *next* request land on?**

If login sessions live in a single server's memory, this breaks in a specific, confusing way: a user authenticated on **Server A** gets routed to **Server B** on their next request, and appears logged out — Server B never saw that session in the first place.

### Two real fixes

| Approach | How it works | Trade-off |
|---|---|---|
| **Sticky sessions** | The load balancer pins a client to one specific server, usually via a cookie | Uneven load across servers; breaks entirely if that one server dies |
| **Externalize session state** | Session data moves out of any single server's memory into something every server can read — usually **Redis** | Adds an extra moving piece (the shared store) to operate |

### The sidestep: JWT-based auth

**A JWT carries the user's identity inside the signed token itself.** Any server can verify it independently against the shared secret — there's nothing to look up, and nothing tied to a specific instance. No sticky sessions, no shared Redis store, no server-side session state at all.

This is exactly why **JWT is the standard choice for anything sitting behind a load balancer.**

---

## 3. Load balancer — the "one stable address" detail

Without a load balancer, each server has its own IP address. If that server dies, any user who had that IP is simply stranded — there's no mechanism to redirect them anywhere else.

A load balancer solves this by giving you **one DNS name that never changes**, while the individual servers behind it come and go freely — scaled up, scaled down, replaced, none of it visible to the client.

### Operational trap: never hardcode the IP

An ALB's underlying IP addresses **can and do change over time.** Always point DNS at the load balancer's *name*, never at a captured IP address. Hardcoding the IP works fine right up until AWS rotates it — at which point it becomes a mysterious, hard-to-diagnose outage.

---

## 4. ALB vs NLB vs GWLB — the actual mechanism

The three load balancer types operate at different layers of the network stack, and that layer is what determines what each one can (and can't) do.

### ALB — Layer 7 (HTTP/HTTPS) - Application Load Balancer

Reads the actual request content:

- Routes `/api` vs `/images` to different target groups
- Reads the `Host` header
- Terminates TLS

Because it's parsing HTTP, it costs a small amount of latency compared to the alternatives below — but that's exactly what buys the content-aware routing.

### NLB — Layer 4 (TCP) - Network Load Balancer

Blind to packet contents — it just forwards connections. That blindness is exactly why it's extremely fast and can handle millions of connections.

It also offers a **static IP per Availability Zone**, which ALB does not.

**Reach for NLB when:**
- You need a fixed IP (e.g. a partner's firewall needs to allowlist you)
- You're balancing non-HTTP traffic (a game server, a database proxy)
- You need the lowest possible latency at extreme scale

### GWLB — Gateway Load Balancer

Sits transparently in the traffic path, routing requests through security appliances — firewalls, intrusion detection systems — before they ever reach your application. This is more of a **networking/security team concern** than something an app team typically configures directly.

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **Availability failure** | Any single server dying takes all its traffic down — fixed by having more than one server |
| **Capacity ceiling** | A hardware limit vertical scaling only postpones, never removes, and never fixes the single-point-of-failure problem |
| **Horizontal scaling** | More servers, not bigger ones — solves both failure modes at once |
| **Session state problem** | Multiple servers means a user's next request may land somewhere that doesn't know them |
| **Sticky sessions** | Pin a client to one server via cookie — uneven load, fragile |
| **Externalized sessions (Redis)** | Shared session store all servers can read |
| **JWT** | Self-contained, signed identity — no session lookup needed anywhere, sidesteps the whole problem |
| **Load balancer** | One stable DNS name in front of servers that can change freely — never hardcode its IP |
| **ALB** | Layer 7 — content-aware routing, TLS termination, small latency cost |
| **NLB** | Layer 4 — blind to content, extremely fast, static IP per AZ, handles non-HTTP traffic |
| **GWLB** | Transparent routing through security appliances — a networking/security layer concern |
