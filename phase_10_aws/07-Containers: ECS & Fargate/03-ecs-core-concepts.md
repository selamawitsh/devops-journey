# ECS Core Concepts

*Session 07 (3/5) — Linux/DevOps Curriculum*

A working reference for how AWS Elastic Container Service (ECS) is structured, from a task definition all the way up to a running container. The five concepts below build on each other in order — each one wraps the one before it.

---

## Table of Contents

1. [Task Definition — the blueprint](#1-task-definition--the-blueprint)
2. [Task — a running instance](#2-task--a-running-instance)
3. [Service — self-healing + rolling deploys](#3-service--self-healing--rolling-deploys)
4. [Cluster — the capacity boundary](#4-cluster--the-capacity-boundary)
5. [Putting it together: a real multi-service platform](#5-putting-it-together-a-real-multi-service-platform)
6. [The full pipeline, end to end](#6-the-full-pipeline-end-to-end)

---

## 1. Task Definition — the blueprint

A **task definition** is a JSON document describing exactly what should run:

- Which Docker image, and **which exact tag** (this is where commit-SHA tagging pays off — see the ECR notes)
- CPU and memory allocation
- Which ports are exposed
- Environment variables
- Which IAM role the container assumes at runtime

**The key rule: task definitions are immutable.** You never edit one in place. Every change — a new image tag, a new env var, a memory bump — creates a new **revision**:

```
web-task:1
web-task:2
web-task:3
```

### Why immutability matters

Because revisions are never overwritten, you always have an exact, auditable chain:

```
revision number  →  exact image tag  →  exact git commit
```

At any moment you can answer "what's running in prod right now?" with certainty. And rolling back is trivial — it's not "figure out what changed and reverse it," it's just **pointing the service at the previous revision number**. The old, known-good JSON already exists; nothing needs to be reconstructed.

---

## 2. Task — a running instance

A **task** is one running instance of a task definition. Most of the time, that means one container. But look closer at the task definition's `containerDefinitions` field — it's an **array**, not a single object. That's deliberate: a task can bundle multiple containers that:

- always deploy together
- always scale together
- always get placed on the same host together
- share the same network namespace, so they can talk to each other over `localhost`

### The sidecar pattern

This is what makes the **sidecar pattern** possible: a main application container plus a small helper container bolted onto it, living inside the same task.

Common real-world sidecars:

| Sidecar | Purpose |
|---|---|
| **Fluent Bit** | Tails the app container's logs and forwards them to a central log store |
| **Metrics exporter** | Scrapes app metrics and exposes them for a monitoring system |

The app container doesn't need to know how logging or metrics collection works internally — it just writes to stdout or a local port, and the sidecar handles the rest.

---

## 3. Service — self-healing + rolling deploys

A **service** does two jobs:

1. **Keeps a `desiredCount` of tasks running.** If a task dies (crash, host failure, health check failure), the service starts a replacement automatically. This is the self-healing part.
2. **Manages deployments when you point it at a new task definition revision.**

### How a deployment actually happens

Pointing a service at a new revision does **not** kill everything and restart from scratch. Instead:

1. New tasks are started from the new revision
2. ECS waits for them to pass health checks
3. Only once they're healthy does it drain (stop) the old tasks

Two settings control how aggressive this rollout is:

- **`minimumHealthyPercent`** — how far capacity is allowed to dip mid-deploy. `50%` means half of `desiredCount` can be down at once while the rollout is in progress.
- **`maximumPercent`** — how far above `desiredCount` the service can go while new tasks are spinning up. `200%` allows briefly running at double capacity before old tasks are drained.

### The real-world failure mode

This is worth internalizing because it's genuinely one of the most common ECS incidents, not an edge case:

> If the ALB (load balancer) health check path is misconfigured, ECS concludes the new tasks — which are actually fine — are unhealthy. It refuses to finish the rollout and keeps cycling new tasks up and down.

From the outside, the service just looks **"stuck deploying."** The instinct is to suspect the application code. But the actual bug is almost always something mundane like a wrong `/health` path in the health check config — the new code was fine the whole time; ECS just never got a passing health check to confirm it.

---

## 4. Cluster — the capacity boundary

A **cluster** is a logical grouping that tasks and services run inside. That's it — nothing more. It doesn't define behavior, scaling, or deployment logic; it just defines *where capacity comes from*.

A cluster is backed by either:

- **Fargate** — AWS-managed capacity, no servers to think about
- **EC2** — instances you register as cluster capacity yourself

### Convention: one cluster per environment

Companies typically run **one cluster per environment** (`staging`, `prod`) — not one cluster per service. Services are separated *by name* within that shared cluster, not by spinning up a dedicated cluster for each one.

---

## 5. Putting it together: a real multi-service platform

Applying this to a platform with 11 independent services: it wouldn't need 11 clusters. All 11 services sit inside **one** `agri-yield-prod` cluster, each as its own service — with its own task definition, its own `desiredCount`, and its own independent rolling deployments.

Crucially, these deployments don't interfere with each other. `geospatial-service` redeploying doesn't touch `farm-service`'s running tasks at all — they're just different services that happen to share the same cluster.

```
                          ECS CLUSTER
                               │
              ┌────────────────┼────────────────┐
              ↓                ↓                ↓
          SERVICE          SERVICE          SERVICE
       farm-service     weather-service  geospatial-service
              │                │                │
         desired=3        desired=2        desired=2
              │                │                │
          ┌───┼───┐         ┌──┴──┐         ┌──┴──┐
          ↓   ↓   ↓         ↓     ↓         ↓     ↓
         TASK TASK TASK    TASK  TASK      TASK  TASK
          🐳   🐳   🐳       🐳     🐳         🐳     🐳
```

---

## 6. The full pipeline, end to end

Zooming out, here's how everything from a code change to a running container connects:

```
   Developer
      ↓
   Git
      ↓
   CI/CD
      ↓
   Docker build
      ↓
   Docker image
      ↓
   ECR                    (image registry — stores the tagged image)
      ↓
   ECS Task Definition     (the immutable blueprint, referencing that image tag)
      ↓
   ECS Service             (keeps desiredCount running, manages rollout)
      ↓
   ECS Task                (one running instance of the task definition)
      ↓
   🐳 Running Container
```

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **Task Definition** | Immutable, versioned JSON blueprint — image tag, CPU/mem, env vars, IAM role |
| **Task** | One running instance of a task definition (usually 1 container, sometimes several via sidecars) |
| **Service** | Keeps N tasks alive, handles rolling deploys between revisions |
| **Cluster** | Just a capacity boundary — logical grouping of services, backed by Fargate or EC2 |
