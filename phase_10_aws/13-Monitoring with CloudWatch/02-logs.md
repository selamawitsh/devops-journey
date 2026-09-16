# Session 13 — Logs

## Where the previous file left you

```
      5xx errors
       35 |                         *
        5 |         *     *
        0 |   *
          +----------------------------
                                  ^
                                  |
                 you know something broke here
                 you do NOT know what
```

A number cannot carry an explanation. Text can. That text is a log.

---

## What a log looks like

```
+----------------------------------------------------+
|                      app-logs                      |
+----------------------------------------------------+
| 10:42:01   GET  /orders   200   OK                 |
| 10:42:03   GET  /cart     200   OK                 |
| 10:42:05   POST /pay      500   ERROR: db timeout  |   <--
| 10:42:06   POST /pay      500   ERROR: db timeout  |   <--
+----------------------------------------------------+
```

Compare the two side by side:

```
        METRIC                        LOG
  +----------------+       +---------------------------+
  |  errors:  35   |       | 10:42:05 POST /pay 500     |
  |                |       | ERROR: database timeout    |
  +----------------+       +---------------------------+
   one number, no          one event, full context:
   context                 when, what endpoint, what
                           failed, why
```

The metric is the smoke alarm. The log is the fire report.

---

## How CloudWatch organises them

Logs are not one giant pile. They are nested:

```
CloudWatch Logs
    |
    +-- LOG GROUP:  /aws/lambda/process-payment
    |        |
    |        +-- log stream: 2026/09/18/[$LATEST]abc123
    |        +-- log stream: 2026/09/18/[$LATEST]def456
    |
    +-- LOG GROUP:  /var/log/httpd/access
             |
             +-- log stream: i-0a1b2c3d (server 1)
             +-- log stream: i-0e4f5g6h (server 2)
```

```
  LOG GROUP   =  one application or service
  LOG STREAM  =  one source inside it (one instance, one invocation)
```

When you go hunting during an incident, you pick the group (which app) and then search across its streams.

---

## The pairing that is the whole point

```
         SOMETHING IS WRONG
                 |
      +----------+----------+
      |                     |
   METRICS                LOGS
      |                     |
      v                     v
  "THAT it                "WHY it
   happened"               happened"
      |                     |
  errors: 35          ERROR: database timeout
      |                     |
      +----------+----------+
                 |
                 v
        now you can actually fix it
```

Neither half is optional:

```
  metrics only  ->  "the building is on fire, somewhere"
  logs only     ->  you must read every transcript to notice the fire
  both          ->  "fire, second floor, electrical"
```

---

## Logs cost money — and this is where people get burned

CloudWatch Logs bills for two separate things:

```
  your app writes a line
          |
          v
   +--------------+
   |  INGESTION   |   <-- you pay per GB written in
   +--------------+
          |
          v
   +--------------+
   |   STORAGE    |   <-- you pay per GB, per month, for as
   +--------------+       long as it stays
```

Default retention is **never expire**:

```
RETENTION NOT SET
month 1   [####]
month 6   [########################]
month 12  [################################################]
month 24  [################################################################]
                                                  still paying for all of it


RETENTION = 30 DAYS
today     [####]
+30 days  [####]  older lines drop off automatically
+90 days  [####]  cost stays flat
```

Setting retention is a decision you make on day one, not cleanup you do later. Thirty days is the example from the session — long enough to investigate almost any incident, short enough that debug noise from last spring is not on your bill.

---

## How an engineer actually searches logs

Console path:

```
CloudWatch
    |
    v
  Logs
    |
    v
Log groups  --->  pick the group  --->  filter box: "ERROR"
```

What you are really doing is narrowing on two axes at once:

```
                 TIME ------------------------>
              10:40   10:41   10:42   10:43
  service A     .       .       .       .
  service B     .       .      ERR      .    <-- metric said B, so look here
  service C     .       .       .       .
                                ^
                                |
                     alarm fired at 10:42
```

The metric gave you the row. The alarm timestamp gave you the column. The log gives you the sentence in that cell.

At real scale, teams use **CloudWatch Logs Insights** — a query language over the same data — instead of scrolling. Worth knowing the name exists; this session's lab uses the basic filter box.

---

## When logs are the wrong tool

```
QUESTION: "what is my average CPU over the last hour?"

  via logs:     parse thousands of lines, extract numbers,
                average them yourself, slowly, expensively
  via metrics:  open the graph, it is already there
```

```
  LOGS     ->  narrative.  what happened, in order, with what error
  METRICS  ->  aggregate.  how much, how often, trending which way
```

Using logs to answer a metric question is slow and costs ingestion money for data you did not need. Using metrics to answer a log question is impossible.
