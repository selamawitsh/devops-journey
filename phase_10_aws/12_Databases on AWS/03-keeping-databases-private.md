# Keeping the Database Private (Defense in Depth)

## The rule

> 🔐 **Your database should not be something the internet can directly
> talk to.**

This session takes everything from VPCs, subnets, route tables, and
security groups and applies it to one specific, high-value resource: RDS.

## Why keep a database private?

```
                    INTERNET
                       |
                       v
              +----------------+
              | Load Balancer  |
              +----------------+
                       |
                       v
              +----------------+
              |  App Servers   |
              +----------------+
                       |
                       v
              +----------------+
              |   RDS Database |
              +----------------+
```

Only your application servers need to talk to the database. A random
person on the internet does not. The path should be:

```
User → Application → Database        ✅

User → Database                       😭 ❌
```

## Mental model: VPC as a building

```
              VPC
               |
       +-------+-------+
       |               |
       v               v
   Public area     Private area
       |               |
       v               v
  Load Balancer       RDS
  App servers        Database
```

The public area can receive visitors. The private area is restricted.

```
Internet
   |
   X
   |
Private subnet
   |
  RDS
```

## What actually makes a subnet private?

> **A subnet is public if its route table has a route to an Internet
> Gateway.**

A database subnet should normally **not** have `0.0.0.0/0 → IGW`. Instead:

```
Destination     Target

10.0.0.0/16     local
```

```
Internet
    |
    v
   IGW
    |
    X
    |
Private subnet
    |
   RDS
```

There is no direct internet route into that subnet.

**A subtlety worth remembering:** "private route table = local only" is a
good simple teaching example, but not a strict rule. A private
*application* subnet might still have a route to a NAT Gateway for
outbound internet access:

```
10.0.0.0/16 → local
0.0.0.0/0   → NAT Gateway
```

That subnet is still private — it just has no *direct, inbound* route to
the IGW. A database subnet, depending on needs, may have no internet route
at all.

## Defense in depth: don't rely on one mechanism

A secure database uses **multiple, independent layers**:

```
1. Private subnet
        ↓
2. Security Group
        ↓
3. Public access disabled
```

```
                 INTERNET
                    |
                    X
              Private subnet
                    |
                    X
             RDS Public access
               = No
                    |
                    X
          Security Group doesn't
          allow random sources
                    |
                    ↓
                   RDS
```

Multiple controls reduce the chance that one configuration mistake
exposes everything. This is called **defense in depth**.

## Layer 1 — Private subnet

```
RDS
 ↓
Private subnet (no route to IGW)
```

The internet has no normal network path to reach the subnet at all.

## Layer 2 — Security Group (SG-to-SG, not IP-to-IP)

The app tier has `app-tier-sg`; RDS has `db-tier-sg`. The RDS rule should
reference the **security group**, not an IP:

```
db-tier-sg

Inbound:
MySQL
TCP 3306
Source: app-tier-sg
```

Meaning: "allow connections from resources associated with `app-tier-sg`"
— not `0.0.0.0/0`, and not a specific IP.

## Why SG → SG beats IP → port

```
EC2 #1  (10.0.1.10, app-tier-sg)
    |
    | TCP 3306
    v
RDS (db-tier-sg, allows FROM app-tier-sg)

✅ ALLOWED
```

Auto Scaling launches a replacement instance with a new IP:

```
EC2 #2  (10.0.1.25, app-tier-sg)
    |
    | TCP 3306
    v
RDS

✅ ALLOWED — the rule never needed to change
```

Compare that with an IP-based rule:

```
Rule: Allow TCP 3306, Source: 10.0.1.10

EC2 #1 (10.0.1.10) → RDS     ✅ ALLOW

EC2 crashes. Auto Scaling replaces it:
  Old: 10.0.1.10 ❌
  New: 10.0.1.37

10.0.1.37 → RDS               ❌ BLOCKED
(rule still only allows 10.0.1.10)
```

| Rule type | Survives instance replacement? | Survives Auto Scaling? |
|---|---|---|
| Specific IP address | ❌ No — rule breaks silently | ❌ No |
| Security group reference | ✅ Yes — automatically covers new members | ✅ Yes |

Security-group references are the pattern for dynamic infrastructure.

## The dangerous rule

Never casually do this:

```
Type: MySQL
Port: 3306
Source: 0.0.0.0/0
```

That means *any* IPv4 address can attempt to connect:

```
Internet
   |
   +---- Hacker
   |
   +---- Random computer
   |
   +---- Bot
   |
   +---- Your application
   |
   v
  RDS
```

A terrible default for a database.

## Layer 3 — Public access

When configuring RDS, set:

```
Public access: No
```

This tells RDS directly: "don't make this database publicly accessible,"
independent of subnet routing and security groups.

## Final architecture

```
                         INTERNET
                            |
                            v
                          [IGW]
                            |
                            v
                 ┌───────────────────┐
                 │   PUBLIC SUBNET   │
                 │  Load Balancer    │
                 └─────────┬─────────┘
                            |
                            v
                 ┌───────────────────┐
                 │  PRIVATE SUBNET   │
                 │   App Servers     │
                 │   app-tier-sg     │
                 └─────────┬─────────┘
                            |
                      TCP 5432/3306
                            |
                            v
                 ┌───────────────────┐
                 │  PRIVATE SUBNET   │
                 │       RDS         │
                 │    db-tier-sg     │
                 └───────────────────┘
```

Port reference: PostgreSQL = `5432`, MySQL = `3306`.

```
DB SG
  |
  └── Allow DB port
           |
           └── Source: APP SG
```

## The thing to remember

> **Don't secure a database by simply hiding its IP. Design the network so
> the internet has no direct path to it, then restrict who can connect
> using security groups.**

```
❌ 0.0.0.0/0        → DB port

❌ Specific EC2 IP  → DB port

✅ app-tier-sg      → DB port
```

That last pattern shows up constantly in AWS architectures.

## Real-world grounding

This exact pattern — private subnet, SG-to-SG rule, public access
disabled — is close to the default expectation for any production RDS
instance, and it's a very common finding in security reviews when even one
of the three layers is missing (most often "Public access" left on `Yes`
from a quick setup, or a debugging rule to `0.0.0.0/0` that never got
removed). None of the three layers alone is bulletproof; together they're
designed so one misconfiguration doesn't equal a breach.

## Common mistakes

- Leaving "Public access" set to Yes because it was the first option
  clicked through during setup — this alone can expose a database to the
  entire internet regardless of security group rules.
- Opening port 3306/5432 to `0.0.0.0/0` "temporarily" to debug a
  connection issue, and forgetting to close it afterward.
- Referencing a specific EC2 instance's IP address in the security group
  rule instead of its security group — the rule silently stops protecting
  anything the moment that instance is replaced.
- Assuming a private subnet alone makes the database safe, and skipping
  the security group and public-access layers as "redundant."

## Interview answers

**1. Why shouldn't an RDS database normally be directly accessible from
the internet?**
Because only the application tier needs to reach it. Exposing it directly
removes a whole layer of protection and puts the database one
misconfigured rule away from being reachable by anyone.

**2. What makes a subnet private?**
Its route table has no route to an Internet Gateway for inbound traffic —
not that it has "local only" routes; it can still route outbound traffic
through a NAT Gateway and remain private.

**3. Why is a security-group reference better than an IP address in a DB
rule?**
Because it automatically covers every instance that carries that security
group, including ones added later by Auto Scaling — an IP-based rule
breaks the moment the instance is replaced.

**4. How do you choose between the three layers — subnet, security group,
public access?**
You don't choose one — you use all three together. That's defense in
depth: each layer independently blocks direct internet access, so one
misconfiguration in any single layer doesn't expose the database.

## Active recall — don't look back 😈

1. Why shouldn't an RDS database normally be directly accessible from the
   internet?
2. What makes a subnet private?
3. What does this security group rule mean?
   ```
   DB-SG
   Inbound TCP 3306
   Source: APP-SG
   ```
4. Why is `APP-SG` better than using the current IP address of an EC2
   instance?
5. What does `0.0.0.0/0` mean when used as the source of a security-group
   rule?
6. What should you normally choose for RDS **Public access** when building
   a private database?
7. An EC2 instance in an Auto Scaling Group is replaced and gets a new
   private IP. If the RDS security group allows `APP-SG`, will the new
   instance still be able to connect? Why?
8. Explain this architecture in your own words:
   ```
   Internet
      ↓
   Load Balancer
      ↓
   App Server
      ↓
   RDS
   ```
