# RDS Backups, Multi-AZ, and Cost

## The three things this session is about

1. **Backups** → recover your data.
2. **Multi-AZ** → keep the database available when infrastructure fails.
3. **Cost** → RDS can keep charging you even when you're doing absolutely
   nothing with it.

## Automatic backups

```
Monday
   |
Snapshot
   |
Tuesday
   |
Snapshot
   |
Wednesday
   |
Snapshot
```

Daily snapshots aren't the only recovery points. RDS also records
transaction logs continuously between snapshots, which enables
**point-in-time recovery (PITR)**:

```
Monday snapshot
      |
      | transaction logs
      | transaction logs
      | transaction logs
      v
Tuesday snapshot
      |
      | transaction logs
      | transaction logs
      v
Wednesday snapshot
```

If something breaks at `Tuesday 14:37:25`, you can potentially restore to
approximately that moment — not just to the nearest daily snapshot —
within the configured retention window.

## Snapshot vs point-in-time recovery

| | Snapshot | Point-in-time recovery |
|---|---|---|
| Think of it as | "The database exactly as it was at this saved moment" | "Take me back to approximately this specific moment" |
| Granularity | A specific saved point | Any point within the recovery window |
| Diagram | `Monday 00:00 → [SNAPSHOT]` | `Mon --- Tue(14:37:25) --- Wed → restore here` |

## Worked example: someone deletes production data

```
Users
------
Sara
Abebe
Mekdes
```

```sql
DELETE FROM users;
```

```
12:00 → everything normal
13:00 → everything normal
13:47 → accidental DELETE
14:00 → disaster discovered
```

You can restore to a point **before 13:47**, depending on your configured
recovery window. Backups aren't just "save a copy" — they're the mechanism
for recovering from mistakes and disasters.

## Multi-AZ: a different problem entirely

```
BACKUP     → "How do I recover my data?"
MULTI-AZ   → "How do I keep my database available if infrastructure fails?"
```

## Multi-AZ architecture

```
              AZ-1                          AZ-2
        +-----------+                 +-----------+
        |  PRIMARY  |  <--sync-->     |  STANDBY  |
        |    RDS    |   replication   |    RDS    |
        +-----------+                 +-----------+
              |
        serving traffic
```

## What happens if the primary AZ dies

```
AZ-1                    AZ-2

PRIMARY                 STANDBY
   |                       |
   X 💀                    |
                           v
                     becomes primary
                     (automatic failover,
                      no manual promotion)
```

Your application reconnects through the RDS endpoint after failover. You
never manually copy the database and promote a replacement yourself —
that's the operational advantage. This is the mechanism that turns "the
3 AM problem" (from the DIY-vs-RDS session) into something nobody gets
paged for.

## Multi-AZ is NOT primarily a backup

The most important distinction in this whole session.

**Scenario A — accidental deletion:**

```
PRIMARY
DELETE
  |
  v
STANDBY
DELETE   ← the bad change replicates too
```

Multi-AZ doesn't save you here. You need backup/PITR for this class of
problem.

**Scenario B — infrastructure failure:**

```
PRIMARY 💀
    |
    v
STANDBY
    |
    v
FAILOVER
```

This is where Multi-AZ helps.

```
BACKUP     → recover data
MULTI-AZ   → recover availability
```

That distinction is genuinely interview-worthy.

## Why the standby lives in a different AZ

```
Both in AZ-1:                        Split across AZ-1 / AZ-2:

AZ-1                                 AZ-1              AZ-2
 ├── Primary                          Primary  <--sync-->  Standby
 └── Standby

AZ-1 has an outage:                  AZ-1 has an outage:
AZ-1 💀                                Primary 💀            Standby
 ├── Primary 💀                                              continues
 └── Standby 💀
(both down — no benefit)             (AZ-2 keeps serving)
```

Putting primary and standby in the same physical failure domain defeats
the purpose.

## Cost: the part that quietly wrecks a lab budget

An RDS instance is not billed like Lambda or DynamoDB on-demand, where no
usage roughly means no charge. If it's running, it's billing:

```
08:00 → running → 💰
09:00 → running → 💰
10:00 → running → 💰
   ...
02:00 → running → 💰
03:00 → running → 💰

(even if nobody sends a single query)
```

## RDS vs DynamoDB billing model

```
RDS                                   DynamoDB on-demand

Provisioned database infrastructure   Request
        |                                 |
Running → charges continue          Read/write
        |                                 |
     24/7                          Charge based on usage
```

Don't over-generalize this into "DynamoDB is always free when idle" — it
has multiple pricing dimensions and other features can incur charges. The
actual lesson: **on-demand request capacity doesn't carry the same
always-running, per-instance billing model that RDS does.**

## The classic AWS student mistake

```
Create RDS PostgreSQL for a lab
        |
"Nice! I learned RDS." 😎
        |
Close laptop
        |
Your laptop:  😴          RDS:  💰💰💰💰💰
        |
Three days later
        |
AWS bill:  😐
```

After any lab: check what's still running. Especially RDS instances, EC2
instances, NAT Gateways, load balancers, and other billable resources.

## Multi-AZ costs more

```
Single-AZ:  [ PRIMARY ]                          ≈ 1x

Multi-AZ:   [ PRIMARY ]  <--sync-->  [ STANDBY ]  ≈ higher cost
```

For a learning lab, you don't normally need high availability unless the
lab specifically calls for it. In production, availability + automatic
failover + reduced downtime can easily justify the extra cost.

## Don't say "Multi-AZ doubles everything"

"Multi-AZ roughly doubles RDS compute cost" is a useful mental model — not
a promise that the whole bill is exactly 2×. Your total bill can include:

```
Instance
  +
Storage
  +
Backup storage
  +
Data transfer
  +
Other features
```

The reliable lesson: **Multi-AZ adds the cost of maintaining a full
second database instance**, and the precise total depends on configuration
and region.

## Connecting the last few sessions

```
             RDS
              |
      +-------+-------+
      |               |
   SECURITY         AVAILABILITY
      |               |
      v               v
Private subnet     Multi-AZ
      |               |
Security Group      Standby
      |               |
      v               v
Who can connect?   What if primary fails?
```

```
BACKUPS           → What if data is deleted/corrupted?
MULTI-AZ          → What if infrastructure fails?
PRIVATE SUBNET+SG → Who can reach the database?
COST              → How much does running all this cost?
```

## The four things to memorize

1. **Backup** → recover data.
2. **Multi-AZ** → maintain availability through automatic failover.
3. **Private database** → don't expose the database directly to the
   internet.
4. **RDS cost** → a running instance keeps incurring charges even when
   idle.

## Real-world grounding

The gap between "DynamoDB/Lambda bill for usage" and "RDS bills for
uptime" is one of the most common surprises for anyone new to AWS billing
— a forgotten RDS instance from a weekend lab is a very ordinary way to
get an unexpectedly large bill, precisely because there's no "idle equals
free" behavior to rely on. In production, this same always-on billing
model is exactly what you're paying for when you enable Multi-AZ: a fully
synchronized, ready-to-promote standby instance sitting there the whole
time, not something spun up only during a failure.

## Common mistakes

- Enabling Multi-AZ in a lab or dev environment "just to be safe,"
  doubling the cost for a workload that doesn't need the durability.
- Assuming RDS behaves like DynamoDB or Lambda and only bills when
  actively used — it doesn't; it bills by the hour regardless of traffic.
- Forgetting that backup storage beyond the free allowance is a separate
  cost line from the database instance itself.
- Treating Multi-AZ as a substitute for backups, or backups as a
  substitute for Multi-AZ — they solve different failure modes.

## Interview answers

**1. What's the difference between a snapshot and point-in-time
recovery?**
A snapshot restores the database to exactly one saved moment. PITR uses
snapshots plus continuous transaction logs to restore to nearly any
moment within the retention window, not just a snapshot boundary.

**2. What problem does Multi-AZ solve, and what doesn't it solve?**
It solves availability — automatic failover to a synchronized standby if
the primary infrastructure fails. It does not protect against bad data
changes, since those replicate to the standby too; that's what
backups/PITR are for.

**3. Why is the standby placed in a different Availability Zone?**
So a single AZ failure can't take out both the primary and the standby at
once — the whole point of Multi-AZ is surviving a failure in the primary's
physical location.

**4. Why can an idle RDS instance still generate a large bill?**
Because RDS bills by the hour for a provisioned, running instance,
regardless of query volume — unlike DynamoDB on-demand or Lambda, which
bill per request/invocation and cost nothing while idle.

## Active recall — don't look back 😈

1. What's the difference between a snapshot and point-in-time recovery?
2. Why can PITR restore to a time between daily snapshots?
3. What problem does Multi-AZ solve?
4. What happens when the primary RDS instance fails in a Multi-AZ setup?
5. Why doesn't Multi-AZ replace backups?
6. Someone accidentally deletes all your production users. Which
   mechanism would you rely on to recover the previous data: Multi-AZ or
   backup/PITR? Why?
7. Why is the standby placed in another Availability Zone?
8. Your RDS instance is running but nobody is using it. Does that mean
   the compute charge stops?
9. Why would you normally avoid Multi-AZ for a simple learning lab?
10. Explain this in your own words:
    ```
    Backup = ?
    Multi-AZ = ?
    Security Group = ?
    Private subnet = ?
    ```
