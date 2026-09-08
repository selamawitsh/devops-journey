# Public vs Private Subnets

## The One Real Rule

A subnet is public if, and only if, its route table sends `0.0.0.0/0`
traffic to an internet gateway. That's it. Not the name you gave it. Not
whether "auto-assign public IP" is ticked. Just that one line in the route
table.

```
+-------------------------- VPC 10.0.0.0/16 --------------------------+
+-----------------------------------------------------------------+
|                                                                 |
+=================================================================+
| PUBLIC SUBNET (10.0.1.0/24)        PRIVATE SUBNET (10.0.2.0/24) |
+-----------------------------------------------------------------+
| route: 0.0.0.0/0 -> IGW            route: local only            |
+-----------------------------------------------------------------+
|                                                                 |
+-----------------------------------------------------------------+
| [Load Balancer]                    [Database]                   |
+-----------------------------------------------------------------+
| reachable from internet            no public IP                 |
+-----------------------------------------------------------------+
| reachable only from inside                                      |
+-----------------------------------------------------------------+
+-----------------------------------------------------------------------+
				  |
			  INTERNET
```

## What `0.0.0.0/0` actually means

It reads as **"any IPv4 destination that isn't matched by a more specific
route above it."** `10.0.0.5`, `8.8.8.8`, `142.250.x.x` — all of it matches.
So `0.0.0.0/0 -> igw` translates in plain English to: *"anything headed
outside my VPC, send it to the internet gateway."*

```
Route Table
--------------------
Destination     Target
10.0.0.0/16     local        <- stays inside the VPC
0.0.0.0/0       igw-12345    <- everything else -> internet gateway
```

---

## The Trap Most Beginners Fall Into

You can create a subnet, name it `qiyas-public`, and it is **still fully
private** the moment it's created — because no route table has pointed it at
an internet gateway yet. Naming a subnet "public" changes nothing on its own.
Only wiring the route (covered in file 03) makes it actually public.

---

## "Private" does not mean "cut off from all networking"

Don't memorize "a private subnet's route table only ever has `local`." A
real private subnet commonly looks like this instead:

```
Route Table
--------------------
Destination     Target
10.0.0.0/16     local
0.0.0.0/0       nat-456      <- still private!
```

```
PRIVATE SUBNET
	  |
	  no route straight to the IGW  <- this is what "private" means
	  |
	  but CAN still reach the internet OUTBOUND
	  through a NAT Gateway (full mechanics in file 03)
	  |
	  v
  NAT Gateway -> IGW -> Internet   (outbound only, one-way door)
```

The subnet is still private — nothing on the internet can reach in — but a
database in it can still call out to fetch an OS patch. **Private means "no
direct inbound route through an IGW," not "zero internet access at all."**

---

## The 5-second rule for checking any subnet

Don't look at the subnet's name, its tags, or whether an instance in it has
a public IP. Look at exactly one thing:

```
				ROUTE TABLE
					 |
					 v
			  0.0.0.0/0 -> ?

  -> Internet Gateway   =>  PUBLIC subnet
  -> NAT Gateway         =>  PRIVATE subnet
  -> (no default route,
	  only "local")       =>  PRIVATE subnet
```

### Mini scenario — three subnets, same VPC

```
Subnet A  10.0.1.0/24    Subnet B  10.0.2.0/24    Subnet C  10.0.3.0/24
route:                   route:                    route:
 10.0.0.0/16 -> local     10.0.0.0/16 -> local      10.0.0.0/16 -> local
 0.0.0.0/0   -> igw-123   0.0.0.0/0   -> nat-456    (no 0.0.0.0/0 line)

	 PUBLIC                    PRIVATE                    PRIVATE
```

Same VPC, three different route tables, three different answers — and the
answer never depended on what any of them were named.

---

## Side-by-Side Comparison

+---------------------------------------+--------------------------------------------+------------------------------------------+
|                                       | Public subnet                              | Private subnet                           |
+=======================================+============================================+==========================================+
| Nickname                              | "Faces the street"                         | "Inner office"                           |
+---------------------------------------+--------------------------------------------+------------------------------------------+
| Route to IGW?                         | Yes                                        | No (may route outbound via NAT instead)  |
+---------------------------------------+--------------------------------------------+------------------------------------------+
| Can hold a public IP?                 | Yes                                        | No                                       |
+---------------------------------------+--------------------------------------------+------------------------------------------+
| Reachable directly from the internet? | Yes                                        | No                                       |
+---------------------------------------+--------------------------------------------+------------------------------------------+
| Typical residents                     | load balancers, web servers, bastion hosts | databases, app servers, internal workers |
+---------------------------------------+--------------------------------------------+------------------------------------------+

---

## Very important: public subnet does not mean public resource

This is the single most common misunderstanding on this topic. A public
subnet is just a street that connects to the outside world — an individual
house on that street still needs its own address to be reachable.

```
PUBLIC SUBNET
	  |
	  +-- EC2-A --> has a public IP     --> reachable from the internet
	  |
	  +-- EC2-B --> no public IP        --> NOT reachable from the internet,
											 even though its subnet is public
```

Three completely separate layers decide whether a specific resource is
actually reachable, and each answers a different question:

```
Route table       -> "Is this SUBNET public?"
Public IPv4        -> "Does this RESOURCE have an internet-facing address?"
Security group      -> "Is this TRAFFIC actually allowed to arrive?"
```

```
Internet
   |
   v
Internet Gateway
   |
   v
Route Table   (subnet is public)
   |
   v
Public Subnet
   |
   v
EC2  --- has a public IPv4? ---  NO  -->  unreachable, stop here
   |
  YES
   |
   v
Security Group  --- allows this port? ---  NO  -->  blocked, stop here
   |
  YES
   |
   v
Traffic reaches the instance
```

The interview-grade version of this idea: *"A subnet is public when its
route table has a route to an internet gateway. Whether a specific resource
inside it is actually reachable depends on two more independent things — a
public IP address, and a security group that allows the traffic."*

---

## The full architecture, and why the database goes private

```
					INTERNET
						|
						v
			   [Internet Gateway]
						|
						v
			  +-----------------+
			  |  PUBLIC SUBNET  |
			  |  Load Balancer  |
			  +--------+--------+
					   |
					   v
			  +-----------------+
			  |  PRIVATE SUBNET |
			  |   App Server    |
			  +--------+--------+
					   |
					   v
			  +-----------------+
			  |  PRIVATE SUBNET |
			  |    Database     |
			  +-----------------+
```

Users need to reach the application — they never need to reach the database
directly. A database holds usernames, passwords, customer records, orders,
payments; there's no reason for it to be a click away from every computer
on the internet. Restricting it to a private subnet means it only ever
talks to the application servers that legitimately need it, covered in
full in file 03's private-subnet security-group pattern.

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
2. If a subnet's route table sends `0.0.0.0/0` to a NAT Gateway instead of
   an internet gateway, is it public or private? Why?
3. Can a public subnet contain a resource with no public IP? What happens to
   it?
4. Name the three separate layers that together decide whether a specific
   resource is reachable from the internet.
5. In your own words, what does "private subnet" actually mean — and what
   does it *not* mean?

---

## Common Mistakes

- Believing the subnet's name or tag makes it public or private.
- Forgetting to enable "auto-assign public IPv4" on a subnet meant to be
  public — the route can be correct and the instance will still have no
  public IP.
- Assuming "private subnet" means "no internet access at all," rather than
  "no direct inbound path through an internet gateway."
- Putting a database in a public subnet "to make testing easier" and
  forgetting to move it back before going live.
