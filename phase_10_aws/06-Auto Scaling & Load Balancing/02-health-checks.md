# Session 06 (2/5): Health Checks — Route to the Living

## Two separate self-healing layers, one signal

- **Load balancer health check controls routing only.** Fail it, and the LB
  stops sending traffic to that target. It does not restart or replace
  anything — it just stops routing.
- **ASG health check controls replacement.** By default an ASG only watches
  EC2 status checks (is the instance running at all), not the ALB's HTTP
  check. An app that's hung — process alive, but its DB connection is dead —
  still passes EC2 status checks, so the ASG does nothing, even though the LB
  has already pulled it from rotation.

**The fix:** explicitly enable **ELB health checks** on the ASG so it trusts
the target group's HTTP check too. Only then does a failed health check
actually trigger a replacement, not just a routing change. Forgetting this is
a real, common production gap — a service that looks "removed from rotation
forever" instead of "replaced."

## Deregistration delay (connection draining)

When an instance leaves a target group — health check failure or an
intentional scale-in — in-flight requests get a grace period (300s default)
to finish before the connection is force-closed. Without this, scaling down
or replacing an unhealthy instance drops requests mid-flight.

## Health check path design is a real trade-off

- A **shallow check** (`/` returns 200 as long as the process is up) misses
  real failures — the app can be "up" while a dependency (its database
  connection) is dead.
- A **deep check** (`/health` that verifies DB connectivity) catches that —
  but now a blip in the database marks *every* instance unhealthy at once,
  turning a partial problem into a total outage.

There's no universally correct answer — it's a real design trade-off between
catching real failures and avoiding self-inflicted total outages from a
shared dependency blip.

## The example setup from the slide, read correctly

Check path `/health`, every 30s, healthy after 2 passes, unhealthy after 2
fails: a crashed server is pulled from rotation within about a minute — that
part is automatic and needs no ASG involvement. Getting it *replaced*, not
just removed, needs the ELB-health-check setting above.

**Interview line:** *"A load balancer health check only affects routing —
failing it stops traffic, it doesn't fix anything. An Auto Scaling Group only
replaces an instance if it's configured to trust that same health check via
ELB health checks; otherwise it's watching EC2 status checks alone and won't
notice an app that's hung but still running."*

## Self-check before moving on

1. An instance's app is deadlocked but the EC2 instance itself is fine. The LB
   has stopped routing to it. Will the ASG replace it — under what condition?
2. Why does deregistration delay exist, and what would break without it?
3. What's the trade-off between a shallow health check and a deep one that
   verifies a database connection?
