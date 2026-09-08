# Managed Databases vs Do-It-Yourself (RDS)

## The core question

Everything in this session collapses into one question:

> **Who is responsible for keeping the database alive?**

You can always install PostgreSQL yourself on an EC2 instance. Nothing
stops you. The question is why — and when — you'd choose to let AWS do it
instead.

## Visual: two ways to run PostgreSQL

```
Option A — DIY                       Option B — RDS

  YOUR RESPONSIBILITY                  AWS RESPONSIBILITY
         |                                    |
         v                                    v
  +----------------+                   +----------------+
  |      EC2       |                   |      RDS       |
  |                |                   |                |
  |  PostgreSQL    |                   |  PostgreSQL    |
  |  Database      |                   |  Database      |
  +----------------+                   +----------------+
                                               ^
                                               |
                                        YOUR APPLICATION
```

In DIY, you own everything underneath PostgreSQL. In RDS, AWS owns the
infrastructure layer; you sit on top of it.

## What "managed" actually means

This is the part beginners get wrong most often:

> **Managed does NOT mean AWS manages your entire database for you.**
> **It means AWS manages the infrastructure and many of the operational
> tasks required to keep the database running.**

```
DIY task chain:                      RDS:

  Install PostgreSQL                          RDS
        |                                      |
  Configure PostgreSQL                 AWS handles many
        |                              operational tasks
  Apply security patches                       |
        |                            +---------+---------+
  Configure backups                  |         |         |
        |                          Patch     Backup   Recovery
  Test backups
        |
  Monitor server
        |
  Handle disk problems
        |
  Handle instance failure
        |
  Build failover system
```

You still manage the **database itself** either way.

## What you still manage, even on RDS

| Responsibility | DIY on EC2 | RDS |
|---|---|---|
| Installing the database engine | You | AWS |
| Applying security patches | You | AWS |
| Configuring and testing backups | You | AWS, automatic |
| Handling a crashed instance | You, manually | AWS, automatic failover* |
| Database schema, tables, relationships | You | You |
| Indexes and query design | You | You |
| Application logic | You | You |
| Database credentials/access | You | You |
| Instance sizing and performance tuning | You | You |

\* *Only with a properly configured Multi-AZ deployment — not automatic by default.*

So: **RDS manages the database infrastructure. You manage how your
application uses the database.** AWS doesn't write your SQL or design your
tables for you.

```
Database
├── users
├── orders
├── products
└── payments

SELECT * FROM users;   ← still yours, on either option
```

## The 3 AM problem

This is the real cost DIY databases run into in production, not a
throwaway line.

Say you're self-hosting PostgreSQL on EC2. At 3 AM, your app starts
throwing `Database connection failed`. You investigate and find the EC2
instance crashed.

```
DIY on EC2:                          RDS (Multi-AZ):

  Instance crashes                     Instance crashes
       |                                    |
       v                                    v
  Database is down                    AWS detects it
  until a human                             |
  notices and fixes it                      v
       |                              Automatic failover to
  Wake up → SSH in →                  the standby — no human
  investigate → recover →             woken up required
  check data → restart app
       |
  Go back to sleep 😭
```

With a properly configured RDS deployment, AWS can handle certain
infrastructure failures automatically via **Multi-AZ failover** — a
primary/standby pair where AWS switches to the standby on failure. The
engineer doesn't have to manually rebuild the database at 3 AM.

## Multi-AZ ≠ backup

Important distinction, especially for interviews — these solve two
different problems.

```
Primary DB
    |
    X  ← instance failure
    |
Standby DB
```

| | Multi-AZ | Backup |
|---|---|---|
| Solves | "What happens if the infrastructure fails?" | "What happens if I need to recover data?" |
| Protects against | Instance/AZ failure | Data loss, mistakes, corruption |
| Mechanism | Failover to a standby | Restore from a snapshot/backup |

Multi-AZ keeps you *available*. Backup lets you *go back in time*. Having
one does not give you the other.

## RDS does not fix bad queries

```sql
SELECT * FROM orders;   -- orders has 500,000,000 rows
```

RDS doesn't say "don't worry, I'll fix your SQL." You still need:

- indexes
- query optimization
- schema design
- connection management
- caching
- application architecture

AWS manages the underlying service. You still need database engineering
knowledge — RDS moves the operational floor, not the ceiling.

## Mental model: furnished apartment vs empty house

```
EC2 + PostgreSQL                     RDS
"Here's an empty house.              "Here's an apartment. We handle
 Good luck."                          much of the building maintenance."

House                                Your apartment
 ├── electricity                          ↓
 ├── maintenance                    How you use it
 ├── repairs
 ├── security
 └── everything else
```

You still control what happens *inside* the apartment either way.

## What RDS can manage for you

Depending on configuration:

- database engine setup
- automated backups
- point-in-time recovery
- software patching / maintenance
- monitoring integration
- Multi-AZ deployment / failover
- storage management options
- automated snapshots

> **Managed doesn't mean zero responsibility.**

## Point-in-time recovery

```
10:00 ─── 11:00 ─── 12:00 ─── 13:00 ─── 14:00
users=100  users=120 users=150 users=180   |
                                        disaster
                                            X
                     ↓ restore ↓

                          13:00
                      (users = 180)
```

If your backup/recovery configuration supports it, you can roll the
database back to a point before an accidental deletion or corruption
event — not just to the last full snapshot.

## Why wouldn't everyone use RDS?

| RDS advantages | RDS trade-offs |
|---|---|
| Less operational work | Costs money |
| Automated backups | Less low-level control |
| Failover options | Limited to supported engines/configs |
| Tighter AWS integration | Can't do unusual customization |
| Easier maintenance | |

You might choose DIY on EC2 when you need an engine or configuration RDS
doesn't support, unusual customization, specialized infrastructure, or a
specific cost/control trade-off.

The real question isn't *"is RDS always better?"* — it's:

> **"Is the operational burden of managing the database yourself worth the
> control/cost benefits?"**

## The core distinction, one more time

```
                    DATABASE
                       |
            +----------+----------+
            |                     |
           DIY                   RDS
            |                     |
        You manage             AWS manages
        infrastructure         infrastructure
            |                     |
        More control          Less operational
        More work             burden
```

> **EC2 + PostgreSQL = "I manage the server."**
> **RDS PostgreSQL = "AWS manages much of the database infrastructure; I manage the database/application side."**

## Real-world grounding

Almost every company past a very early stage uses a managed database for
production workloads — the 3 AM problem above is a recurring, expensive
way to lose an engineer's weekend, and RDS is priced to make that trade
worth it at scale. Self-hosting on EC2 still shows up in specific cases —
cost-sensitive hobby projects, or workloads needing an engine RDS doesn't
offer — but it's the exception, not the default.

## Common mistakes

- Assuming "managed" means AWS also handles your schema design, query
  performance, or scaling decisions — it doesn't; those are still yours.
- Treating Multi-AZ and backups as interchangeable — Multi-AZ protects
  availability, backups protect data.
- Self-hosting a real production database purely to save a small amount
  of money, without weighing the operational risk.
- Expecting RDS to "notice" and fix a bad query — it won't.

## Active recall — don't look back

1. If I install PostgreSQL directly on EC2, who is responsible for
   patching PostgreSQL?
2. If I use RDS PostgreSQL, does AWS design my tables and write my SQL
   queries?
3. What's the difference between Multi-AZ and backup?
4. Why is the "3 AM problem" much worse with DIY databases?
5. What does "managed database" actually mean?
6. If my SQL query is extremely slow, will RDS automatically optimize it?
7. Give one reason someone might still choose PostgreSQL on EC2 instead
   of RDS.
8. In one sentence: EC2 + PostgreSQL vs RDS PostgreSQL — what's the
   difference?
