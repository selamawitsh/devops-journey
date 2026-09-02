# Session 4a · What Is EC2 & Instance Types

## What Is EC2?

**EC2 (Elastic Compute Cloud)** lets you rent virtual servers, called instances, and pay
only for the time they run. Launch in seconds, delete when done.

| | Detail |
|---|---|
| A computer you rent | CPU, memory, storage, and networking, running in an AWS data center instead of under your desk |
| Anywhere, in seconds | Pick a Region, click launch, a server boots in about a minute — no shipping, no cables |
| Pay per second | Billed while it runs (per second for Linux). Stop it and the compute charge stops too |

## Instance Types: Right Tool, Right Job

AWS offers families tuned for different workloads. The goal isn't to memorize them — it's
to learn to *read* them.

| Family | Tuned for | Example use |
|---|---|---|
| **T / M** — General purpose | Balanced CPU and memory | Web servers, small apps, dev boxes. `t3.micro` is Free Tier |
| **C** — Compute optimized | Heavy CPU | Batch processing, gaming servers, scientific modeling |
| **R / X** — Memory optimized | Big RAM | In-memory databases, large caches, real-time analytics |
| **G / P** — Accelerated (GPU) | Graphics/ML training | The expensive ones |

## Decoding an Instance Name

```
t3.micro
 │  └── size
 └───── family + generation
```

| Part | Meaning |
|---|---|
| `t` | The family (T = general purpose, burstable) |
| `3` | The generation — higher usually means newer, faster, and cheaper per unit |
| `micro` | The size — `nano < micro < small < medium < large < xlarge < 2xlarge...` |

## Tie-In To My Own Work

When CredentialChain eventually gets deployed, its Go microservices would likely start on
`t3`/`t4g` instances — general purpose, balanced, cheap enough to run several services
without needing heavy compute or GPU power.

## Key Terms

- **Instance** — a single virtual server running on EC2
- **Family** — the letter prefix indicating what an instance type is tuned for (CPU, memory, GPU, balanced)
- **Free Tier** — AWS's allowance of limited free usage, including `t3.micro`/`t2.micro` hours




