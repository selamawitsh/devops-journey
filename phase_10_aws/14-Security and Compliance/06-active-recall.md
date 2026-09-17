# Session 14 — Whole-Session Active Recall

Use this after finishing files 01 to 05 and the lab. The per-file questions test one tool at a time; this file mixes all five, which is closer to how you will actually need to route a real question.

```
  first pass   ->  immediately after the lab
  second pass  ->  next day, cold, no re-reading
  third pass   ->  one week later
```

Mark anything you had to peek at. Only the marked ones need a third pass.

---

## Round 1 — Rapid fire

Answer each in under ten seconds.

**1.** CloudTrail = ?
**2.** AWS Config = ?
**3.** GuardDuty = ?
**4.** WAF = ?
**5.** Shield = ?
**6.** CloudTrail retention, free, by default = ?
**7.** The managed Config rule for public S3 buckets = ?
**8.** The two things powering GuardDuty's detection = ?
**9.** What WAF inspects vs what Shield inspects = ?
**10.** The three security layers, in order = ?

<details><summary>Answers</summary>

1. Who did what, when, from where — the account's security camera.
2. Watches whether resources stay configured safely — action vs state.
3. Detects malicious or suspicious activity using threat intelligence and machine learning.
4. Web Application Firewall — filters individual web requests by content.
5. DDoS protection — absorbs floods of traffic.
6. 90 days.
7. `s3-bucket-public-read-prohibited`
8. AWS threat intelligence and machine learning.
9. WAF inspects the content of individual requests; Shield inspects the volume of overall traffic.
10. Control access (IAM) -> Watch what happens (CloudTrail, Config, GuardDuty) -> Block attacks (WAF, Shield).

</details>

---

## Round 2 — Route the question

For each question below, name the one tool that answers it, from memory.

```
  1. Who deleted that database?
  2. Is any S3 bucket public right now?
  3. Is an attacker inside my account?
  4. Block SQL injection on my website.
  5. Survive a traffic flood attack.
  6. An EC2 instance is talking to a known malware server — how would you find out?
  7. A security group allows SSH from 0.0.0.0/0 — which tool would have flagged this, continuously, even if nobody noticed the change happen?
  8. Someone's login attempt came from a known malicious IP — which tool raised that?
```

<details><summary>Answers</summary>

1. CloudTrail
2. AWS Config
3. GuardDuty
4. WAF
5. Shield
6. GuardDuty (it raises this exact finding)
7. AWS Config (continuous evaluation, independent of when the change happened)
8. GuardDuty

</details>

---

## Round 3 — Trace a compromise, tool by tool

Fill in every blank in the flow from memory:

```
  An attacker gets hold of a leaked AWS key.
        |
        v
  Attacker launches an EC2 instance.
        |
        v
  ____________ records: WHO, WHAT, WHEN, WHERE, and that it succeeded.
        |
        v
  Attacker makes an S3 bucket public.
        |
        v
  ____________ evaluates the bucket on its next cycle and marks it ______________.
        |
        v
  The compromised key is used from a country it has never logged in from.
        |
        v
  ____________ raises a HIGH finding for unusual key usage.
        |
        v
  That finding is wired (via a CloudWatch alarm and SNS) straight to your ______________.
        |
        v
  Attacker also sends malicious requests at your public website.
        |
        v
  ____________ blocks the requests before they reach the app.
        |
        v
  Attacker adds a traffic flood on top.
        |
        v
  ____________ absorbs it.
```

<details><summary>Answers</summary>

CloudTrail -> Config, NON-COMPLIANT -> GuardDuty -> inbox/email -> WAF -> Shield

</details>

---

## Round 4 — Scenarios

Write real answers, not one-liners.

**S1.** Which is scarier: an attacker getting into your account, or not knowing they got in? Why?

<details><summary>Model answer</summary>
Not knowing is scarier in practice, because an attacker who is detected can be locked out and the damage bounded — CloudTrail shows exactly what they touched, and access can be revoked. An undetected attacker has unlimited time to escalate privileges, exfiltrate data, or plant persistence, and every day undetected multiplies the eventual cleanup cost. This is the entire argument for running GuardDuty continuously rather than only investigating after something looks visibly wrong.
</details>

**S2.** You find a CloudTrail event you don't recognize. What are your next three steps?

<details><summary>Model answer</summary>
First, read the full event: eventName, userIdentity, sourceIP, and result, to understand exactly what was attempted and whether it succeeded. Second, check GuardDuty for any related findings around that timestamp or user identity, since an unrecognized action is exactly the kind of signal GuardDuty might have already flagged. Third, if the action modified a resource, check AWS Config for that resource's current compliance state — did the unrecognized action leave something in an unsafe configuration right now.
</details>

**S3.** Is it worth paying for GuardDuty on a small personal learning project? When would it be worth it?

<details><summary>Model answer</summary>
For a genuinely small, disposable learning account with no real credentials or data at stake, the cost may not be justified full-time — the free trial period is enough to learn the tool's shape. It becomes worth it the moment the account holds anything real: production credentials, real user data, or a billing method that could be abused for cryptomining if compromised. The habit worth keeping regardless of GuardDuty is: CloudTrail costs nothing and should always stay on.
</details>

**S4.** A student's leaked AWS key is used to mine cryptocurrency for a week before anyone notices. Which tools would have caught it, and at what point in the timeline?

<details><summary>Model answer</summary>
GuardDuty would likely have raised a HIGH finding almost immediately — unusual instance types being launched, unusual regions, or an API call pattern inconsistent with the account's normal behavior. CloudTrail would show the exact RunInstances calls, from which source IP, the moment they happened, giving a full record for cleanup and reporting. AWS Config would separately flag any resulting unsafe configuration changes. The point is that none of these tools required a week's delay — the week-long gap in this scenario is a detection-and-alerting failure, not a tooling gap, which is exactly why wiring GuardDuty findings into a CloudWatch alarm (Session 13) matters: detection without notification is nearly as slow as no detection at all.
</details>

---

## Round 5 — Design under constraints

**D1.** Write a five-item security checklist for a brand-new AWS account, in priority order, with one reason each.

<details><summary>One valid answer</summary>

1. Enable MFA on the root user and stop using it for daily work — root has unlimited power, so it is the single highest-value target to protect first.
2. Create IAM users/roles for actual work, following least privilege — limits the blast radius if any one credential is later compromised.
3. Enable CloudTrail (often already on) and confirm event history is retained — establishes the audit trail before anything happens, not after.
4. Enable GuardDuty — establishes a baseline of "normal" activity early, so future anomalies are actually detectable as anomalies.
5. Restrict SSH access away from 0.0.0.0/0 on every security group — closes the single most common real-world misconfiguration named in the session.

</details>

**D2.** A company's e-commerce site experiences both a SQL injection attempt and a volumetric DDoS attack in the same week. Explain why one tool alone would not have covered both.

<details><summary>Reasoning</summary>

WAF inspects the content of requests, so it can catch the SQL injection attempt regardless of how much traffic accompanies it. It does not solve a volume problem — a flood of otherwise well-formed requests can still exhaust infrastructure. Shield is built for exactly that volume problem but does not inspect request content, so a single well-crafted malicious request sent at normal volume passes through unnoticed. The two failure modes are different in kind, which is why defense in depth pairs both rather than treating either as sufficient alone.

</details>

---

## Self-check scorecard

```
+--------------------------------------+--------+--------+--------+
| Round                                | pass 1 | pass 2 | pass 3 |
+--------------------------------------+--------+--------+--------+
| 1. Rapid fire (x/10)                 |        |        |        |
| 2. Route the question (x/8)          |        |        |        |
| 3. Trace a compromise (x/7 blanks)   |        |        |        |
| 4. Scenarios (answered without peek) |        |        |        |
| 5. Design (answered without peek)    |        |        |        |
+--------------------------------------+--------+--------+--------+
```

If Round 1 is not 10/10 cold on the second pass, re-read files 01 to 04 before attempting Round 4 again. The five-tool vocabulary is what every later question in this session is built on.
