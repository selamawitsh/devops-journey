# Session 14 — AWS Config

## The distinction this whole file rests on

CloudTrail and Config get confused constantly, so pin this down first:

```
   CloudTrail   records   ACTION           "what just happened"
   AWS Config   records   STATE            "what is true right now"
```

Same event, two different questions:

```
  Someone makes an S3 bucket public
              |
     +--------+--------+
     |                 |
     v                 v
  CloudTrail         Config
  "WHO made it        "IS it
   public, and         public
   when?"               RIGHT NOW?"
```

You need both. CloudTrail gives you the culprit and the timestamp for an investigation. Config gives you an ongoing, continuously-updated answer to "is anything currently unsafe" — even for changes that happened before you were watching, or that CloudTrail logs got rotated past.

---

## What Config actually does

> AWS Config tracks how your resources are configured over time, and checks them against rules you define.

```
   YOUR RESOURCES
        |
        v
  +----------------+
  |   AWS CONFIG   |  <-- continuously evaluates
  +----------------+
        |
   +----+----+
   |         |
   v         v
COMPLIANT  NON-COMPLIANT
  (OK)         (flagged)
```

This is not a one-time check. Config keeps evaluating as things change — a bucket that was private yesterday and someone flips public today gets caught on the next evaluation cycle, automatically.

---

## Three examples straight from the session

```
+---------------------------------+------------------+---------------------------------+
| Resource state                  | Verdict          | Why                             |
+---------------------------------+------------------+---------------------------------+
| S3 bucket is public              | NON-COMPLIANT ❌ | rule flags any bucket open      |
|                                   |                  | to the world                    |
+---------------------------------+------------------+---------------------------------+
| EBS volume is encrypted          | COMPLIANT ✅     | rule confirms disks are         |
|                                   |                  | encrypted                       |
+---------------------------------+------------------+---------------------------------+
| Security group allows 0.0.0.0/0  | NON-COMPLIANT ❌ | flags SSH open to the           |
| on SSH                           |                  | whole internet                  |
+---------------------------------+------------------+---------------------------------+
```

Notice the pattern across all three: none of these involve an ongoing attack. They are all "somebody configured this in a way that is a risk waiting to happen." Config's entire job is catching that category of problem before it becomes an incident.

---

## The rule you'll actually deploy in the lab

```
  Rule name:  s3-bucket-public-read-prohibited

  Config asks, for every bucket, continuously:
       "is this one readable by the entire internet?"

  YES  -> NON-COMPLIANT
  NO   -> COMPLIANT
```

One rule, evaluated against every bucket in the account, forever, without you checking manually.

---

## Why companies actually run Config

The direct benefit is catching misconfiguration early. The less obvious but bigger one is **audits**:

```
  Auditor: "Prove that none of your storage is publicly exposed,
            across all 3,000 buckets, as of today."

  Without Config:  someone manually checks 3,000 buckets
  With Config:     one dashboard, already evaluated, already dated
```

Compliance frameworks (PCI-DSS, SOC 2, HIPAA-adjacent work) frequently require exactly this kind of continuous evidence, not a one-time screenshot. Config is what makes "continuous compliance" a real, checkable thing instead of a slogan.

---

## How an engineer uses this day to day

```
  new engineer joins a team
          |
          v
  accidentally leaves a security group open to 0.0.0.0/0
          |
          v
  Config re-evaluates on its next cycle
          |
          v
  rule flips to NON-COMPLIANT
          |
          v
  (often wired to notify, same pattern as a CloudWatch alarm)
```

This is drift detection — the resource "drifted" away from the safe state it was supposed to be in, and Config caught the drift without anyone remembering to go check.

---

## What Config does NOT do

```
  Config  ->  tells you something is unsafe
  Config  ->  does NOT automatically fix it
  Config  ->  does NOT block the change from happening in the first place
```

Config is a detective control, not a preventive one. It notices after the fact — quickly, but after the fact. If you need to stop the public bucket from ever being created, that is IAM permission design (Session 3) working alongside Config, not Config alone. Config's job is "tell me the moment reality drifts from the rule," not "prevent the drift."

---

## Active Recall — AWS Config

**Q1.** Complete the pair: CloudTrail records ______. Config records ______.

<details><summary>Answer</summary>
CloudTrail records the ACTION. Config records the STATE (and judges it against a rule).
</details>

**Q2.** A bucket was made public three weeks ago, before you started monitoring. Which tool tells you it is public right now, and which tool tells you who made it public three weeks ago?

<details><summary>Answer</summary>
Config tells you it is public right now — it continuously re-evaluates regardless of when the change happened. CloudTrail (if the event is still within the 90-day retention) tells you who did it and when.
</details>

**Q3.** Name the exact managed rule used in the lab to catch public S3 buckets.

<details><summary>Answer</summary>
`s3-bucket-public-read-prohibited`
</details>

**Q4.** "Is any of my S3 bucket public?" — which tool, and why not the other candidate?

<details><summary>Answer</summary>
AWS Config — the question is about current configuration state, not about who took an action or whether an attack is underway.
</details>

**Q5.** Why do companies rely on Config specifically for audits, rather than a manual review?

<details><summary>Answer</summary>
Config evaluates continuously and at scale — thousands of resources checked automatically and re-checked as things change — producing dated, checkable evidence, versus someone manually inspecting every resource by hand.
</details>

**Q6.** Does Config prevent a security group from being opened to 0.0.0.0/0? What does it actually do instead?

<details><summary>Answer</summary>
No — Config is detective, not preventive. It flags the resource as NON-COMPLIANT once it evaluates, after the change has already happened. Preventing the change in the first place is an IAM permissions question.
</details>
