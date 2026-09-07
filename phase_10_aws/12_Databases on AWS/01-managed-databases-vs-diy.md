# Managed Databases vs Do-It-Yourself

## The core question

You could always install MySQL or PostgreSQL directly on an EC2 instance
yourself. Nothing stops you. The question this session opens with is: why
would you ever choose to?

## Visual: Owning a house vs renting an apartment

```
DO IT YOURSELF (on EC2)              MANAGED (RDS)
"Own the house"                      "Rent, landlord maintains"

  You install the DB engine            AWS installs and patches it
  You configure backups                Automatic backups,
  and hope they work                   point-in-time restore
  You handle failover                  Automatic failover
  yourself, at 3am                     to a standby, automatically
  Total control,                       You just use it
  total responsibility
```

## Why "you handle failover at 3am" is the real cost

This isn't a throwaway line — it's the actual failure mode DIY databases run
into in production. If you self-host on EC2 and the instance's disk fills
up, or the process crashes, or the whole EC2 instance dies, **you** are the
one who gets paged, diagnoses it, and brings the database back — at
whatever hour it happens. RDS turns that specific 3am phone call into
something AWS's infrastructure handles automatically (covered fully in file
04 — Multi-AZ failover).

```
DIY on EC2:                          RDS:

  Instance crashes                     Instance crashes
       |                                    |
       v                                    v
  Database is down                    AWS detects it
  until a human                            |
  notices and fixes it                     v
                                      Automatic failover to
                                      the standby, no human
                                      woken up required
```

## What "managed" actually buys you, concretely

| Responsibility | DIY on EC2 | RDS |
|---|---|---|
| Installing the database engine | You | AWS |
| Applying security patches | You | AWS |
| Configuring and testing backups | You | AWS, automatic |
| Handling a crashed instance | You, manually | AWS, automatic failover |
| Choosing the engine and instance size | You | You (you still decide this) |
| Writing queries and using the database | You | You (this never changes) |

Notice the last two rows: RDS doesn't take away your control over what
engine you run or how you use the database. It only takes over the
operational burden underneath it — installation, patching, backup
mechanics, and failure recovery.

## Real-world grounding

Almost every company past a very early stage uses a managed database for
production workloads, specifically because the DIY failure mode above is a
recurring, expensive way to lose an engineer's weekend. Self-hosting a
database on EC2 still shows up in specific cases — extremely
cost-sensitive hobby projects, or workloads needing a database engine RDS
doesn't offer — but it's the exception, not the default.

## Interview questions

1. What specifically does "managed" mean for a database — what does AWS do
   that you would otherwise have to do yourself?
2. Does choosing RDS mean you give up control over the database engine or
   how you query it?
3. Why is "failover" specifically called out as the risky 3am job in a
   self-hosted setup?

## Common mistakes

- Assuming "managed" means AWS also handles your schema design, query
  performance, or scaling decisions — it doesn't; those are still yours.
- Self-hosting a database on EC2 for a real production workload purely to
  save a small amount of money, without weighing the operational risk.
- Thinking Multi-AZ failover is "free" just because it's automatic — it has
  a real cost, covered in file 04.
