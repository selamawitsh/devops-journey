# Session 13 — Logs

## What a log actually is

A log is detailed text your application or service writes as it runs. Where a metric is a single number, a log is a sentence (or a stack trace, or a request line) with context attached.

```
10:42:01 GET /orders 200 OK
10:42:03 GET /cart 200 OK
10:42:05 POST /pay 500 ERROR: database timeout
```

CloudWatch Logs organizes these into **log groups** (usually one per application or Lambda function) and **log streams** within a group (usually one per instance or invocation source).

## The pairing that matters

> Metrics tell you THAT something is wrong. Logs tell you WHY.

A metric shows `5xx errors: 2 → 4 → 35`. That's an alert, not an explanation. Opening the log group for that service and searching for `ERROR` around the same timestamp gives you `database timeout` — now you actually know what to fix.

Neither one replaces the other. A system with only metrics tells you something is on fire but not which room. A system with only logs (no aggregated numbers) means you'd have to notice the fire by reading transcripts line by line.

## Logs cost money — this is not a footnote

CloudWatch Logs bills for two separate things:

- **Ingestion** — every byte written into a log group.
- **Storage/retention** — how long those bytes sit there.

By default, log groups retain data **forever** unless you set a retention period. A company that never sets retention will eventually be paying storage costs for years-old debug logs nobody will ever read again. Session's example retention period is **30 days** — long enough to investigate most incidents, short enough that old noise expires automatically.

**When you create a log group, setting a retention period is not optional cleanup — it's a cost control decision you make on day one.**

## How engineers actually search logs

In the console: CloudWatch → Logs → Log groups → open the group → use the filter box for a keyword (`ERROR`, a request ID, a user ID). At any real scale, teams use **CloudWatch Logs Insights** (a query language over log data) instead of manually scrolling — worth knowing the name exists even though this session's lab uses the basic filter box.

## When logs are the wrong tool

Don't use logs to answer a question a metric already answers cheaply. "What's my average CPU over the last hour?" is a metric question — pulling that out of raw log lines (if it were even logged) is slower and more expensive than just looking at the `CPUUtilization` graph. Logs are for **narrative** (what happened, in what order, with what error message) — not for **aggregate numbers over time**.
