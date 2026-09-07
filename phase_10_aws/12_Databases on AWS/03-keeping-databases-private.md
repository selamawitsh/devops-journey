# Keeping the Database Private

## The rule

A database should never be open to the internet. This is the private
subnet concept from Session 11, applied to a specific, high-value resource.

```
                Internet
                    |
                   IGW
                    |
       Public Route Table: 0.0.0.0/0 -> IGW
                    |
              PUBLIC SUBNET
           (load balancer, app servers)
                    |
       Private Route Table: local only
       (no route to the IGW at all)
                    |
              PRIVATE SUBNET
                (RDS database)

        no path exists from the internet
              to the private subnet
```

## Three layers that enforce this together

```
1. Private subnet     -> no route to the internet gateway
2. Security group     -> only allow the DB port FROM the app tier's SG
3. Public access = No -> RDS never gets a public IP at all
```

```
Internet  ---X--->  RDS
          (blocked by all three layers above,
           independently)
```

## The security group rule, specifically

The correct rule doesn't reference an IP address at all — it references
**another security group**:

```
RDS security group, inbound rule:

  Type: MySQL/Aurora (port 3306)
  Source: [ the app server's security group ]   <-- not an IP, not 0.0.0.0/0

Meaning: "Only instances that carry this specific security group
may reach me on port 3306 — nothing else, from anywhere."
```

```
App server (has SG: app-tier-sg)  ----port 3306---->  RDS (allows FROM app-tier-sg)
        allowed

Random internet host               ----port 3306---->  RDS
        blocked, no matching source SG
```

This is a meaningfully different (and safer) pattern than allowing a
specific IP range, because it automatically covers every instance that ever
joins that security group — including ones added later by an Auto Scaling
Group — without editing the rule again.

## Interview questions

1. Why should an RDS instance's "Public access" setting be set to No even
   if a security group also restricts access?
2. What's the difference between allowing a security-group source versus
   an IP-range source for a database's inbound rule, and why does it
   matter for a fleet that scales up and down?
3. Which of the three layers (private subnet, security group, public
   access setting) would still protect the database if one of the other
   two were misconfigured?

## Common mistakes

- Leaving "Public access" set to Yes because it was the first option
  clicked through quickly during setup — this alone can expose a database
  to the entire internet regardless of security group rules.
- Opening port 3306 to `0.0.0.0/0` "temporarily" to debug a connection
  issue, and forgetting to close it afterward.
- Referencing a specific EC2 instance's IP address in the security group
  rule instead of its security group — the rule silently stops working the
  moment that instance is replaced.
