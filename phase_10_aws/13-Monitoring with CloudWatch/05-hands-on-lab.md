# Session 13 — Hands-On Lab: Watch Your System

Fill in each blank yourself before checking the answer. Screenshots go in `screenshots/` alongside this file (e.g. `screenshots/01-cpu-graph.png`, `screenshots/03-alarm-in-alarm.png`, `screenshots/04-dashboard.png`).

---

## Exercise 1 — Read the Metrics

Goal: find the numbers AWS is already collecting about a running server. No setup required.

1. Have a server running — reuse or launch a small EC2 instance.
2. Open CloudWatch → Metrics → **______**.
3. Click **______**, then Per-Instance Metrics, and find your instance's `______`.
4. Tick it to graph it.
5. Hover the line and note the normal range — this becomes the number you'll alarm above in Exercise 2.

<details>
<summary>Answer</summary>

2. All metrics
3. EC2 → `CPUUtilization`

</details>

---

## Exercise 2 — An Alarm That Emails You

Goal: create an alarm on CPU and wire it to your email through SNS.

1. In CloudWatch, click Alarms → Create alarm → Select metric → pick your instance's `CPUUtilization`.
2. Set the condition: Greater than **____ %** (deliberately low, so the lab can trip it easily).
3. Under Notification, create a new SNS topic named **______**.
4. Add your email as the endpoint. AWS sends a confirmation message.
5. Open your inbox and click **______**. Without this step the alarm reaches no one.
6. Name the alarm **______** and create it. It starts in the OK state.

<details>
<summary>Answer</summary>

2. Greater than 50%
3. `qiyas-alerts`
5. Confirm subscription
6. `high-cpu`

</details>

---

## Exercise 3 — Trigger the Alarm

Goal: push CPU past the line on purpose and watch the whole chain fire.

1. SSH into the EC2 instance the alarm is watching.
2. Install the stress tool: `sudo yum install -y ______`
3. Load the CPU: `______ --cpu 2 --timeout 300s`
4. In CloudWatch Alarms, watch `high-cpu` move from OK to **______** (give it a few minutes).
5. Check your email — a notification should arrive unprompted.
6. When the stress command ends, CPU falls and the alarm returns to OK on its own.

<details>
<summary>Answer</summary>

2. `stress-ng`
3. `stress-ng --cpu 2 --timeout 300s`
4. In alarm

</details>

---

## Exercise 4 — Dashboard, Logs, Clean Up

Goal: put a health screen together, find a cause in the logs, then remove everything you made.

1. In CloudWatch, Dashboards → Create dashboard → name it **______**.
2. Add a Line widget for your EC2 CPU, and a Number widget for the same. Save.
3. Click Logs → Log groups. Open a group (e.g. a Lambda's from Session 8, or the EC2 agent's).
4. Use the filter box to search for a word like **______**.
5. Clean up, in this order: delete the ______, delete the ______, delete the ______, terminate the lab server, and confirm the stress process has stopped.

<details>
<summary>Answer</summary>

1. `qiyas-health`
4. `ERROR`
5. alarm → SNS topic → dashboard

</details>

---

## Lab Reference — The Four Pillars

| Pillar | One-line definition | Example from this lab |
|---|---|---|
| Metric | A number over time | `EC2 CPUUtilization` |
| Alarm | Metric + threshold + action | `CPU > 50% -> SNS` |
| SNS topic | The messenger to your inbox | `qiyas-alerts` (confirm the email!) |
| Dashboard | Widgets on one health screen | CPU, errors, storage |

> Metrics tell you THAT. Logs tell you WHY. Alarms tell you NOW. Dashboards tell you AT A GLANCE.

---

## Final Take-Home Assignment

This is the last take-home of the course. Design a monitoring plan for the app you've built across the previous 12 sessions.

1. List **three alarms** you'd set for a web app with an EC2 fleet and an RDS database. For each: the metric, the threshold, and why it matters.
2. In two sentences, explain the difference between a metric and a log, using an example of a problem where you'd need both.
3. Sketch (in words or a screenshot) a 4-widget health dashboard: what does each widget show?
4. Optional: recreate one alarm end-to-end and confirm the email actually arrives.

Submit to the Google Form or Telegram group.
