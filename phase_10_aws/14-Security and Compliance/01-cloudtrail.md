# Session 14 — CloudTrail

## Where Session 13 left off

Last session gave you the health of your system:

```
  EC2 CPU = 90%
  RDS storage = 2 GB
  Lambda errors = 10
```

CloudWatch can tell you a number moved. It cannot tell you this:

```
  WHO logged in
       and
  WHAT did they change
```

That gap is what this file fills.

---

## What CloudTrail actually is

> CloudTrail records every action taken in your account — who did it, what they did, when, and from where.

Your slides call it the account's **security camera**. Not a metaphor for flavor — it is a literal description of what it does: it is always recording, and you only go back and watch the footage once something looks wrong.

```
  every API call in your account
              |
              v
   +----------------------+
   |      CLOUDTRAIL       |
   |   (always recording)  |
   +----------------------+
              |
              v
        Event history
     (free, last 90 days)
```

---

## The scenario that makes this concrete

```
  You open the EC2 console.

  There is an instance you did not launch.

              "Who created this?!"
```

Without CloudTrail, that question has no answer. With it:

```
+------------------------------------------+
|  Time:       10:42:01                    |
|  Action:     RunInstances                |
|  User:       kal                         |
|  Source IP:  196.xx.xx                   |
|  Result:     Success                     |
+------------------------------------------+
```

Now the mystery is over. You know exactly who, from where, and that it succeeded.

---

## The four fields worth memorizing

```
{
  "eventTime":   "10:42:01",     <- WHEN
  "eventName":   "RunInstances", <- WHAT
  "userIdentity":"kal",          <- WHO
  "sourceIP":    "196.xx.xx",    <- WHERE
  "result":      "Success"       <- DID IT WORK
}
```

```
  eventName     ->  WHAT happened          (RunInstances = an EC2 launch)
  userIdentity  ->  WHO did it             (which user or role)
  sourceIP      ->  WHERE it came from     (the IP address)
  result        ->  did it succeed or get denied
```

Notice `result` matters as much as the other three. A denied action still gets logged — someone tried something and IAM refused it. That failed attempt is itself a security signal, not noise to ignore.

---

## It is on by default, and it is free

```
  RIGHT NOW, without you configuring anything:

  CloudTrail  --->  recording every API call
                     --->  keeping the last 90 days
                            --->  at no cost
```

This is different from the logs file from last session, where you had to actively set a retention period to control cost. CloudTrail event history costs nothing for 90 days of visibility — there is no excuse for not knowing what happened in your own account.

---

## How an engineer actually queries this

Console path:

```
CloudTrail -> Event history -> filter
```

Or from the terminal, which is what you will actually use once you are past the console-clicking stage:

```bash
# recent account actions
aws cloudtrail lookup-events --max-results 5

# who launched EC2 instances specifically
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=EventName,AttributeValue=RunInstances
```

The second command is the direct answer to "who launched this instance" — filter by `eventName`, then read `userIdentity` off each result.

---

## Why companies treat this as non-negotiable

```
   incident happens
          |
          v
   "who touched this, and when?"
          |
          v
   without CloudTrail: guessing, blame, no evidence
   with CloudTrail:    an exact, timestamped answer
```

Beyond incidents, CloudTrail is usually the first thing an auditor asks for. Compliance frameworks (SOC 2, PCI-DSS, and similar) require proof that account activity is logged and retrievable — CloudTrail is that proof.

---

## What CloudTrail is not

```
  CloudTrail  ->  tells you an action happened
  CloudTrail  ->  does NOT block the action
  CloudTrail  ->  does NOT judge if the RESULT is currently dangerous
```

If someone makes an S3 bucket public, CloudTrail will show you the exact API call that did it and who made it. It will not tell you, right now, six months later, whether that bucket is *still* public. That ongoing state question belongs to the next file — AWS Config.

```
   CloudTrail  ->  the ACTION      "someone made it public, at 10:42"
   Config      ->  the STATE       "it is public, right now"
```

---

## Active Recall — CloudTrail

**Q1.** Define CloudTrail in one sentence, using the security-camera framing.

<details><summary>Answer</summary>
CloudTrail is the account's security camera — it records every action taken in the account: who did it, what they did, when, and from where.
</details>

**Q2.** Name the four fields in a CloudTrail event and what each one answers.

<details><summary>Answer</summary>
eventName (WHAT happened), userIdentity (WHO did it), sourceIP (WHERE from), result (did it succeed or get denied).
</details>

**Q3.** You find a `RunInstances` event with `result: Denied`. Is this worth investigating? Why?

<details><summary>Answer</summary>
Yes. A denied action still means someone or something attempted it. It is itself a signal — either a legitimate user missing a permission, or an attacker probing what they can get away with.
</details>

**Q4.** How long is CloudTrail event history kept by default, and what does it cost?

<details><summary>Answer</summary>
90 days, and it costs nothing — it is on by default with no setup required.
</details>

**Q5.** "Who deleted my database?" — which tool, and why is it that one specifically?

<details><summary>Answer</summary>
CloudTrail — because the question is about an ACTION someone took, not about the resource's current configuration or whether an attack is in progress.
</details>

**Q6.** What can CloudTrail NOT tell you, even though it recorded the event perfectly?

<details><summary>Answer</summary>
Whether the resulting state is currently dangerous — e.g. it can show that someone made a bucket public at 10:42, but not whether that bucket is still public right now. That is AWS Config's job.
</details>
