# Session 13 — Alarms and SNS

## What an alarm is

An alarm watches a metric and takes an action the moment that metric crosses a line you defined. It has exactly three parts:

1. **Metric** — what are we watching? e.g. `EC2 CPUUtilization`
2. **Threshold** — what's the limit? e.g. "greater than 80% for 5 minutes"
3. **Action** — what happens? e.g. send an email, or trigger auto scaling

```
Metric → Threshold → Action
CPUUtilization → > 80% for 5 min → notify via SNS
```

Note the "for 5 minutes" part in a real threshold, not just "for 1 datapoint." A single 5-second CPU spike is normal noise; a threshold with a sustained duration filters that out so you're not alerted on every blip.

## How the alert actually reaches you: SNS

CloudWatch alarms don't send email themselves — they hand the message to **SNS (Simple Notification Service)**, which is purely a messenger.

```
Alarm fires → SNS topic → Subscribers (email / SMS)
```

An SNS **topic** is just a named mailing list (e.g. `qiyas-alerts`). The alarm publishes one message to the topic; everyone subscribed to that topic receives it. This is why you can wire the same alarm to notify multiple people, or route different alarms to different topics (e.g. `payments-alerts` vs `infra-alerts`), without changing the alarm logic itself.

## The step that gets forgotten: confirming the subscription

When you subscribe an email address to an SNS topic, AWS sends a confirmation email first. **The subscription does nothing until that link is clicked.** An alarm can fire correctly, publish to the topic correctly, and still notify nobody — because the subscription was never confirmed. This is the single most common reason a "working" alarm silently fails in the lab (and in production).

## Why companies are strict about alarm design

The failure mode isn't "not enough alarms" — it's too many bad ones.

> A team getting 200 alarm emails a day will start ignoring all of them, including the one that mattered.

This is alarm fatigue, and it's a real operational problem, not a hypothetical one. The fix is discipline at design time:

- Alarm on things that **actually hurt** (a database about to run out of storage, sustained high error rates) — not on every metric that exists.
- Prefer a threshold with a sustained duration over "any single high reading."
- Route alarms to the team that can actually act on them, not a shared inbox everyone ignores.

## How this looks during an actual incident

3 AM, an alarm fires. The message needs to contain enough for the on-call engineer to act without first opening five consoles: which resource, which metric, what threshold was crossed, and ideally a link straight to the relevant dashboard or log group. An alarm that just says "ALARM: high-cpu" and nothing else forces the responder to go rediscover context that the alarm already had.

## When NOT to use an alarm

Don't alarm on a metric that fluctuates normally without ever indicating a real problem (e.g. momentary CPU spikes during a scheduled batch job you already know about). If a metric is expected to cross a "normal-looking" threshold routinely, either raise the threshold, extend the duration, or don't alarm on it at all — and rely on the dashboard for visibility instead.
