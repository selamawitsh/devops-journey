# Session 4a · What EC2 Actually Is

## The Core Idea

EC2 (Elastic Compute Cloud) lets you rent virtual servers, called **instances**, and pay only
for the time they run. CPU, memory, storage, and networking — running in an AWS data center
instead of under your desk. Pick a Region, click launch, a server boots in about a minute.
Billing is per second while it runs (for Linux) — stop it, and the compute charge stops too.

## Every Instance Needs Four Things

Think of it like assembling a computer rather than buying one pre-built:

| # | Piece | Role | Detail |
|---|---|---|---|
| 1 | **AMI** | The template | Amazon Machine Image — the OS and pre-installed software (Amazon Linux, Ubuntu, Windows). Your instance boots from this |
| 2 | **Instance type** | The size | How much CPU and memory — `t3.micro` for us. Decides speed and price |
| 3 | **Storage** | The disk | An EBS volume, a virtual hard drive that persists. The root volume holds the OS |
| 4 | **Network + security** | The doors | Which VPC and subnet it lives in, and a security group controlling who can reach it |

## Why Companies Use It Instead of Buying Servers

| | Buying a physical server | Renting EC2 |
|---|---|---|
| **Cost model** | CapEx — large payment up front | OpEx — pay only for hours run |
| **Utilization** | Most physical servers sit at 10–20% load, wasted the rest of the time | Scale up or down in minutes |
| **Failure recovery** | Replace hardware, wait days | Launch a new instance, wait a minute |

This is the entire economic argument for "the cloud" in one sentence: elasticity beats
ownership when demand is unpredictable.

## Reading an Instance Type Name

`t3.micro` isn't arbitrary — it's structured, like reading a shirt size plus a model year.

```
t3.micro
 │ │  └── size (nano < micro < small < medium < large < xlarge...)
 │ └───── generation (higher = newer, usually faster and cheaper per unit)
 └─────── family (what the instance is *tuned* for)
```

- **t** — the family (T = general purpose, burstable)
- **3** — the generation. Higher = newer, usually faster and cheaper per unit
- **micro** — the size. nano < micro < small < medium < large < xlarge...

## Instance Families: Right Tool, Right Job

You do not memorize every family — you learn to read one.

| Family | Tuned for | Example use |
|---|---|---|
| **T / M** | General purpose — balanced CPU + memory | Web servers, small apps, dev boxes — `t3.micro` is Free Tier |
| **C** | Compute optimized — heavy CPU | Batch processing, gaming servers, scientific modeling |
| **R / X** | Memory optimized — big RAM | In-memory databases, large caches, real-time analytics |
| **G / P** | Accelerated — GPU | Graphics, machine learning training — the expensive ones |

If an incident ticket says "app is CPU-starved on an `r5.large`", you should immediately notice
the mismatch: that's a memory-tuned instance being asked to do CPU-heavy work.

## How This Shows Up in Real Debugging

"Why is this instance slow" is one of the most common on-call questions, and instance-type
mismatch is one of the first things to rule out — alongside undersized storage IOPS and
network throughput ceilings for that instance size. Undersizing costs performance; oversizing
quietly burns budget every month until a cost review catches it.

## Common Mistakes

- Picking the biggest instance "to be safe" instead of matching the workload — the single most
  common source of wasted AWS spend at small companies.
- Forgetting billing is per-second while *running* — test instances left on overnight are a
  classic surprise line item.
- Assuming "stopping saves money completely" — storage keeps billing even while stopped (more
  on this in Session 4d).

## Key Terms

- **EC2 (Elastic Compute Cloud)** — AWS's rented-virtual-server service, billed by the second
- **Instance** — a single running virtual server
- **Instance type** — the family/generation/size combination that determines CPU, memory, and price
- **Instance family** — the letter prefix (T, M, C, R, G...) indicating what the type is tuned for

Reflection questions for the whole session are in file 05, after the lab.
