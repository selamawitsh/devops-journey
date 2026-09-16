# Session 13 — Whole-Session Active Recall

Use this after finishing files 01 to 05 and the lab. The per-file questions test one topic at a time; this file mixes them, which is harder and closer to how you will actually need the knowledge.

How to use it:

```
  first pass   ->  immediately after the lab
  second pass  ->  next day, cold, no re-reading
  third pass   ->  one week later
```

Mark anything you had to peek at. Only the marked ones need a third pass.

---

## Round 1 — Rapid fire

Answer each in under ten seconds. No partial credit.

**1.** Metric = ?
**2.** Log = ?
**3.** Alarm = ? (three words joined by plus signs)
**4.** SNS = ?
**5.** Dashboard = ?
**6.** Standard monitoring interval = ?
**7.** Detailed monitoring interval = ?
**8.** Example log retention period = ?
**9.** The two alarm states = ?
**10.** The four-verb sentence = ?

<details><summary>Answers</summary>

1. A number tracked over time.
2. Detailed text an application or service writes.
3. Metric + threshold + action.
4. Simple Notification Service — the messenger that delivers alarm messages to subscribers.
5. One screen of widgets showing system health at a glance.
6. 5 minutes (free, default).
7. 1 minute (costs extra).
8. 30 days.
9. OK and In alarm.
10. Metrics tell you THAT. Logs tell you WHY. Alarms tell you NOW. Dashboards tell you AT A GLANCE.

</details>

---

## Round 2 — Trace the chain

Fill in every blank in the flow from memory:

```
  EC2 CPU hits 90%
        |
        v
  CloudWatch records it as a ____________
        |
        v
  your ____________ compares it to a threshold of ____________
        |
        v
  state flips from ________ to ________
        |
        v
  the alarm publishes to an ____________
        |
        v
  every ____________ subscriber receives the message
        |
        v
  you open the ____________ to find out WHY
        |
        v
  you glance at the ____________ to see whether anything else is affected
```

<details><summary>Answers</summary>

metric -> alarm -> (whatever you set, e.g. 80%) -> OK to In alarm -> SNS topic -> confirmed -> logs -> dashboard

The word "confirmed" is the one most people miss.

</details>

---

## Round 3 — Scenarios

These are the session's discussion questions. Write real answers, not one-liners.

**S1.** Your team gets 200 alarm emails a day and ignores all of them. What went wrong, and how do you fix it?

<details><summary>Model answer</summary>
Alarms were created on everything measurable rather than on the few things that indicate real trouble, and likely without sustained durations, so normal spikes fire alerts. The result is alarm fatigue: the team stops reading alerts, which means the one that mattered gets deleted with the rest. Fix by deleting alarms nobody has ever acted on, raising thresholds and adding durations to the survivors, and routing each remaining alarm to the specific team that can act on it rather than a shared inbox.
</details>

**S2.** An app is "slow" but every metric looks normal. Where do you look next, and what might the metrics be missing?

<details><summary>Model answer</summary>
Go to the logs for the request path users are complaining about, and look at timestamps between stages rather than at error counts. Infrastructure metrics like CPU and network can look healthy while the application is waiting — on a database query, an external API, a lock. The missing measurement is usually latency of the specific operation, which is an application-level metric nobody published, not something AWS collects for you. This is exactly the custom-metric case.
</details>

**S3.** You are woken at 3am by an alarm. What should that alarm's message contain to help you act fast?

<details><summary>Model answer</summary>
Which resource (instance ID and a human name), which metric, the threshold that was crossed, the actual value, when it started, and links straight to the relevant dashboard and log group. The alarm already had all of this at the moment it fired, so including it costs nothing and saves the responder ten minutes of rediscovery while the system is down.
</details>

**S4.** An alarm is in the OK state, the SNS topic exists, the threshold is correct, and no email ever arrives. Diagnose it.

<details><summary>Model answer</summary>
Almost certainly an unconfirmed email subscription — the confirmation link was never clicked, so the subscription sits in "Pending confirmation" and SNS delivers to nobody. Check the topic's subscription status directly. Secondary possibilities: the alarm never actually crossed the threshold (check its history), or the confirmation mail went to spam.
</details>

**S5.** A colleague proposes enabling detailed monitoring on every resource in the account "so we see problems faster." Respond.

<details><summary>Model answer</summary>
Detailed monitoring is 1-minute resolution and is billed per metric, so account-wide it is a real recurring cost. The question to ask per resource is how fast you must actually react: a payment API during peak traffic may justify it; a nightly batch worker does not, because nothing changes in the four minutes you would save. Enable it where reaction time has a cost attached, not by default.
</details>

---

## Round 4 — Design under constraints

**D1.** Design three alarms for a web app with an EC2 fleet behind a load balancer and an RDS database. For each give metric, threshold, and why it matters. No two may watch the same service.

<details><summary>One valid answer</summary>

1. RDS FreeStorageSpace below 2 GB — a full database disk stops writes entirely and is slow to recover from; this gives you hours of warning.
2. ALB HTTPCode_Target_5XX above 20 over 5 minutes — users are visibly failing right now, whatever the cause.
3. EC2 fleet average CPUUtilization above 80% for 10 minutes — the fleet is saturating and scaling is not keeping up.

Note each one is a different failure mode, not three views of the same one.

</details>

**D2.** Sketch a four-widget dashboard for the same app, and justify why each widget earns its place.

<details><summary>One valid answer</summary>

EC2 fleet CPU (line — shows trend and whether scaling is coping), RDS free storage (number — a slow-moving value where the current figure is what matters), 5xx responses over the last hour (line — spikes are meaningful in shape, not just magnitude), healthy target count (number — immediately reveals instances dropping out).

Each answers a question someone actually asks. Anything that has never changed state does not belong.

</details>

**D3.** You have a fixed monitoring budget. Rank these by what you would cut first: detailed monitoring on all instances, 90-day log retention, a second SNS topic for on-call routing, a dashboard.

<details><summary>Reasoning</summary>

Cut detailed monitoring first — it is the largest recurring cost with the least benefit on most resources, and standard 5-minute resolution is adequate for anything not latency-critical. Then trim log retention from 90 to 30 days, which is enough for almost any investigation. The SNS topic and the dashboard cost effectively nothing and directly reduce time-to-respond, so they are the last things you would ever cut.

</details>

---

## Self-check scorecard

```
+--------------------------------------+--------+--------+--------+
| Round                                | pass 1 | pass 2 | pass 3 |
+--------------------------------------+--------+--------+--------+
| 1. Rapid fire (x/10)                 |        |        |        |
| 2. Trace the chain (x/8 blanks)      |        |        |        |
| 3. Scenarios (answered without peek) |        |        |        |
| 4. Design (answered without peek)    |        |        |        |
+--------------------------------------+--------+--------+--------+
```

If Round 1 is not 10/10 cold on the second pass, re-read files 01 to 04 before attempting Round 3 again. The rapid-fire answers are the vocabulary everything else is built on.
