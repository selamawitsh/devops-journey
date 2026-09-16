# Session 13 — Dashboards and Good Habits

## What a dashboard is

A dashboard is one screen, made of widgets, each showing a metric (or a log search) at a glance. Nothing computed here is new — a dashboard doesn't create data, it just arranges data you already have so you don't have to open five separate metric pages to check on a system.

```
EC2 CPU %        RDS free storage
   42%               18 GB

Lambda errors    5xx responses
    0                 2
```

## Why companies build these instead of just using alarms

Alarms tell you when something crosses a line. A dashboard answers a different question: "is everything currently fine, generally?" — the kind of check someone does at the start of a shift, or pulls up on a shared screen in an ops room. Alarms are for the moment something goes wrong; dashboards are for the ongoing sense of "where do things stand right now."

Both matter, and they're not substitutes for each other — an alarm you can silence, a dashboard you glance at whenever you want.

## Good habits and gotchas (this is the part worth memorizing)

| Habit | Why it matters |
|---|---|
| Alarm on what hurts, not everything | Prevents alarm fatigue — see the alarms file |
| Set a log retention period (e.g. 30 days) | CloudWatch Logs bills for ingestion and storage; unset retention means paying to store logs forever |
| Standard (5 min) vs detailed (1 min) monitoring | Detailed monitoring costs extra — only pay for it if you genuinely need to react faster than 5 minutes |
| Confirm the SNS email subscription | An unconfirmed subscription means a "working" alarm notifies no one |

None of these are AWS trivia for its own sake — each one is a real cost or a real outage waiting to happen if skipped.

## The full picture, tied together

This is the sentence the whole session is built around:

> **Metrics tell you THAT. Logs tell you WHY. Alarms tell you NOW. Dashboards tell you AT A GLANCE.**

Worked as a single incident:

1. **Metric** — `5xx errors` spikes upward. This is the "THAT."
2. **Alarm** — you'd configured `5xx errors > 20` as the threshold. It fires.
3. **SNS** — the alarm publishes to a topic, which emails you. This is the "NOW."
4. **Logs** — you open the log group and search for `ERROR`. You find `database timeout`. This is the "WHY."
5. **Dashboard** — while investigating, the dashboard shows the rest of the system (CPU, storage, Lambda errors) so you can tell whether this is isolated or part of something bigger. This is "AT A GLANCE."

That's the entire operating model for watching a system in production. Every piece in this session exists to serve one of those four verbs.

## When a dashboard isn't the fix

If a dashboard has a widget that's permanently green and nobody's ever looked at when it turned red, that widget isn't earning its place — it's decoration. A dashboard should be built around the handful of numbers someone actually checks, not every metric that happens to exist for a resource.
