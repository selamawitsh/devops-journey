# Auto Scaling Group — The Right Number

*Session 06 (3/5) — Linux/DevOps Curriculum*

An ASG's whole job is answering "how many instances should be running right now, and how do we get there safely?" Everything below is really just detail on that one question.

---

## Table of Contents

1. [Min / Desired / Max — the whole mental model](#1-min--desired--max--the-whole-mental-model)
2. [Launch templates are versioned, not edited in place](#2-launch-templates-are-versioned-not-edited-in-place)
3. [Health check grace period — the "false failure" trap](#3-health-check-grace-period--the-false-failure-trap)
4. [Cooldown periods prevent thrashing](#4-cooldown-periods-prevent-thrashing)
5. [Grace period vs. cooldown — don't mix these up](#5-grace-period-vs-cooldown--dont-mix-these-up)
6. [Self-healing, precisely](#6-self-healing-precisely)
7. [AZ spreading](#7-az-spreading)
8. [How it all fits together](#8-how-it-all-fits-together)
9. [Interview line](#9-interview-line)
10. [Self-check](#10-self-check)

---

## 1. Min / Desired / Max — the whole mental model

| Setting | Role |
|---|---|
| **Min** | Safety floor — never fewer than this, no matter what |
| **Max** | Cost/safety ceiling — never more than this, no matter what |
| **Desired** | Where the ASG is actively trying to sit *right now* |

**Min** is the guarantee that capacity never drops below a level you've decided is unacceptable, even during a scale-in event or a wave of instance failures.

**Max** is the actual protection against a bug or a traffic spike launching hundreds of instances and producing a shocking bill. It's a hard ceiling — no scaling policy, no runaway metric, can push the group past it.

**Desired** is the number that actually moves. Scaling policies adjust it automatically in response to load, but it's always kept within the min/max bounds — it can never be pushed outside that range.

The chain of cause and effect is short and mechanical:

```
   Scaling policy
         ↓
   changes desired
         ↓
   ASG launches/terminates instances
```

Nothing scales the fleet directly — a policy only ever moves the **desired** number, and the ASG's job is to make reality match that number by launching or terminating instances.

---

## 2. Launch templates are versioned, not edited in place

Changing anything in a launch template — the AMI, instance type, User Data script, security groups — **creates a new version.** The ASG then references a specific version (or explicitly tracks "latest").

This is the exact same pattern as **ECS task definition revisions** (see the ECS Core Concepts doc), and for the same underlying reason:

- At any moment you can say **exactly** what configuration a running instance launched from
- Rolling back means **pointing at a previous version**, not reconstructing what changed

Immutable, versioned config shows up repeatedly in AWS because it solves the same problem every time: "what's actually running right now, and how do I get back to what worked before."

---

## 3. Health check grace period — the "false failure" trap

A freshly launched instance needs time to:

1. Boot
2. Run its User Data script
3. Actually start serving traffic

If the ASG starts counting health check failures against the instance **immediately**, a perfectly fine instance gets killed for failing a check it never had a chance to pass — it was still booting, not broken.

**The fix:** the **health check grace period** tells the ASG to ignore failures for the instance's first N seconds after launch, giving it time to actually come up before its health is judged.

> Skipping this is a classic, real cause of instances stuck in an endless launch → fail health check → get killed → relaunch loop — one that has nothing to do with the actual application and everything to do with the ASG judging the instance too early.

---

## 4. Cooldown periods prevent thrashing

After a scaling action, the ASG **waits** before evaluating whether to scale again.

Without this, a metric that's still catching up to reflect a just-added instance could trigger *another* scale-out before the first instance has even had a chance to help absorb load — overshooting capacity and adding instances the group didn't actually need.

The cooldown period is what gives a scaling action time to actually take effect before the ASG re-evaluates.

---

## 5. Grace period vs. cooldown — don't mix these up

These two settings sound similar and get confused constantly, but they protect against opposite problems:

| | Protects against | Applies to |
|---|---|---|
| **Health check grace period** | A brand-new instance being killed before it's even finished booting | A single instance, right after launch |
| **Cooldown period** | The ASG scaling again before its last action has had time to take effect | The group's scaling decisions overall |

**In one line: grace period protects new instances from being killed too early, while cooldown prevents the ASG from scaling again too quickly.**

---

## 6. Self-healing, precisely

If an instance fails its health check — see the Health Checks document for exactly which health check and under what condition — the ASG:

1. **Terminates** the failed instance
2. **Launches a fresh replacement** from the launch template

Capacity restores itself with **no human action required**, and the grace period from Section 3 applies to that replacement too — it isn't judged on health until it's had time to actually come up:

```
   EC2 fails
      ↓
   Health Check
      ↓
   ASG detects failure
      ↓
   Terminate unhealthy instance
      ↓
   Launch replacement
      ↓
   Launch Template
      ↓
   New EC2
      ↓
   Grace period
      ↓
   Health check passes
      ↓
   ALB sends traffic
```

---

## 7. AZ spreading

The ASG actively balances instances **evenly across the Availability Zones** it's configured to use. This means losing one entire AZ only takes out the fraction of the fleet that happened to be placed there — not the whole fleet at once.

---

## 8. How it all fits together

Zooming out, here's the full shape — users hitting the load balancer, the ASG holding the fleet between min/max, and the self-healing loop running underneath it the whole time:

```
                         USERS
                           │
                           ▼
                    ┌────────────┐
                    │    ALB     │
                    └─────┬──────┘
                          │
                ┌─────────┼─────────┐
                ↓         ↓         ↓
              EC2 A     EC2 B     EC2 C
                │         │         │
                └─────────┼─────────┘
                          │
                         ASG
                          │
              ┌───────────┼───────────┐
              ↓           ↓           ↓
             MIN       DESIRED       MAX
              2           3            6
                          │
                          ↓
                  Scaling Policies
                          │
                ┌─────────┴─────────┐
                ↓                   ↓
             Scale Out           Scale In
                │                   │
                └─────────┬─────────┘
                          ↓
                  Launch Template
                          │
                    Versioned config
                          │
                          ↓
                      New EC2
```

Everything above the `ASG` line is what users and the ALB see — a set of healthy EC2 instances taking traffic. Everything below it is the ASG's internal bookkeeping: min/desired/max bounds, scaling policies nudging desired up or down, and a versioned launch template supplying the exact config for any new instance it launches.

---

## 9. Interview line

> *"An ASG holds capacity between a min floor and a max ceiling, targeting a desired count moved by scaling policies. Instances launch from a versioned launch template — same immutable-revision pattern as ECS task definitions. A health check grace period protects instances still booting, and cooldown periods stop the group from over-correcting on stale metrics."*

---

## 10. Self-check

1. Why does the max setting exist — what's the actual risk it protects against?
2. A new instance keeps getting killed and relaunched right after boot, even though the app works fine once it's up. What setting is almost certainly missing?
3. Why does a launch template create a new version instead of being edited in place?

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **Min** | Safety floor — capacity never drops below this |
| **Max** | Cost/safety ceiling — capacity never exceeds this, protects against runaway scaling |
| **Desired** | The number scaling policies actively move, always within min/max |
| **Launch template versioning** | Immutable, versioned config — same pattern as ECS task definition revisions |
| **Health check grace period** | Ignores health check failures for N seconds after launch, so booting instances aren't killed prematurely |
| **Cooldown period** | Wait time after a scaling action, before re-evaluating, to prevent overshooting capacity |
| **Self-healing** | Failed instance is terminated and automatically replaced from the launch template |
| **AZ spreading** | Instances balanced evenly across AZs, so losing one AZ only costs that fraction of the fleet |
