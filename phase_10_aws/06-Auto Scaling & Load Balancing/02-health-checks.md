# Health Checks — Route to the Living

*Session 06 (2/5) — Linux/DevOps Curriculum*

Health checks sound like a single concept, but there are actually two separate self-healing layers involved — and mixing them up is where a real, common production gap comes from.

---

## Table of Contents

1. [Two separate self-healing layers, one signal](#1-two-separate-self-healing-layers-one-signal)
2. [Deregistration delay (connection draining)](#2-deregistration-delay-connection-draining)
3. [Health check path design is a real trade-off](#3-health-check-path-design-is-a-real-trade-off)
4. [The example setup from the slide, read correctly](#4-the-example-setup-from-the-slide-read-correctly)
5. [Interview line](#5-interview-line)
6. [Self-check](#6-self-check)

---

## 1. Two separate self-healing layers, one signal

### Load balancer health check — controls routing only

If a target fails the load balancer's health check, the LB simply **stops sending traffic to it.** That's the entire effect. It does not restart the instance, does not replace it, does not do anything beyond removing it from rotation.

### ASG health check — controls replacement

This is the layer people assume is watching the same thing, and it isn't — by default.

**By default, an Auto Scaling Group only watches EC2 status checks** — is the instance running at all — not the ALB's HTTP-level check.

Here's where that gap shows up in practice: an app that's **hung** — the process is alive, but its database connection is dead — still passes EC2 status checks, because from EC2's point of view, the instance is fine. So the ASG does nothing, **even though the load balancer has already pulled it from rotation.**

### The fix

Explicitly enable **ELB health checks** on the ASG, so it trusts the target group's HTTP check too — not just the EC2-level check.

Only once that's configured does a failed health check actually **trigger a replacement**, rather than just a routing change.

> Forgetting this is a real, common production gap. Without it, a broken instance doesn't get fixed — it just sits there forever, quietly "removed from rotation," while the ASG believes everything is fine.

---

## 2. Deregistration delay (connection draining)

When an instance leaves a target group — whether from a health check failure or an intentional scale-in — **in-flight requests get a grace period** to finish before the connection is force-closed. The default is **300 seconds**.

Without this grace period, scaling down or replacing an unhealthy instance would simply **drop requests mid-flight** — anyone with a request in progress against that instance loses it outright, with no chance to complete.

---

## 3. Health check path design is a real trade-off

There isn't a single "correct" health check design — it's a genuine trade-off between two failure modes.

### Shallow check

Something like `/` returning `200` as long as the process is up.

- **Misses real failures.** The app can be technically "up" — responding to the health check — while a dependency it actually needs, like its database connection, is dead. From the health check's point of view, everything looks fine.

### Deep check

Something like `/health` that actively verifies DB connectivity before responding.

- **Catches that failure** — but introduces a new risk: a temporary blip in the shared database now marks **every single instance** unhealthy at the same moment, since they all depend on the same DB.
- This turns a **partial problem** (one dependency having a bad moment) into a **total outage** (every instance simultaneously pulled from rotation).

**The trade-off in one line:** shallow checks under-detect real failures; deep checks over-react to shared-dependency blips by taking the whole fleet down at once.

---

## 4. The example setup from the slide, read correctly

Given this configuration:

- Check path: `/health`
- Interval: every 30 seconds
- Healthy threshold: 2 consecutive passes
- Unhealthy threshold: 2 consecutive fails

**What actually happens:** a crashed server is **pulled from rotation within about a minute** (two failed 30-second checks). That part is fully automatic and needs no ASG involvement at all — it's purely the load balancer's job.

**What doesn't happen automatically:** getting that instance actually **replaced**, not just removed from rotation. That still needs the ELB-health-check setting on the ASG described in Section 1 — without it, the instance stays pulled from rotation indefinitely, never replaced.

---

## 5. Interview line

> *"A load balancer health check only affects routing — failing it stops traffic, it doesn't fix anything. An Auto Scaling Group only replaces an instance if it's configured to trust that same health check via ELB health checks; otherwise it's watching EC2 status checks alone and won't notice an app that's hung but still running."*

---

## 6. Self-check

1. An instance's app is deadlocked but the EC2 instance itself is fine. The LB has stopped routing to it. Will the ASG replace it — under what condition?
2. Why does deregistration delay exist, and what would break without it?
3. What's the trade-off between a shallow health check and a deep one that verifies a database connection?

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **LB health check** | Controls routing only — fail it, and traffic stops, nothing gets fixed |
| **ASG health check (default)** | Watches EC2 status only — blind to app-level failures like a dead DB connection |
| **ELB health checks (ASG setting)** | Makes the ASG trust the target group's HTTP check too — required for actual replacement |
| **Deregistration delay** | Grace period (default 300s) for in-flight requests to finish before a connection is force-closed |
| **Shallow health check** | Fast, simple, but misses failures where a dependency is down while the process itself is up |
| **Deep health check** | Catches dependency failures, but risks a shared-dependency blip taking the whole fleet down at once |
