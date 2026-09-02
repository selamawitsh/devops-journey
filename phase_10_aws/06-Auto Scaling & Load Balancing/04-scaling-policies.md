# Scaling Policies + The Full Picture

*Session 06 (4/5) — Linux/DevOps Curriculum*

Three different scaling policies exist because they solve three different shapes of demand: smooth and continuous, sudden and uneven, or known in advance. This session ties them together, then walks the full causal chain end to end.

---

## Table of Contents

1. [Target tracking — a control loop, not magic](#1-target-tracking--a-control-loop-not-magic)
2. [Step scaling — control target tracking hides](#2-step-scaling--control-target-tracking-hides)
3. [Scheduled scaling — the only policy that acts ahead of demand](#3-scheduled-scaling--the-only-policy-that-acts-ahead-of-demand)
4. [The full causal chain, start to finish](#4-the-full-causal-chain-start-to-finish)
5. [Zero-downtime deploys use the same machinery differently](#5-zero-downtime-deploys-use-the-same-machinery-differently)
6. [Real-world shape](#6-real-world-shape)
7. [Interview line](#7-interview-line)
8. [Self-check](#8-self-check)

---

## 1. Target tracking — a control loop, not magic

Pick a target — say, CPU at 50% — and AWS creates CloudWatch alarms behind the scenes, then continuously adjusts desired capacity to converge on that number. Mathematically, this is a **thermostat**: it doesn't jump straight to a guess, it keeps nudging capacity until the metric settles at the target.

This is exactly why it's the default policy — **you describe the outcome you want, not the mechanism for getting there.**

### When it misbehaves, it's usually the metric, not the policy

CPU can stay low while a service is actually **memory-bound or I/O-bound** — genuinely struggling, but never showing it on the one metric being watched. Scaling never triggers, because the metric that would trigger it was never the bottleneck in the first place.

**Real fix:** scale on **request count per target**, or a **custom CloudWatch metric** that actually reflects load for that specific workload. CPU is a reasonable default, not a universal one.

---

## 2. Step scaling — control target tracking hides

Target tracking gives you one smooth response curve toward a target. **Step scaling** trades that smoothness for explicit control over response size at different thresholds:

- CPU over 70% → add 2 instances
- CPU over 90% → add 4 instances
- CPU back under 40% → remove 1 instance

This matters when load spikes **aren't smooth** — a sudden, large spike deserves a bigger, faster response than the slow, proportional correction target tracking would apply. Step scaling lets you say "if it's this bad, respond harder" explicitly, instead of trusting the control loop to eventually catch up.

---

## 3. Scheduled scaling — the only policy that acts ahead of demand

Target tracking and step scaling are both **reactive** — they wait for a metric to move before doing anything. **Scheduled scaling** is the one policy that acts **proactively**, ahead of demand that's already known.

If Friday's sale starts at 9:00am, waiting for CPU to climb means spending the first few minutes of the sale — the exact moment traffic is highest and you can least afford the lag — launching instances. **Scale up at 8:45am on a schedule instead.**

Known, recurring patterns get handled proactively. Reactive scaling is still there as a backstop for anything unexpected, but it shouldn't be the only tool for demand you can already see coming.

---

## 4. The full causal chain, start to finish

A common interview ask is *"walk me through what happens when traffic spikes."* Here's the complete chain, cause to effect:

```
traffic rises
      ↓
CPU climbs on existing instances
      ↓
target tracking's CloudWatch alarm fires
      ↓
ASG launches new instances from the (versioned) launch template
      ↓
new instances pass their health check after the grace period
      ↓
the ALB adds them to rotation
      ↓
load spreads thinner per instance
      ↓
CPU falls back toward target
      ↓
on a further drop, the ASG scales back in — respecting cooldown so it doesn't overcorrect
```

Every link in this chain is something covered on its own elsewhere in this curriculum — CloudWatch alarms (this doc), versioned launch templates and grace period (Auto Scaling Group doc), health checks and ALB routing (Health Checks doc), cooldown (Auto Scaling Group doc). Scaling isn't a separate mechanism bolted on top — it's all the same pieces, triggered in sequence.

Here's the same idea as a system diagram — three policy types all feeding into the same ASG, which draws from the same versioned launch template and hands off to the same health-check-gated rotation into the ALB:

```
                         USERS
                           |
                           v
                    +-------------+
                    |     ALB     |
                    +-------------+
                     /     |     \
                    /      |      \
                   v       v       v
                EC2 #1  EC2 #2  EC2 #3
                   \       |       /
                    \      |      /
                     +-----+-----+
                           |
                      CloudWatch
                           |
                    +--------------+
                    |    Scaling   |
                    |    Policy    |
                    +--------------+
                      /     |     \
                     /      |      \
                    v       v       v
             Target     Step     Scheduled
            Tracking   Scaling    Scaling
                    \      |      /
                     \     |     /
                      v    v    v
                         ASG
                          |
                 MIN / DESIRED / MAX
                          |
                          v
                  Launch Template
                     versioned
                          |
                          v
                    New EC2 instances
                          |
                          v
                     Health Checks
                          |
                          v
                         ALB
```

Notice the loop: the ALB sits at both the top and the bottom of the diagram — it's what users hit, and it's also what new instances report back to once they're healthy and ready for traffic.

---

## 5. Zero-downtime deploys use the same machinery differently

Instead of reacting to load, an **instance refresh** replaces instances with new ones from an **updated launch template**, one batch at a time — waiting for each batch to pass health checks before continuing. This means users never see a fully-down version; there's always a healthy batch serving traffic while the next batch rolls out.

This is the **same rolling-deployment idea as an ECS service** (see the ECS Core Concepts doc) — new-then-drain, gated by health checks — just applied at the **EC2 layer** instead of the **container layer**. Same pattern, different altitude.

---

## 6. Real-world shape

**Load balancer + Auto Scaling is the baseline** for any production web app that must stay up and handle variable traffic:

- **E-commerce sites** scale out for a sale and back down afterward
- **Ticketing sites** scale out for a single big on-sale moment

Elasticity is also a **cost lever**, not just a reliability one — scale down overnight when traffic is low, scale up during the day. This gets you **cost savings and performance at the same time**, rather than forcing a choice between them.

---

## 7. Interview line

> *"Target tracking is a CloudWatch-alarm-driven control loop converging on a metric target — the default choice, but only as good as the metric picked. Step scaling gives threshold-based control for uneven spikes. Scheduled scaling acts ahead of known demand instead of reacting. Together with health checks and versioned launch templates, this is also how zero-downtime deploys work — an instance refresh rolls out a new template version batch by batch, gated by health checks."*

---

## 8. Self-check

1. Why might target tracking on CPU fail to scale a service that's actually struggling under load?
2. Why does scheduled scaling exist when target tracking already reacts to real demand?
3. How does an instance refresh achieve a zero-downtime deploy — what's it reusing from the self-healing machinery already in place?

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **Target tracking** | CloudWatch-alarm-driven control loop converging on a metric target — the default, reactive policy |
| **Step scaling** | Explicit, threshold-based response sizes — bigger spike, bigger reaction, still reactive |
| **Scheduled scaling** | The only proactive policy — acts ahead of known demand, not in response to a metric |
| **Full causal chain** | Traffic → CPU → alarm → new instances → grace period → health check → ALB rotation → metric falls → scale-in respecting cooldown |
| **Instance refresh** | Rolling replacement from an updated launch template, batch by batch, gated by health checks — the EC2-layer equivalent of an ECS rolling deploy |
| **Elasticity as cost lever** | Scaling down during low-traffic hours saves cost without sacrificing performance during peak hours |
