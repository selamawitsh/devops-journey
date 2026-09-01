# Session 07 (3/5): ECS Core Concepts

## Task definition — an immutable, versioned blueprint

A task definition is JSON describing exactly what should run: which image
(and which exact tag — this is where commit-SHA tagging from the ECR doc pays
off), how much CPU/memory, which ports, which env vars, which IAM role the
container assumes.

Task definitions are never edited in place. Every change creates a new
**revision** — `web-task:1`, `web-task:2`, `web-task:3`. This means at any
moment you can answer "what's running in prod right now" with an exact chain:
revision number -> exact image tag -> exact git commit. Rolling back is just
pointing the service at the previous revision, not reconstructing what changed.

## Task — usually one container, sometimes more

A task is one running instance of a task definition. Most of the time that's a
single container. But a task definition's `containerDefinitions` field is an
**array**, not a single object, because a task can bundle multiple containers
that always deploy, scale, and get placed together as one unit — sharing the
same network namespace, so they can reach each other over `localhost`.

This is the **sidecar pattern**: a main app container plus a small helper
bolted to it. Common real examples: a log-shipping sidecar (Fluent Bit)
tailing the app's logs and forwarding them centrally, or a metrics exporter.

## Service — self-healing, plus rolling deployments

A service keeps a `desiredCount` of tasks running and replaces any that die.
The part that matters day to day is how it deploys: pointing a service at a
new task definition revision doesn't kill everything and restart. It starts
new tasks from the new revision, waits for them to pass health checks, then
drains the old ones. Two settings control how aggressive that is:

- `minimumHealthyPercent` — how far capacity is allowed to dip mid-deploy
  (e.g. 50% means half of desired count can be down at once).
- `maximumPercent` — how far above desired count it can go while spinning up
  new tasks (e.g. 200% allows briefly running double capacity).

**The real-world failure mode:** if the ALB health check path is
misconfigured, ECS concludes the new (actually fine) tasks are unhealthy,
refuses to finish the rollout, and keeps cycling. The service looks "stuck
deploying" — the bug is a wrong `/health` path, not the application code. This
is one of the most common ECS incidents in practice, not an edge case.

## Cluster — just the capacity boundary

A cluster is a logical grouping that tasks and services run inside. Nothing
more than that. It's backed either by Fargate (AWS-managed capacity) or by EC2
instances registered as cluster capacity. Companies typically run one cluster
per environment (`staging`, `prod`) and separate services *within* a cluster
by name, rather than spinning up a cluster per service.

## How this maps onto a real multi-service platform

Agri-Yield's 11 services wouldn't need 11 clusters — they'd typically sit
inside one `agri-yield-prod` cluster as 11 separate services, each with its
own task definition, its own desired count, its own independent rolling
deployments. `geospatial-service` redeploying doesn't touch `farm-service`'s
running tasks at all — they're different services in the same cluster.

