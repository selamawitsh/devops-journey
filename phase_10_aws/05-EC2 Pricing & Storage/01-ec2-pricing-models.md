# The Four Pricing Models

*Session 05 (1/5) — Linux/DevOps Curriculum*

Four ways to pay for EC2 capacity, each trading flexibility for savings differently. The right choice depends on whether a workload can tolerate interruption, and how predictable its usage is — not on which option sounds cheapest on paper.

---

## Table of Contents

1. [On-Demand — the baseline](#1-on-demand--the-baseline)
2. [Spot — not an auction anymore](#2-spot--not-an-auction-anymore)
3. [Reserved Instances vs Savings Plans — genuinely different tools](#3-reserved-instances-vs-savings-plans--genuinely-different-tools)
4. [Dedicated Hosts vs Dedicated Instances](#4-dedicated-hosts-vs-dedicated-instances)
5. [Interview line](#5-interview-line)
6. [Choosing between them](#6-choosing-between-them)

---

## 1. On-Demand — the baseline

Pay **per second** (with a 60-second minimum) on Linux. Windows and some other OS billing is still **hourly**.

This is why short-lived Linux experiments are cheaper than people assume — spin up an instance for five minutes of testing and you're billed for roughly five minutes, not a full hour. It's also why **On-Demand is the right default for anything unpredictable or short-lived** — no commitment, no interruption risk, just pay for what you use.

---

## 2. Spot — not an auction anymore

Older material describes Spot as literal bidding against other customers for capacity. **That model is gone.**

Spot price now tracks **long-term supply and demand** for spare capacity in a given AZ/instance-type pool, and you're charged that current market price — capped at a ceiling you set, usually the On-Demand price. There's no real-time bidding war happening behind the scenes anymore.

### What hasn't changed: the 2-minute reclaim warning

AWS can still reclaim a Spot instance at any time, giving a **2-minute warning** — delivered as a CloudWatch event, and also available directly from the instance's own metadata endpoint.

A real workload built on Spot needs a handler that **catches that warning and checkpoints or drains gracefully** — saving progress, finishing in-flight work, or handing traffic off — rather than just getting killed mid-task.

### The real production pattern: diversification, not a single instance

Relying on one Spot instance is fragile — it's just a risky discount. The pattern that actually makes Spot viable for production work is different: an **ASG with a mixed-instances policy**, spread across many instance types and multiple AZs.

Spread this way, a reclaim in one pool doesn't correlate with a reclaim in another — the fleet as a whole survives even as individual instances get interrupted here and there. This diversification is *why* Spot is genuinely usable for real batch workloads, not just a discount with a catch.

---

## 3. Reserved Instances vs Savings Plans — genuinely different tools

These two get treated as interchangeable, but they commit to fundamentally different things.

| | Commits to | Flexibility |
|---|---|---|
| **Reserved Instance (RI)** | A **specific instance type and region** | Standard RIs can't change type at all; Convertible RIs can, but for a smaller discount than Standard |
| **Savings Plan** | A **dollar-per-hour spend**, period | AWS automatically applies it to whatever instance type or family is actually running — even across EC2, Fargate, and some Lambda usage |

**AWS itself now steers most customers toward Savings Plans over RIs**, specifically because of that flexibility — you're not locked into a single instance family if your architecture shifts.

> Know which one an interviewer means when they say "Reserved" — they're not interchangeable, and conflating them is an easy tell that the distinction hasn't landed.

---

## 4. Dedicated Hosts vs Dedicated Instances

These sound like the same idea at different intensities, but they solve two genuinely different problems.

- **Dedicated Instance** — guarantees that **no other AWS customer's workload shares your physical hardware**. That's the entire guarantee: isolation.
- **Dedicated Host** — goes further, giving you **visibility into the actual physical server** — sockets, cores, and all.

That extra visibility matters for a specific reason: some software licenses (**Windows Server, Oracle**) are priced **per-socket or per-core**, and staying compliant with those licenses requires being able to see and report on that physical hardware detail. A Dedicated Instance's isolation alone doesn't give you that visibility.

**Compliance (isolation) and licensing (per-socket/core visibility) are two different reasons to land on dedicated hardware — not the same reason phrased two ways.**

---

## 5. Interview line

> *"On-Demand is the flexible baseline. Spot tracks supply/demand for spare capacity with a 2-minute reclaim warning — real production use means diversifying across instance types and AZs, not a single Spot instance. Reserved Instances commit to a specific instance family; Savings Plans commit to a spend level and apply automatically to whatever's running, which is why AWS recommends them for most cases now. Dedicated Hosts add physical visibility for per-socket licensing, which Dedicated Instances don't provide."*

---

## 6. Choosing between them

The overall shape of the four options:

```
                    EC2 PRICING
                        |
       +----------------+----------------+
       |                |                |
       v                v                v
   On-Demand          Spot          Commitment
       |                |                |
       |                |          +-----+------+
       |                |          |            |
       v                v          v            v
 Flexible          Cheap but     Reserved    Savings
 no commitment     interruptible Instances   Plans
```

And the decision path for actually picking one — the questions that matter, in order, are interruption tolerance first, then predictability, then whether flexibility across instance types matters:

```
               Need EC2?
                 |
                 v
       Can workload tolerate
          interruption?
           /          \
         YES           NO
          |             |
          v             v
        Spot       Is usage predictable?
                     /        \
                   NO          YES
                   |            |
                   v            v
              On-Demand   Need flexibility?
                            /       \
                          YES       NO
                           |         |
                           v         v
                    Savings Plan    RI
```

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **On-Demand** | Pay per second (Linux), no commitment — the default for anything unpredictable or short |
| **Spot** | Market-price spare capacity, capped at a ceiling, reclaimable with a 2-minute warning — viable in production only when diversified across instance types/AZs |
| **Reserved Instance** | Commits to a specific instance type + region; Standard can't change type, Convertible can for less discount |
| **Savings Plan** | Commits to a dollar-per-hour spend, auto-applies across instance types/services — AWS's preferred default now |
| **Dedicated Instance** | Guarantees hardware isolation from other customers only |
| **Dedicated Host** | Adds visibility into physical sockets/cores — needed for per-socket/core software licensing compliance |
