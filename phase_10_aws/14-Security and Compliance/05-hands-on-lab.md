# Session 14 — Hands-On Lab: Watch and Defend Your Account

What you are about to build, end to end:

```
   CloudTrail (already recording)
        |
        v
   read your own audit trail
                                   GuardDuty
                                        |
                                        v
                              enable + generate sample findings
                                                       AWS Config
                                                            |
                                                            v
                                              s3-bucket-public-read-prohibited
                                              COMPLIANT / NON-COMPLIANT
                                                                       WAF
                                                                        |
                                                                        v
                                                          design a rate-limit rule
                                                          (paper only, then clean up)
```

Fill in each blank yourself before opening the answer. Screenshots go in `screenshots/` next to this file (e.g. `screenshots/01-cloudtrail-event.png`, `screenshots/02-guardduty-finding.png`, `screenshots/03-config-noncompliant.png`).

---

## Exercise 1 — Read Your Audit Trail

Goal: see exactly who did what in your account. Nothing to configure — CloudTrail has been recording all along.

```
  AWS Console
      |
      v
  ____________     (step 1)
      |
      v
   Event history
      |
      v
  list of actions: time, user, event name
```

1. Open CloudTrail, click **______**.
2. Look at recent events — you see time, user, and event name.
3. Open one event and expand it to see the full record.
4. Filter by event name for **______** to find every time an instance was launched.
5. Filter by your own user name to find your own actions.

<details>
<summary>Answer</summary>

1. Event history
4. `RunInstances`

</details>

---

## Exercise 2 — Turn On the Threat Detector

Goal: enable GuardDuty and see what a real finding looks like, without waiting for a real attack.

```
  GuardDuty
      |
      v
  Get Started -> Enable GuardDuty   (____-day trial is free)
      |
      v
  Settings -> "____________"
      |
      v
  Findings   <-- fake, but real format
```

1. Open GuardDuty from the search bar.
2. Click Get Started, then Enable GuardDuty. The **____**-day trial is free.
3. In Settings, click **"______________"** so you have something to read on a quiet account.
4. Open Findings — you should see sample HIGH and MEDIUM alerts.
5. Click into one finding to see the affected resource and why it was flagged.

<details>
<summary>Answer</summary>

2. 30-day trial
3. "Generate sample findings"

</details>

---

## Exercise 3 — Add a Safety Rule

Goal: use AWS Config to automatically and continuously flag public S3 buckets.

```
  AWS Config
      |
      v
  Get started (if new) -> accept default recorder + delivery
      |
      v
  Add a managed rule: "____________________________"
      |
      v
  Config evaluates your buckets
      |
      v
  each bucket shows:  COMPLIANT   or   NON-COMPLIANT
```

1. Open AWS Config, click Get started if this is a new setup.
2. Accept the defaults for the recorder and delivery, click Next.
3. Search the managed rules for **______________________________** and add it.
4. Wait a minute or two for Config to evaluate your buckets against the rule.
5. Open the rule and read the compliance results.

```
   any public bucket in your account shows as:  ______________
```

<details>
<summary>Answer</summary>

3. `s3-bucket-public-read-prohibited`

Step 5: NON-COMPLIANT

</details>

---

## Exercise 4 — Plan a WAF Rule, Then Clean Up

Goal: design a rate-limiting WAF rule on paper (no real deployment cost), then shut down anything that bills.

```
  Rule to design:
    block any IP making more than ______ requests
    in ______ minutes
```

1. Sketch the rule: block any IP making more than **____** requests in **____** minutes. This is called **______________**.
2. Note where it would attach: a WAF **______** attaches to CloudFront or a **______________**, in front of your app.
3. Disable GuardDuty in Settings so the trial does not bill later.
4. Delete the Config rule and stop the recorder so Config stops charging.
5. Confirm the only thing still running is **______**, because it is free.

```
   cleanup order:
   [ ] disable ____________
   [ ] delete ____________ and stop the recorder
   [ ] confirm ____________ is the only thing left on
```

<details>
<summary>Answer</summary>

1. 1000 requests, 5 minutes — rate limiting
2. Web ACL, load balancer
5. CloudTrail

Cleanup order: GuardDuty -> Config rule + recorder -> confirm CloudTrail is the only thing left running.

</details>

---

## Lab Reference — The Five Tools

```
+==============================+==============================+
| Tool          | Question it answers                          |
+==============================+==============================+
| CloudTrail    | who did what?                                |
| AWS Config    | is it configured safely?                     |
| GuardDuty     | is someone attacking?                        |
| WAF           | block bad web requests                       |
| Shield        | absorb DDoS floods                           |
+==============================+==============================+
```

CLI reference used in Exercise 1:

```bash
# recent account actions
aws cloudtrail lookup-events --max-results 5

# who launched instances?
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances
```

---

## Take-Home Assignment

Write a one-page security checklist for a brand-new AWS account.

1. List the **first five things** you would do to secure a brand-new account. Think IAM, MFA, CloudTrail, GuardDuty, and the SSH rule.
2. For each of the five, write **one sentence** on WHY it matters.

```
   1. ________________________  why: ________________________
   2. ________________________  why: ________________________
   3. ________________________  why: ________________________
   4. ________________________  why: ________________________
   5. ________________________  why: ________________________
```

**Submit:** a screenshot of one CloudTrail event you found (your own action), plus your one-page checklist, to the Google Form or the Telegram group.
