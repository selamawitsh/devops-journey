# Session 13 — Dashboards and Good Habits

## The problem a dashboard solves

Without one, checking on your system looks like this:

```
  open CloudWatch -> Metrics -> EC2 -> per-instance -> CPUUtilization    (tab 1)
  open CloudWatch -> Metrics -> RDS -> FreeStorageSpace                  (tab 2)
  open CloudWatch -> Metrics -> Lambda -> Errors                         (tab 3)
  open CloudWatch -> Metrics -> ALB -> HTTPCode_Target_5XX               (tab 4)
```

Four navigations to answer one question: "is everything fine?"

With a dashboard:

```
  open CloudWatch -> Dashboards -> qiyas-health
```

One click. That is the entire value proposition — a dashboard creates no new data, it just arranges data you already had.

---

## What a dashboard looks like

```
+===========================================================+
|                    qiyas-health                           |
+=============================+=============================+
|  EC2 CPU %                  |  RDS free storage           |
|                             |                             |
|      42%              (OK)  |      18 GB            (OK)  |
|                             |                             |
+=============================+=============================+
|  Lambda errors (1h)         |  5xx responses              |
|                             |                             |
|       0               (OK)  |       2            (WARN)   |
|                             |                             |
+=============================+=============================+
```

Two widget shapes you will build in the lab:

```
   NUMBER WIDGET              LINE WIDGET

   +---------------+          +---------------------------+
   |   EC2 CPU     |          |  EC2 CPU over 3 hours     |
   |               |          |                           |
   |     42%       |          | 80|          *            |
   |               |          | 40|  *  *  *   *  *       |
   +---------------+          |  0+------------------     |
                              +---------------------------+
   "what is it                "what has it been doing,
    right now?"                and where is it heading?"
```

The number answers the present. The line answers the trend. A dashboard usually wants both for anything important — 42% is fine, but 42% after climbing from 10% all morning is a different story.

---

## Dashboard vs alarm — they answer different questions

```
                  ALARM                      DASHBOARD
        +-----------------------+   +--------------------------+
        | pushes to you         |   | you pull from it         |
        | only when a line      |   | whenever you want         |
        | is crossed            |   |                          |
        +-----------------------+   +--------------------------+
        | "something is wrong   |   | "how are things,          |
        |  RIGHT NOW"           |   |  generally?"              |
        +-----------------------+   +--------------------------+
        | 3am, phone buzzing    |   | 9am, coffee, start        |
        |                       |   | of shift                  |
        +-----------------------+   +--------------------------+
```

```
   ALARM      --->  interrupts you
   DASHBOARD  --->  waits for you
```

Neither replaces the other. A team with alarms but no dashboard only ever sees the system when it is broken. A team with a dashboard but no alarms only finds out about 3am outages at 9am.

---

## Good habits and gotchas

Four rules, each one a real cost or a real outage if skipped.

```
+---------------------------------------------------------------+
| 1. ALARM ON WHAT HURTS                                        |
|                                                               |
|    200 alerts/day  ->  everyone ignores all of them           |
|      3 alerts/week ->  everyone reads every one               |
+---------------------------------------------------------------+
| 2. SET LOG RETENTION                                          |
|                                                               |
|    no retention  ->  [########################################]|
|    30 days       ->  [####]  old lines expire, cost stays flat |
+---------------------------------------------------------------+
| 3. STANDARD (5 min, free) vs DETAILED (1 min, paid)           |
|                                                               |
|    x-----x-----x-----x     vs    x-x-x-x-x-x-x-x-x-x          |
|    match it to how fast you actually must react                |
+---------------------------------------------------------------+
| 4. CONFIRM THE SNS SUBSCRIPTION                               |
|                                                               |
|    unconfirmed  ->  alarm fires  ->  SNS publishes  ->  (nothing)|
|    a silent alarm is worse than no alarm                       |
+---------------------------------------------------------------+
```

---

## The complete picture, assembled

Everything in this session is one of four verbs:

```
                        YOUR AWS SYSTEM
                               |
              +----------------+----------------+
              |                                 |
           METRICS                            LOGS
       "THAT it happened"              "WHY it happened"
              |                                 |
              |                                 |
              v                                 |
           ALARM                                |
    "it crossed my line, NOW"                   |
              |                                 |
              v                                 |
            SNS                                 |
      "delivering the news"                     |
              |                                 |
              v                                 |
        your inbox / SMS                        |
                                                |
              +---------------------------------+
              |
              v
          DASHBOARD
   "everything, AT A GLANCE"
```

The sentence the whole session is built around:

```
   Metrics    tell you  THAT
   Logs       tell you  WHY
   Alarms     tell you  NOW
   Dashboards tell you  AT A GLANCE
```

---

## One incident, all five pieces

An online shop. A customer tries to pay. Something breaks.

```
 STEP 1  METRIC
         5xx errors:  2 -> 4 -> 35
         +--------------------------------------+
         | you would know this IF you looked    |
         +--------------------------------------+
                        |
                        v
 STEP 2  ALARM
         you had configured:  5xx errors > 20
         35 > 20  ->  state flips OK -> IN ALARM
                        |
                        v
 STEP 3  SNS
         alarm publishes to topic "shop-alerts"
         topic delivers to your inbox
         +--------------------------------------+
         | you now know WITHOUT having looked   |
         +--------------------------------------+
                        |
                        v
 STEP 4  LOGS
         open the log group, filter "ERROR", 10:42
         >  POST /pay  500  ERROR: database timeout
         +--------------------------------------+
         | you now know WHAT to actually fix    |
         +--------------------------------------+
                        |
                        v
 STEP 5  DASHBOARD
         EC2 CPU       45%    (normal)
         RDS storage   18 GB  (normal)
         5xx errors    35     (the problem)
         Lambda errors  2     (normal)
         +--------------------------------------+
         | isolated to the database path, not   |
         | a system-wide failure. Scope known.  |
         +--------------------------------------+
```

That is the full operating model for watching a system in production. Every feature in this session exists to serve one of those five steps.

---

## When a dashboard is not the fix

```
  +----------------------------------------------------+
  |                   too-many-widgets                 |
  +------+------+------+------+------+------+----------+
  | CPU  | mem  | net  | disk | conn | iops | ...      |
  | 42%  | 61%  | 2MB  | ok   | 12   | 340  |          |
  +------+------+------+------+------+------+----------+
  | ...  | ...  | ...  | ...  | ...  | ...  | 30 more  |
  +------+------+------+------+------+------+----------+

  nobody can "glance" at this. it has stopped being a
  dashboard and become a metrics dump.
```

A widget that has been permanently green and that nobody has ever caught turning red is decoration, not monitoring. Build the dashboard around the handful of numbers someone actually checks — and delete the rest.
