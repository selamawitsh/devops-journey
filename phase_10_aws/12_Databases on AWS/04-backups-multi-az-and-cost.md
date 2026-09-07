# Backups, Multi-AZ, and Cost

## Automatic backups and point-in-time restore

```
Daily snapshot        Daily snapshot        Daily snapshot
     |                     |                     |
   Day 1  ---------------Day 2--------------- Day 3
              transaction logs recorded continuously
                          |
                          v
        Restore to ANY SECOND within the
        retention window, not just to a
        daily snapshot boundary
```

RDS takes daily snapshots automatically and continuously records
transaction logs in between them — which is what makes "restore to any
second in the retention window" possible, rather than only being able to
roll back to midnight.

## Multi-AZ standby and automatic failover

```
              AZ-1                          AZ-2
        +-----------+                 +-----------+
        |  PRIMARY  |  <--sync-->     |  STANDBY  |
        |    RDS    |   replication   |    RDS    |
        +-----------+                 +-----------+
              |
        serving traffic
              |
              X   <- AZ-1 has an outage
              |
        AWS automatically fails over
              |
              v
        +-----------+
        |  STANDBY  |  <- now serving traffic,
        |  (in AZ-2)|     no human intervention
        +-----------+
```

The standby is a full, continuously synchronized second database instance
sitting in a different Availability Zone. If the primary fails — or the
whole AZ has a problem — AWS fails over to the standby automatically. This
is the mechanism that turns "handle failover at 3am" (file 01) into
something nobody gets paged for.

## Cost — read this before you forget to delete a lab environment

```
RDS billing:                         DynamoDB (on-demand) billing:

  Bills by the HOUR,                   Bills PER REQUEST
  whether used or not                  (read/write)
       |                                     |
  Instance sits idle                   No requests coming in
  overnight, on weekends                     |
       |                                     v
  Still costs money                    Costs nothing while idle

  <---------- opposite billing models ---------->
```

| Cost driver | Detail |
|---|---|
| RDS instance | Bills 24/7 by the hour — running is running, whether or not anyone queries it |
| RDS storage + backups | You pay for the disk and for backup storage beyond the free allowance |
| DynamoDB on-demand | Pay per read/write request — cheap for spiky loads, zero idle cost |
| Multi-AZ | The standby is a full second instance — this roughly **doubles** RDS compute cost |

```
Single-AZ RDS:  [ Primary ]                    ~ 1x cost

Multi-AZ RDS:   [ Primary ]  +  [ Standby ]    ~ 2x cost
                (worth it in production,
                 usually skipped in a lab
                 or dev environment)
```

**The one thing that turns a lab into an expensive mistake:** an RDS
instance left running after a lab session bills every single hour, all
week, whether or not you ever touch it again — unlike Lambda (Session 08)
or DynamoDB on-demand, there's no "idle equals free" here.

## Interview questions

1. What does "point-in-time restore" mean, and what makes it possible
   beyond just daily snapshots?
2. Walk through what actually happens, step by step, when the primary AZ
   in a Multi-AZ RDS deployment fails.
3. Why does Multi-AZ roughly double RDS cost, specifically?
4. Why is forgetting to delete an RDS instance after a lab meaningfully
   worse than forgetting to delete a DynamoDB table?

## Common mistakes

- Enabling Multi-AZ in a lab or dev environment "just to be safe," doubling
  the cost for a workload that doesn't need the durability.
- Assuming RDS behaves like DynamoDB or Lambda and only bills when it's
  actively used — it doesn't; it bills by the hour regardless of traffic.
- Forgetting that backup storage beyond the free allowance is a separate
  cost line from the database instance itself.
