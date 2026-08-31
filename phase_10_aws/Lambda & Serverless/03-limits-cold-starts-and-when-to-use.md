# Session 8c · Limits, Cold Starts & When Serverless Fits

## The Fine Print: Limits & Cold Starts

| Limit | Detail |
|---|---|
| **15-minute max** | A single invocation can run up to 15 minutes. For longer jobs, use containers or a different service |
| **Limited local state** | Each invocation is independent — don't rely on data staying in memory between calls. Store state in S3, a database, etc. |
| **Cold starts** | A function that hasn't run recently takes a moment to spin up the first time. Warm functions are instant. Usually milliseconds, but real |
| **Package size limits** | Code and dependencies must fit within size limits. Huge libraries may need a container image instead |

Think of a cold start like a shop that's briefly closed reopening its shutters — there's a
small delay the first time, but once it's open (warm), every next customer is served
instantly.

## When Serverless Fits, And When It Doesn't

| Great for | Reach for something else |
|---|---|
| Event-driven tasks (file uploaded, message arrives) | Long-running jobs (> 15 min) |
| Spiky or unpredictable traffic | Steady, heavy, constant workloads |
| Scheduled jobs and automation | Apps needing lots of in-memory state |
| Lightweight APIs and glue code | Ultra-low-latency with zero tolerance for cold starts |
| Anything idle much of the time | Very large dependencies |

## Lambda Rarely Works Alone

Real serverless apps combine Lambda with other managed services:

| Combo | What it does |
|---|---|
| **API Gateway + Lambda** | A complete web API backend with no servers — requests in, responses out, scales automatically |
| **S3 + Lambda** | Process files the moment they land: thumbnails, virus scans, data extraction |
| **DynamoDB + Lambda** | A serverless database paired with serverless compute — react to data changes instantly |
| **EventBridge + Lambda** | Wire services together with events — the nervous system of an event-driven architecture |

## Key Terms

- **Cold start** — the brief delay when a Lambda spins up after being idle
- **Stateless** — nothing persists in memory between separate invocations
- **Event-driven architecture** — a system design where components react to events rather than being called directly


