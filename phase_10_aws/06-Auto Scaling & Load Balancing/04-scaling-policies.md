# Session 06 (4/5): Scaling Policies + The Full Picture

## Target tracking — a control loop, not magic

Pick a target (CPU at 50%), and AWS creates CloudWatch alarms behind the
scenes and continuously adjusts desired capacity to converge on that number —
mathematically a thermostat. This is why it's the default: you describe the
outcome, not the mechanism.

**When it misbehaves, it's usually the metric, not the policy.** CPU can stay
low while a service is memory-bound or I/O-bound, so scaling never triggers
even though the app is genuinely struggling. Real fix: scale on request count
per target, or a custom CloudWatch metric that actually reflects load for
that workload — not always CPU.

## Step scaling — control target tracking hides

Different thresholds trigger different-sized responses: CPU over 70% adds 2,
over 90% adds 4, back under 40% removes 1. Useful when load spikes aren't
smooth and a bigger spike deserves a bigger, faster response than a slow
linear correction.

## Scheduled scaling — the only policy that acts ahead of demand

If Friday's sale starts at 9am, you don't want to wait for CPU to climb and
spend the next few minutes launching instances during the exact moment you
can least afford the lag. Scale up at 8:45am on a schedule instead — known
patterns get handled proactively, not reactively.

## The full causal chain, start to finish

A common interview ask is "walk me through what happens when traffic spikes."
The real chain: traffic rises -> CPU climbs on existing instances -> target
tracking's CloudWatch alarm fires -> ASG launches new instances from the
(versioned) launch template -> new instances pass their health check after
the grace period -> the ALB adds them to rotation -> load spreads thinner per
instance -> CPU falls back toward target -> on a further drop, the ASG scales
back in, respecting cooldown so it doesn't overcorrect.

## Zero-downtime deploys use the same machinery differently

Instead of reacting to load, an **instance refresh** replaces instances with
new ones from an updated launch template, one batch at a time, waiting for
each batch to pass health checks before continuing — so users never see a
fully-down version. Same rolling-deployment idea as an ECS service, just at
the EC2 layer instead of the container layer.

## Real-world shape

Load balancer + Auto Scaling is the baseline for any production web app that
must stay up and handle variable traffic — e-commerce sites scale out for a
sale and back down after, ticketing sites for a big on-sale moment.
Elasticity is a cost lever too: scale down overnight when traffic is low,
scale up during the day, automatically getting both cost savings and
performance without choosing between them.

**Interview line:** *"Target tracking is a CloudWatch-alarm-driven control
loop converging on a metric target — the default choice, but only as good as
the metric picked. Step scaling gives threshold-based control for uneven
spikes. Scheduled scaling acts ahead of known demand instead of reacting.
Together with health checks and versioned launch templates, this is also how
zero-downtime deploys work — an instance refresh rolls out a new template
version batch by batch, gated by health checks."*

## Self-check before moving on

1. Why might target tracking on CPU fail to scale a service that's actually
   struggling under load?
2. Why does scheduled scaling exist when target tracking already reacts to
   real demand?
3. How does an instance refresh achieve a zero-downtime deploy — what's it
   reusing from the self-healing machinery already in place?
