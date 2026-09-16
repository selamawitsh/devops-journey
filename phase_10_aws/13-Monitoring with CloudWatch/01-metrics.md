# Session 13 — Metrics

## What a metric actually is

A metric is one number, tracked over time. That's the entire definition — nothing more mystical than that.

AWS is already producing these numbers for every resource you run, whether you asked for them or not:

| Service | Example metrics |
|---|---|
| EC2 | `CPUUtilization`, `NetworkIn`, `NetworkOut`, disk read/write ops |
| RDS | `CPUUtilization`, `FreeStorageSpace`, `DatabaseConnections` |
| Lambda | `Invocations`, `Errors`, `Duration`, `Throttles` |

None of this required you to write instrumentation code. It ships by default the moment the resource exists.

## Standard vs detailed monitoring

- **Standard monitoring** — one data point every 5 minutes. Free, on by default.
- **Detailed monitoring** — one data point every 1 minute. Costs extra per metric.

The tradeoff is reaction time vs cost. A batch job that runs overnight doesn't need 1-minute resolution. A payment API during a flash sale might.

## Why companies actually rely on this

Nobody wants a human staring at a CPU graph all day. In practice, metrics are the input to two things engineers actually care about:

1. **Autoscaling decisions** — an Auto Scaling Group's target-tracking policy is just "watch `CPUUtilization`, add instances when it's high." No alarm, no email, no person involved.
2. **Alarms** (covered next file) — the same numbers become the trigger for "wake someone up."

So a metric by itself doesn't do anything. It becomes useful the moment something else (a scaling policy, an alarm, a dashboard) reads it.

## What metrics can't tell you

A metric tells you **THAT** something changed. It cannot tell you **WHY**.

```
5xx errors: 2 → 4 → 35
```

That graph says "something broke." It says nothing about what. For that you need logs (next file) — the pairing of metric + log is the actual skill here, not either one alone.

## How engineers use this when debugging

When an incident starts, the first move is almost never "grep the logs." It's "open the dashboard, see which number moved." Metrics narrow down *where* to look before you spend time reading *why*. Jumping straight to logs on a system with dozens of services wastes time; the metric tells you which service's logs are worth opening.

## When NOT to reach for a custom metric

Before writing a custom `PutMetricData` call for something, check whether AWS is already tracking it for the resource type you're using. Reinventing `CPUUtilization` with a custom metric is wasted engineering effort — the built-in ones covered in Exercise 1 of the lab are free and already there.
