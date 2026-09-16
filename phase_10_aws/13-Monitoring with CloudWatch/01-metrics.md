# Session 13 — Metrics

## The problem before the solution

You have built something on AWS. It is running right now:

```
        YOUR APPLICATION
              |
   +----------+----------+
   |          |          |
  EC2        RDS      Lambda
 server    database  functions
```

Today everything is fine. Tomorrow, one of these goes wrong:

```
  EC2                RDS              Lambda
  CPU 95%      storage 99% full     errors rising
   |                  |                  |
   +------------------+------------------+
                      |
              users see errors
                      |
              and you are asleep
```

You cannot sit at a screen 24 hours a day watching for this. Something else has to watch. That something is CloudWatch, and the raw material it watches is **metrics**.

---

## What a metric actually is

One number, tracked over time. That is the entire definition.

```
CPUUtilization

 100 |
  80 |                              *
  60 |                        *
  40 |            *     *
  20 |   *   *
   0 +---+---+----+-----+-----+-----+----
     10:00  10:05 10:10 10:15 10:20 10:25
```

Same data as a list:

```
10:00  ->  CPU 30%
10:05  ->  CPU 35%
10:10  ->  CPU 42%
10:15  ->  CPU 78%
10:20  ->  CPU 91%      <-- something changed here
```

The number by itself is boring. The number **over time** is where the meaning lives — 91% means nothing until you can see it used to be 30%.

---

## Metrics you get for free, per service

AWS measures your resources automatically. You write no code, install no agent, configure nothing.

```
+------------------+------------------+------------------+
|       EC2        |       RDS        |     LAMBDA       |
+------------------+------------------+------------------+
| CPUUtilization   | CPUUtilization   | Invocations      |
| NetworkIn        | FreeStorageSpace | Errors           |
| NetworkOut       | DatabaseConn.    | Duration         |
| DiskReadOps      | ReadIOPS         | Throttles        |
+------------------+------------------+------------------+
| "is this server  | "is the disk     | "are my          |
|  overloaded?"    |  about to fill?" |  functions       |
|                  |                  |  failing?"       |
+------------------+------------------+------------------+
```

Each column answers a different operational question. Notice each one is a question a human would actually ask at 3am.

---

## How often the number is recorded

This is a cost decision, not a technical one.

```
STANDARD MONITORING (free, default)
  |     |     |     |     |     |
  x-----x-----x-----x-----x-----x
  0     5     10    15    20    25   minutes
  one data point every 5 minutes


DETAILED MONITORING (costs extra)
  | | | | | | | | | | | | | | | | |
  x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
  0 1 2 3 4 5 6 7 8 9 ...          minutes
  one data point every 1 minute
```

What that difference means in practice:

```
Problem starts at 10:00:30

Standard:  you might not see it until 10:05  (4.5 min blind)
Detailed:  you see it at 10:01               (30 sec blind)
```

A nightly batch job does not need 1-minute resolution. A payment API during a sale might. Match the resolution to how fast you actually have to react — and pay accordingly.

---

## What a metric cannot do

This is the limitation that shapes the whole rest of the session.

```
      5xx errors
       35 |                         *
       20 |                    *
        5 |         *     *
        0 |   *
          +----------------------------
```

Read that graph out loud. You can say:

```
  "errors went up sharply around 10:42"      <-- YES, the metric tells you this
  "because the database connection timed out" <-- NO, the metric cannot tell you this
```

```
   METRIC  --->  tells you  THAT something happened
   METRIC  -/->  tells you  WHY it happened
```

The WHY lives in logs, which is the next file.

---

## Why companies actually care about metrics

A metric does nothing on its own. It becomes useful the moment something reads it:

```
                    METRIC
                (CPUUtilization)
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
    ALARM         AUTOSCALING     DASHBOARD
        |         POLICY              |
        v              |              v
  "wake someone"       v         "glance and see
                 "add a server"    it is fine"
```

Three different consumers, one source of numbers. That middle branch is worth noticing: an Auto Scaling Group's target-tracking policy is just "watch CPUUtilization, add instances when it is high." No alarm, no email, no human involved at all. Monitoring is not only about telling people — sometimes it is about the system fixing itself.

---

## How engineers actually use this during an incident

The instinct of a beginner is to open the logs first. The instinct of an experienced engineer is to open the dashboard first.

```
ALERT COMES IN
      |
      v
+---------------------------+
| Step 1: which NUMBER moved?  |   <-- metrics narrow WHERE
+---------------------------+
      |
      v
+---------------------------+
| Step 2: read THAT service's  |   <-- logs explain WHY
|         logs, that time window|
+---------------------------+
```

On a system with twenty services, jumping straight to logs means you do not know whose logs to open. The metric tells you which door to walk through before you spend twenty minutes reading the wrong room's transcript.

---

## When NOT to create a metric

Before writing custom code to publish a metric, check whether AWS is already tracking it.

```
  You think:  "I will write code to report CPU usage"
  Reality:    CPUUtilization already exists, free, since day one
```

Reinventing a built-in metric is wasted effort and adds a cost that was already zero. Custom metrics are for things only your application knows — "items in checkout queue", "failed logins per minute" — never for infrastructure numbers AWS already publishes.
