# Session 8b · Triggers & Pricing

## Triggers: What Wakes a Lambda

A Lambda sits idle until an event calls it.

| Trigger | Fires when | Example |
|---|---|---|
| **API Gateway** | An HTTP request hits your API, Lambda runs and returns a response | A signup form posts an email, Lambda saves it and replies OK |
| **File upload** | A file lands in storage, Lambda processes it automatically | A user uploads a photo, Lambda makes a thumbnail of it |
| **Schedule** | Runs on a timer — cron in the cloud | Every night at 2am, Lambda deletes week-old temporary files |
| **New message** | A record or queued message arrives, Lambda reacts to it | An order is placed, Lambda sends a confirmation SMS |

## Pricing: Pay Per Millisecond

You pay for two things: how many times your function runs, and how long each run takes —
billed by the millisecond. No runs, no charge.

| | Detail |
|---|---|
| **Generous free tier** | 1 million requests and 400,000 GB-seconds free every month — most learning and small apps stay free |
| **Billed by the ms** | A function that runs 200ms is billed for 200ms, not a full second. Efficient code costs less |
| **Zero when idle** | No traffic means no bill — a traditional always-on server costs money even doing nothing |

## Key Terms

- **Trigger** — the event source that invokes a Lambda function
- **GB-second** — a Lambda billing unit combining memory allocated and execution time
- **Cron** — a scheduling syntax for running something at fixed times/intervals


