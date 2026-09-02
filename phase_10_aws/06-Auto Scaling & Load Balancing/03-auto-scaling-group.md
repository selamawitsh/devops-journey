# Session 06 (3/5): Auto Scaling Group — The Right Number

## Min / Desired / Max — the whole mental model

- **Min** — safety floor, never fewer than this no matter what.
- **Max** — cost/safety ceiling, never more than this no matter what. This is
  the actual protection against a bug or traffic spike launching hundreds of
  instances and a shocking bill.
- **Desired** — where the ASG is actively trying to sit right now, moved
  automatically by scaling policies, always kept within min/max.

## Launch templates are versioned, not edited in place

Changing anything in a launch template creates a new version; the ASG
references a specific version (or "latest"). This is the same pattern as ECS
task definition revisions (Session 7) for the same reason: at any moment you
can say exactly what configuration a running instance launched from, and
rolling back means pointing at a previous version — not reconstructing what
changed.

## Health check grace period — the "false failure" trap

A freshly launched instance needs time to boot, run its User Data script, and
start actually serving traffic. If the ASG counts health check failures
against it immediately, a perfectly fine instance gets killed for failing a
check it never had a chance to pass — it was still booting. The **health
check grace period** tells the ASG to ignore failures for the instance's first
N seconds. Skipping this is a classic real cause of instances stuck in an
endless launch-fail-relaunch loop that has nothing to do with the actual
application.

## Cooldown periods prevent thrashing

After a scaling action, the ASG waits before evaluating whether to scale
again. Without this, a metric still catching up to a just-added instance
could trigger another scale-out before the first instance even helped,
overshooting capacity.

## Self-healing, precisely

If an instance fails its health check (see the Health Checks doc for the LB
vs ASG distinction), the ASG terminates it and launches a fresh replacement
from the launch template — capacity restores itself with no human action.

## AZ spreading

The ASG actively balances instances evenly across the AZs selected, so losing
one AZ only takes out the fraction of the fleet that happened to be there,
not the whole thing.

**Interview line:** *"An ASG holds capacity between a min floor and a max
ceiling, targeting a desired count moved by scaling policies. Instances launch
from a versioned launch template — same immutable-revision pattern as ECS
task definitions. A health check grace period protects instances still
booting, and cooldown periods stop the group from over-correcting on stale
metrics."*

## Self-check before moving on

1. Why does the max setting exist — what's the actual risk it protects
   against?
2. A new instance keeps getting killed and relaunched right after boot, even
   though the app works fine once it's up. What setting is almost certainly
   missing?
3. Why does a launch template create a new version instead of being edited in
   place?
