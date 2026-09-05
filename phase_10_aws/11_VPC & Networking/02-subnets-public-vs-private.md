# Public vs Private Subnets

## The One Real Rule

A subnet is **public** if, and only if, its route table sends `0.0.0.0/0`
traffic to an internet gateway. That's it. Not the name you gave it. Not
whether "auto-assign public IP" is ticked. Just that one line in the route
table.

```
+-------------------------- VPC 10.0.0.0/16 --------------------------+
|                                                                      |
|   PUBLIC SUBNET (10.0.1.0/24)        PRIVATE SUBNET (10.0.2.0/24)    |
|   route: 0.0.0.0/0 -> IGW            route: local only               |
|                                                                      |
|   [Load Balancer]                    [Database]                      |
|   reachable from internet            no public IP                    |
|                                       reachable only from inside     |
+-----------------------------------------------------------------------+
                  |
              INTERNET
```

---

## Side-by-Side Comparison

| | Public subnet | Private subnet |
|---|---|---|
| Nickname | "Faces the street" | "Inner office" |
| Route to IGW? | Yes | No |
| Can hold a public IP? | Yes | No |
| Reachable directly from the internet? | Yes | No |
| Typical residents | load balancers, web servers, bastion hosts | databases, app servers, internal workers |

---

## The Trap Most Beginners Fall Into

You can create a subnet, name it `qiyas-public`, and it is **still fully
private** the moment it's created — because no route table has pointed it at
an internet gateway yet. Naming a subnet "public" changes nothing on its own.
Only wiring the route (covered in file 03) makes it actually public.

---

## Real-World Grounding

This public/private split is the industry-default two-tier pattern:

```
Internet
   |
[Load Balancer]  <-- public subnet, reachable
   |
[Web / App servers]  <-- can also sit in public or a "web tier" subnet
   |
[Database]  <-- private subnet, never reachable directly
```

You will draw close to this exact box diagram in almost every real system
design interview and almost every production architecture diagram you'll
ever review at a job. The reasoning is simple: anything that *must* be
reached from outside goes public; anything you're *protecting* goes private.

---

## Interview Questions

1. What single thing makes a subnet "public" — not by name, but technically?
2. Why would you deliberately put a database in a private subnet instead of a
   public one?
3. Can a public subnet contain a resource with no public IP? What happens to
   it?

---

## Common Mistakes

- Believing the subnet's name or tag makes it public or private.
- Forgetting to enable "auto-assign public IPv4" on a subnet meant to be
  public — the route can be correct and the instance will still have no
  public IP.
- Putting a database in a public subnet "to make testing easier" and
  forgetting to move it back before going live.
