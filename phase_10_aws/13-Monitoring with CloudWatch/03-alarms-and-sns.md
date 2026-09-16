# Session 13 — Alarms and SNS

## The scenario

It is 3am. You are asleep. Your EC2 CPU does this:

```
 100 |                                    * * * *
  80 |- - - - - - - - - - - - - - - - -*- - - - -   <-- the line you care about
  60 |                             *
  40 |   *   *   *   *   *   *
  20 |
     +------------------------------------------
      11pm        1am        3am        5am
```

Nobody is looking at that graph. The graph existing does not help. Something has to notice the crossing and reach out to you.

---

## An alarm is exactly three things

```
   +-----------------------------------------------+
   |                  AN ALARM                     |
   +-----------------------------------------------+
   |                                               |
   |   1. METRIC      what are we watching?        |
   |         |        EC2 CPUUtilization           |
   |         v                                     |
   |   2. THRESHOLD   what is the line?            |
   |         |        greater than 80%, for 5 min  |
   |         v                                     |
   |   3. ACTION      what happens when crossed?   |
   |                  publish to an SNS topic      |
   |                                               |
   +-----------------------------------------------+
```

Memorise it as one line:

```
        ALARM = METRIC + THRESHOLD + ACTION
```

If you can name those three for any alarm you meet, you understand that alarm completely.

---

## The two states an alarm lives in

```
      CPU
 100 |                  * * *
  80 |- - - - - - - - -*- - - * - - - - - - - -  threshold
  40 |  * * * *  *  *           *  *  *  *  *
     +------------------------------------------
        OK          IN ALARM        OK
     +---------+  +----------+  +-------------+
     |  green  |  |   red    |  |    green    |
     +---------+  +----------+  +-------------+
                       ^              ^
                       |              |
              notification sent   recovers on its own
```

An alarm is not a one-time event. It is a state machine that flips back and forth. That is why your lab alarm returns to OK by itself once the stress command ends — nobody has to reset it.

---

## Why "for 5 minutes" matters

Compare two threshold designs against the same noisy metric:

```
  CPU with normal spikes:

 100 |     *        *              *
  80 |- - -*- - - - *- - - - - - - *- - - -
  40 |  *  * *   *  *  *   *  *  * *  *
     +--------------------------------------


  THRESHOLD A: "above 80% for 1 datapoint"
      -> fires    -> fires    -> fires
      3 alerts, all of them meaningless noise

  THRESHOLD B: "above 80% for 5 consecutive minutes"
      -> silent   -> silent   -> silent
      0 alerts, because none of the spikes were sustained
```

A single 5-second spike is normal computer behaviour. A sustained 5-minute climb is a problem. The duration part of a threshold is what separates the two.

---

## How the message actually reaches you: SNS

CloudWatch does not send email. It hands the message to a messenger.

```
  +-------------+        +-------------+        +--------------+
  | ALARM FIRES |  --->  |  SNS TOPIC  |  --->  | SUBSCRIBERS  |
  +-------------+        +-------------+        +--------------+
    CPU > 80%            "qiyas-alerts"          your email
                          the mailing list       your phone (SMS)
                                                 a colleague
```

An SNS topic is just a named mailing list. The alarm publishes **one** message to the topic; everyone on the list receives it.

Why that indirection is useful:

```
                      WITHOUT TOPICS              WITH TOPICS

  alarm 1 --> you                    alarm 1 --\
  alarm 1 --> teammate                          >--> [infra-alerts] --> you
  alarm 1 --> phone                  alarm 2 --/                    --> teammate
  alarm 2 --> you                                                   --> phone
  alarm 2 --> teammate               alarm 3 -----> [payments-alerts] --> on-call
  ...
  every alarm hardcodes              add a person once, to the topic;
  every recipient                    every alarm using it now reaches them
```

Routing changes without touching any alarm's logic.

---

## The step everybody forgets

```
  you subscribe your email
            |
            v
  +--------------------------+
  | AWS sends a confirmation |
  |     email to you         |
  +--------------------------+
            |
      did you click it?
            |
     +------+------+
     |             |
    YES            NO
     |             |
     v             v
  status:       status:
  Confirmed     Pending confirmation
     |             |
     v             v
  alarm       ALARM FIRES, SNS PUBLISHES,
  reaches     AND THE MESSAGE GOES NOWHERE
  you
```

The alarm will look perfectly healthy in the console. The SNS topic will look fine. The failure is invisible until the day you actually needed the alert. **A silent alarm is worse than no alarm**, because you believed you were covered.

---

## Why companies are strict about alarm design

The failure mode in real teams is never "too few alarms."

```
  INBOX, 9am

  [ ] ALARM: high-cpu-web-01          |
  [ ] ALARM: high-cpu-web-02          |
  [ ] ALARM: disk-io-web-01           |
  [ ] ALARM: high-cpu-web-01 (again)  |  200 of these per day
  [ ] ALARM: memory-web-03            |
  [ ] ALARM: rds-storage-low          |  <-- the one that mattered
  [ ] ALARM: high-cpu-web-02 (again)  |
  [ ] ...                             |
                                      v
              everyone selects all and deletes
```

This is alarm fatigue, and it is an operational problem, not a hypothetical one. The discipline that prevents it:

```
  +-------------------------------+-----------------------------------+
  | DO                            | DO NOT                            |
  +-------------------------------+-----------------------------------+
  | alarm on things that hurt     | alarm on every metric that exists |
  | use sustained durations       | alert on single spikes            |
  | route to who can act          | dump everything in a shared inbox |
  | make the message actionable   | send "ALARM: high-cpu" and stop   |
  +-------------------------------+-----------------------------------+
```

---

## What a good alarm message contains

You are woken at 3am. Compare what arrives:

```
  BAD                          GOOD
  +----------------------+     +-----------------------------------+
  | Subject: ALARM       |     | Subject: ALARM high-cpu on web-01 |
  |                      |     |                                   |
  | high-cpu             |     | metric:    CPUUtilization         |
  |                      |     | resource:  i-0a1b2c3d (web-01)    |
  +----------------------+     | threshold: > 80% for 5 min        |
                               | actual:    94%                    |
  you now open five            | since:     03:12 UTC              |
  consoles just to find        | dashboard: <link>                 |
  out what "high-cpu"          | logs:      <link to log group>    |
  even refers to               +-----------------------------------+
```

The alarm already knew all of that at the moment it fired. Making it carry that context is free, and saves the responder ten minutes of rediscovery while the system is down.

---

## When NOT to use an alarm

```
  Scheduled batch job, every night at 2am:

 100 |            * * *
  80 |- - - - - -*- - -*- - - - - - -   threshold
  20 |  * * * *          * * * * * *
     +-------------------------------
              2am
```

That crossing is expected. It happens every single night. Alarming on it trains you to ignore alarms, which eventually costs you a real one.

Options when a metric routinely crosses a "normal-looking" line:

```
  raise the threshold          -> only alert above what the job produces
  extend the duration          -> only alert if it stays high far longer
  do not alarm at all          -> put it on the dashboard instead, and look
                                  at it when you want to, not at 2am
```
