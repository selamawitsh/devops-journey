# Session 8d · The Full Compute Spectrum

## The Full Compute Spectrum

Every rung of the ladder, from most control to least management:

```
EC2                     → You manage the server
Containers (EC2 launch) → You manage hosts + containers
Fargate                 → AWS manages the servers
Lambda                  → AWS manages everything but your code
```

**Most control ————————————————————→ Least management.**

This is the real payoff of the compute pillar: every one of these is a genuine option for
running code, and the right choice depends on how much control you need versus how much
undifferentiated server work you're willing to hand off.

## Where Serverless Shows Up in Real Jobs

| Use case | What it looks like |
|---|---|
| **Backends for apps** | API Gateway + Lambda powers mobile/web app backends that scale automatically and cost nothing when idle |
| **Automation & ops** | Scheduled Lambdas clean up resources, rotate logs, send reports — cron jobs with no server to babysit |
| **Data processing** | React to uploads, stream records, transform data on the fly — the workhorse of event pipelines |
| **Glue between services** | Small functions connecting AWS services and third-party APIs — the duct tape of the cloud |

## Quick Recap

| Concept | One-line summary |
|---|---|
| Serverless | Servers exist, but AWS manages them. You bring only code |
| Lambda | A function that runs on an event. Upload code, AWS does the rest |
| Triggers | API Gateway, S3, schedules, queues — something happens, code reacts |
| Pricing | Pay per request + per millisecond. Idle = free. Generous free tier |
| Limits | 15-min max, cold starts, stateless. Great for bursty event-driven work |

## Key Terms

- **Compute spectrum** — the range of options for running code, trading control for less operational burden
- **Undifferentiated heavy lifting** — routine infrastructure work (patching, scaling, provisioning) that doesn't differentiate your product


