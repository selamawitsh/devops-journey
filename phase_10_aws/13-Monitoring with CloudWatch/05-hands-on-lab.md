# Session 13 — Hands-On Lab: Watch Your System

What you are about to build, end to end:

```
   EC2 instance  ---> CPUUtilization ---> CloudWatch metric
   (you stress it)                              |
                                                v
                                          high-cpu ALARM
                                          (> 50%)
                                                |
                                                v
                                        SNS topic "qiyas-alerts"
                                                |
                                                v
                                          your inbox

   and separately:

   the same metric  --->  dashboard "qiyas-health"
   log groups       --->  filter for ERROR
```

Fill in each blank yourself before opening the answer. Screenshots go in `screenshots/` next to this file (e.g. `screenshots/01-cpu-graph.png`, `screenshots/03-alarm-in-alarm.png`, `screenshots/04-dashboard.png`).

---

## Exercise 1 — Read the Metrics

Goal: find numbers AWS is already collecting. You configure nothing.

Navigation path:

```
  AWS Console
      |
      v
  CloudWatch
      |
      v
   Metrics
      |
      v
  ____________     (step 2)
      |
      v
  ____________     (step 3)
      |
      v
  Per-Instance Metrics
      |
      v
  ____________     (step 3)
```

1. Have a server running — reuse or launch a small EC2 instance so there is something to watch.
2. Open CloudWatch, click Metrics, then **______**.
3. Click **______**, then Per-Instance Metrics, and find your instance's **______**.
4. Tick the checkbox to graph it. A line appears:

```
 CPU %
  100 |
   80 |
   60 |
   40 |          _________
   20 |  _______/
    0 +--------------------------
              time ->
```

5. Hover the line to read values. Write down the normal range — this is the "normal" you will alarm above:

```
   my instance's idle CPU sits around ______ %
```

<details>
<summary>Answer</summary>

2. All metrics
3. EC2 -> `CPUUtilization`

Step 5 is yours to observe. A small idle instance is usually in the low single digits.

</details>

---

## Exercise 2 — An Alarm That Emails You

Goal: build metric + threshold + action, and wire the action to your inbox.

What you are assembling:

```
  +------------------+
  | METRIC           |   CPUUtilization on your instance
  +------------------+
           |
  +------------------+
  | THRESHOLD        |   greater than ____ %
  +------------------+
           |
  +------------------+
  | ACTION           |   publish to SNS topic ____________
  +------------------+
           |
           v
     your email  (must be CONFIRMED)
```

1. CloudWatch -> Alarms -> Create alarm -> Select metric -> your instance's `CPUUtilization`.
2. Set the condition: Greater than **____ %**. This line is deliberately low so the lab can trip it.
3. Under Notification, create a new SNS topic named **______**.
4. Enter your email as the endpoint. AWS sends a confirmation message.
5. Open your inbox and click **______**.

```
   subscription status before clicking:  ____________________
   subscription status after clicking:   ____________________
```

6. Name the alarm **______** and create it. It starts in the ____ state.

<details>
<summary>Answer</summary>

2. Greater than 50%
3. `qiyas-alerts`
5. Confirm subscription — status goes from "Pending confirmation" to "Confirmed"
6. `high-cpu`, starts in **OK**

</details>

---

## Exercise 3 — Trigger the Alarm

Goal: cause the problem on purpose and watch the whole chain fire.

```
  you run stress-ng
        |
        v
  CPU climbs past 50%
        |
        v
  CloudWatch sees it (give it a few minutes)
        |
        v
  alarm:  OK  ---->  IN ALARM
        |
        v
  SNS publishes
        |
        v
  email arrives, unprompted
        |
        v
  stress ends, CPU falls
        |
        v
  alarm:  IN ALARM  ---->  OK   (by itself)
```

1. SSH into the EC2 instance the alarm is watching.
2. Install the stress tool:

```bash
sudo yum install -y ________
```

3. Load the CPU for five minutes:

```bash
________ --cpu 2 --timeout 300s
```

4. In CloudWatch -> Alarms, watch `high-cpu` move from OK to **______**.

```
   time I started stress:        __________
   time the alarm flipped:       __________
   delay between them:           __________   <-- this is your metric resolution at work
```

5. Check your email. Take a screenshot of the notification.
6. Let it recover. Confirm the alarm returns to OK with no action from you.

<details>
<summary>Answer</summary>

2. `stress-ng`
3. `stress-ng --cpu 2 --timeout 300s`
4. **In alarm**

The delay in step 4 is expected — standard monitoring records a data point every 5 minutes, and the alarm needs a data point above the line before it can flip.

</details>

---

## Exercise 4 — Dashboard, Logs, Clean Up

Goal: build a health screen, find a cause in the logs, then remove everything.

Target dashboard:

```
+=================================+
|          ____________           |   (step 1: name it)
+================+================+
|  EC2 CPU       |  EC2 CPU       |
|  (Line widget) |  (Number)      |
|                |                |
|  80|      *    |                |
|  40| * *  *    |      42%       |
|   0+--------   |                |
+================+================+
```

1. CloudWatch -> Dashboards -> Create dashboard -> name it **______**.
2. Add a Line widget for your EC2 CPU, and a Number widget for the same metric. Save.
3. CloudWatch -> Logs -> Log groups. Open a group (e.g. a Lambda's from Session 8, or the EC2 agent's).
4. Use the filter box to search for **______**.

```
   metric said:  ______________________   (THAT)
   log said:     ______________________   (WHY)
```

5. Clean up, in this order:

```
   [ ] delete the ____________
   [ ] delete the ____________
   [ ] delete the ____________
   [ ] terminate the lab EC2 instance
   [ ] confirm no stress process is still running
```

<details>
<summary>Answer</summary>

1. `qiyas-health`
4. `ERROR`
5. alarm -> SNS topic -> dashboard -> terminate instance -> confirm stress stopped

Delete the alarm before the SNS topic, otherwise you leave an alarm pointing at a topic that no longer exists.

</details>

---

## Lab Reference — The Four Pillars

```
+==============================+==============================+
| METRIC                       | ALARM                        |
|                              |                              |
| a number over time           | metric + threshold + action  |
| CloudWatch > Metrics         |                              |
|                              |   CPU > 50%  ->  SNS         |
|   EC2 CPUUtilization         |                              |
+==============================+==============================+
| SNS TOPIC                    | DASHBOARD                    |
|                              |                              |
| the messenger to your inbox  | widgets on one health screen |
|                              |                              |
|   confirm the email!         |   CPU, errors, storage       |
+==============================+==============================+
```

```
   Metrics tell you THAT.
   Logs tell you WHY.
   Alarms tell you NOW.
   Dashboards tell you AT A GLANCE.
```

---

## Final Take-Home Assignment

This is the last take-home of the course. Design a monitoring plan for the app you have built across the previous 12 sessions.

**1.** List **three alarms** you would set for a web app with an EC2 fleet and an RDS database. For each, fill in all three parts:

```
   Alarm 1:  metric = ______________  threshold = ______  why it matters: ______
   Alarm 2:  metric = ______________  threshold = ______  why it matters: ______
   Alarm 3:  metric = ______________  threshold = ______  why it matters: ______
```

**2.** In two sentences, explain the difference between a metric and a log, using an example of a problem where you would need both.

**3.** Sketch a 4-widget health dashboard — in words or a screenshot. What does each widget show, and why does it earn its place?

```
+=================+=================+
|                 |                 |
|                 |                 |
+=================+=================+
|                 |                 |
|                 |                 |
+=================+=================+
```

**4.** Optional: recreate one alarm end to end and confirm the email actually arrives.

Submit to the Google Form or Telegram group.
