# Session 14 — GuardDuty

## The question that's different from the first two files

```
  CloudTrail  asks:  "who did something?"
  Config      asks:  "is my configuration safe?"
  GuardDuty   asks:  "does this behavior look malicious?"
```

The first two tools are about your own account's record-keeping. GuardDuty is the first tool in this session that is actually looking for an adversary.

---

## What GuardDuty actually is

> GuardDuty watches your account's activity for signs of attack or compromise, using AWS threat intelligence and machine learning.

```
  account activity (API calls, network traffic, DNS queries)
                    |
                    v
         +--------------------+
         |     GUARDDUTY      |
         |  threat intel + ML |
         +--------------------+
                    |
                    v
             a FINDING, if something
                looks wrong
```

The important operational detail: **you turn it on, and it works immediately.** No log shipping to configure, no data source to wire up yourself — it plugs into signals AWS already has (CloudTrail, VPC traffic, DNS) and starts scoring them against known attack patterns.

---

## Real findings, read like a security analyst would

```
+--------+------------------------------------------------------+
| HIGH   | your EC2 instance is talking to a known malware      |
|        | server                                                |
+--------+------------------------------------------------------+
| HIGH   | an IAM key is being used from an unusual country     |
+--------+------------------------------------------------------+
| MEDIUM | someone is port-scanning your instances               |
+--------+------------------------------------------------------+
| MEDIUM | login attempts from a known malicious IP              |
+--------+------------------------------------------------------+
```

Read the severities like an actual triage list: HIGH findings usually mean something is already compromised or actively exfiltrating (an instance beaconing to malware infrastructure, credentials used from somewhere they've never been used before). MEDIUM findings are often reconnaissance — someone probing before they try to get in.

---

## The moment this becomes real

```
  Normal:   your key is used from your usual IP, your usual hours

  Suddenly: your key is used from
                  a country you've never logged in from,
                  at 3am your time,
                  launching instances you didn't ask for

  GuardDuty  ->  🚨 HIGH: unusual key usage
```

This is the exact shape of a leaked-credential incident. Nobody had to write a rule saying "watch for logins from unusual countries" — GuardDuty's baseline of your normal activity is what makes the anomaly visible in the first place.

---

## Why the sample findings step in the lab matters

```
  a brand new lab account
             |
             v
  probably has zero real attacks happening
             |
             v
  "Generate sample findings" button
             |
             v
  fake findings, in the real format, so you learn
  to read a finding BEFORE you ever need to under
  real pressure
```

This is the same idea as a fire drill — you want the first time you read a GuardDuty finding to not be during an actual incident.

---

## Where this connects back to Session 13

Your slides state this directly: GuardDuty findings can trigger CloudWatch alarms and emails.

```
   GuardDuty
        |
        v
   suspicious activity found
        |
        v
   CloudWatch  (via an EventBridge rule watching for findings)
        |
        v
      Alarm
        |
        v
       SNS
        |
        v
   your inbox
```

This is why last session mattered for this one. You are not manually opening the GuardDuty console every hour hoping to catch something — you wire the finding into the exact alerting chain you already built. GuardDuty detects; the CloudWatch/SNS pipeline from Session 13 is what actually taps you on the shoulder.

---

## Why companies leave this on permanently

```
  cost of running GuardDuty:      small, scales with account activity
  cost of a MISSED compromise:    leaked credentials, data exfiltration,
                                   a cryptomining bill, reputational damage
```

The session's own habit list says to enable CloudTrail and GuardDuty on day one of a new account — not after something goes wrong. Detection tools are worth the least when you turn them on after the incident has already happened; you want the baseline of "normal" established before an attacker shows up, so the anomaly actually looks anomalous.

---

## What GuardDuty does NOT do

```
  GuardDuty  ->  tells you something looks malicious
  GuardDuty  ->  does NOT block the traffic
  GuardDuty  ->  does NOT filter web requests
```

Detection and blocking are different jobs, handled by different tools. GuardDuty is purely a watcher — turning suspicious activity into something you can act on. Actually stopping traffic at the edge is the next file's job: WAF and Shield.

---

## Active Recall — GuardDuty

**Q1.** In one line, what question does GuardDuty answer that CloudTrail and Config do not?

<details><summary>Answer</summary>
"Does this behavior look malicious?" — CloudTrail answers who did what, Config answers whether configuration is safe; only GuardDuty is actively looking for signs of an attacker.
</details>

**Q2.** What two things power GuardDuty's detection, according to the session?

<details><summary>Answer</summary>
AWS threat intelligence and machine learning.
</details>

**Q3.** How much setup does GuardDuty require to start detecting threats?

<details><summary>Answer</summary>
Almost none — you enable it and it starts working immediately, using signals AWS already collects.
</details>

**Q4.** Why does the lab have you generate sample findings instead of just enabling GuardDuty and waiting?

<details><summary>Answer</summary>
A new, quiet account likely has no real attacks to observe. Sample findings let you practice reading the real finding format and severity levels before you ever need to under real pressure.
</details>

**Q5.** A HIGH finding says an IAM key is being used from an unusual country. What likely happened, and what other tool would you check next, and why?

<details><summary>Answer</summary>
The credential is likely compromised or leaked. Check CloudTrail next, filtered around that time and that user identity, to see exactly what actions the key performed.
</details>

**Q6.** How does GuardDuty connect to what you built in Session 13?

<details><summary>Answer</summary>
A GuardDuty finding can trigger a CloudWatch alarm, which publishes through SNS to your email — so detection doesn't require manually checking the GuardDuty console.
</details>

**Q7.** Does GuardDuty block anything? If not, what's the next tool that does?

<details><summary>Answer</summary>
No, GuardDuty only detects and reports. Blocking malicious web requests is WAF's job, and absorbing traffic floods is Shield's job.
</details>
