# EC2 Launch Type vs Fargate

*Session 07 (4/5) — Linux/DevOps Curriculum*

Both are ways to give an ECS cluster somewhere to actually run tasks. The difference isn't just "who manages the server" — it's a real mechanical difference that drives cost, operational burden, and which workloads even fit.

---

## Table of Contents

1. [The actual mechanism](#1-the-actual-mechanism)
2. [The cost trade-off, with the reasoning](#2-the-cost-trade-off-with-the-reasoning)
3. [Real clusters mix both](#3-real-clusters-mix-both)
4. [Reasoning about a real multi-service platform](#4-reasoning-about-a-real-multi-service-platform)
5. [When containers aren't even the right tool](#5-when-containers-arent-even-the-right-tool)
6. [Interview line](#6-interview-line)
7. [Self-check](#7-self-check)

---

## 1. The actual mechanism

### EC2 launch type

You register real EC2 instances as cluster capacity yourself. Each instance runs the **ECS agent**, and the **ECS scheduler bin-packs** multiple tasks onto each instance based on the CPU/memory each task definition requests.

That means you own:

- Patching the AMI (the machine image the instances boot from)
- Scaling instance count — usually via an **Auto Scaling Group** wired in as a **Capacity Provider**
- **Draining instances safely** before terminating them, so running tasks aren't killed mid-request

### Fargate

There's no instance to register at all. AWS provisions a right-sized, isolated **micro-VM per task**, on demand — built on **Firecracker**, the same technology behind Lambda. It runs the task, then tears the micro-VM down when the task stops. You never see or manage that host.

> This is why the lab's cluster creation step had "nothing to launch" — with Fargate there's genuinely no capacity decision to make.

---

## 2. The cost trade-off, with the reasoning

| | How it bills | What that means |
|---|---|---|
| **EC2** | For the instance being *on*, regardless of utilization | Bin-pack several tasks tightly onto one instance running near-full utilization around the clock, and you're spreading one fixed instance cost across many tasks — cost per task drops |
| **Fargate** | Per task, per second, for exactly the vCPU/memory requested | Nothing to amortize, but also nothing wasted sitting idle |

**The rule of thumb:**

- **High, steady, bin-packable utilization → EC2 wins.**
- **Low or bursty utilization → Fargate wins.** An EC2 instance in that scenario sits mostly idle while still being billed in full; Fargate only charges for seconds actually used.

---

## 3. Real clusters mix both

A common production pattern is a **Capacity Provider Strategy** that spreads tasks across:

- **Fargate** — standard, on-demand
- **Fargate Spot** — up to ~70% cheaper, but AWS can reclaim the task with only a **2-minute warning**
- **EC2** — for the workloads where bin-packing pays off

Spot suits fault-tolerant batch work; it's a poor fit for anything stateful or latency-critical that can't absorb a sudden 2-minute-notice kill.

### Hard technical limit: no GPUs on Fargate

**Fargate does not support GPU workloads.** A service needing GPU (e.g. ML inference) *requires* the EC2 launch type with a GPU-backed instance type. This is a real, common reason companies end up running **mixed** clusters — Fargate for the bulk of stateless services, a small EC2 GPU pool for the one service that actually needs it.

---

## 4. Reasoning about a real multi-service platform

Take a profile like: **eleven steady, always-on, moderate-baseline-load services, run by a small team.**

That profile favors **Fargate early on** — there's no AMI patching or capacity planning to operate across 11 services while the priority is actually building the platform.

If one specific service later becomes high-volume enough that bin-packing savings genuinely matter, **that single service migrates to EC2 launch type — not the whole cluster.** Mixed clusters like this are the normal end state, not a compromise or a sign something went wrong.

---

## 5. When containers aren't even the right tool

It's worth stepping back one level further — ECS itself isn't always the right call.

### A small, low-traffic, rarely-changed app

Task definitions, services, clusters, an ALB, IAM task roles — all of that buys you **rolling deployments and self-healing you don't need yet**. A single EC2 instance, or a managed platform like **Elastic Beanstalk** or **App Runner**, runs the same app with far less to operate. Reaching for ECS here is *premature*, not *wrong in principle* — it's the right tool used too early.

### Event-driven, short-lived, bursty-to-zero work

A function that runs 200ms in response to an S3 upload, or a nightly 2-minute job, doesn't want a container kept warm and paid for continuously.

- **Lambda** skips containers and servers entirely — pay only for milliseconds executed, scales to zero when idle.
- Even *inside* ECS, an occasional job is better served by a **scheduled task** (EventBridge triggers a one-off Fargate `RunTask` on a cron) than a long-running service with `desiredCount: 1` sitting idle almost all day.

---

## 6. Interview line

> *"EC2 launch type trades operational ownership for cost efficiency at high, steady, bin-packable utilization. Fargate trades a per-task cost premium for zero infrastructure ownership. Real clusters often mix Fargate, Fargate Spot, and EC2 by service based on each service's utilization pattern and blast-radius tolerance — and containers aren't the floor; low-traffic apps and short bursty event-driven work often don't need ECS at all."*

---

## 7. Self-check

1. Why does EC2 launch type get cheaper as utilization and bin-packing improve, while Fargate's cost doesn't change with utilization at all?
2. Name a real workload requirement that forces EC2 launch type over Fargate.
3. Why does a scheduled Fargate task fit an occasional nightly job better than a long-running service with desired count 1?

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **EC2 launch type** | You manage real instances; ECS bin-packs tasks onto them; cheaper at high steady utilization |
| **Fargate** | Per-task micro-VMs (Firecracker), no host management; billed per task/second; no GPU support |
| **Fargate Spot** | Cheaper Fargate, reclaimable with a 2-minute warning — for fault-tolerant work only |
| **Mixed clusters** | Normal production pattern — different services on different launch types within one cluster |
| **Below ECS entirely** | Single instance / App Runner for small stable apps; Lambda or scheduled Fargate tasks for bursty event-driven work |
