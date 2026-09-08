# VPC Fundamentals

## What is a network, before AWS is even involved

Strip AWS away for a second. A network is just a set of devices with a way
to identify each other, communicate, and control who's allowed to talk to
whom — your home Wi-Fi, a university's 500 computers, a company's data
center. AWS gives you the ability to build your own virtual version of
exactly that inside its cloud. That virtual network is the VPC.

## What is a VPC?

A **VPC (Virtual Private Cloud)** is your own private, walled-off network inside AWS.
Nothing gets in or out unless you explicitly allow it.

Think of it as a gated office compound:

```
+-----------------------------------------------------+
|                     VPC (the wall)                   |
|   your own space, sealed off from every other        |
|   AWS customer's traffic, even on shared hardware     |
|                                                       |
|   +----------------+        +----------------+       |
|   |  Public room   |        |  Private room  |       |
|   |  (subnet)      |        |  (subnet)      |       |
|   +----------------+        +----------------+       |
|                                                       |
+-----------------------[ FRONT GATE = IGW ]-----------+
                                |
                            Internet
```

```
                         AWS
+----------------------------------------------------+
|                                                      |
|   Company A              Company B                  |
|   +-----------+          +-----------+               |
|   |    VPC    |          |    VPC    |               |
|   | EC2       |          | EC2       |               |
|   | Database  |          | Database  |               |
|   +-----------+          +-----------+               |
|                                                      |
+----------------------------------------------------+
```

Company A's resources aren't sitting inside Company B's network just
because both live in AWS — each VPC is its own separate networking
environment.

| Compound piece | AWS name | Job |
|---|---|---|
| The wall | VPC | Your own isolated space |
| Rooms inside | Subnets | Some public (street-facing), some private (inner office) |
| The front gate | Internet Gateway | The one controlled door to the internet |
| The guard's rulebook | Security groups + route tables | Who may pass, and which direction |

**Important beginner correction:** creating a VPC does **not** automatically
mean it can reach the internet. A VPC by itself is just an isolated address
space — subnets, route tables, and an internet gateway are the pieces that
actually create a path outward, and each is covered in its own file in this
session.

**Why this matters at a company:** the VPC boundary is also the blast-radius
boundary. When something goes wrong, "which VPC is this in" is one of the first
triage questions, because a misconfiguration inside one VPC cannot reach into a
completely separate VPC by accident.

---

## Addresses: The CIDR Block

Every VPC gets a range of private addresses written as a CIDR block. **You only
need to read it, not calculate it.**

```
10.0.0.0/16                <- the whole VPC        (~65,536 addresses)
   |
   +-- 10.0.1.0/24         <- one subnet            (256 addresses)
          |
          +-- 10.0.1.37    <- one server            (1 address)
```

**Rule of thumb: bigger `/number` = smaller range.**

- `/16` = a whole neighborhood
- `/24` = one street in that neighborhood
- a single IP = one house on that street

| CIDR | What it is | Address count |
|---|---|---|
| `10.0.0.0/16` | The whole VPC | ~65,000 |
| `10.0.1.0/24` | One subnet | 256 |
| `10.0.1.37` | One server | 1 |

---

## Availability Zones — where a subnet actually lives

An AWS **Region** (like `us-east-1`) is a geographic area containing several
**Availability Zones (AZs)** — physically separate data centers designed so
a failure in one doesn't take down the others:

```
                 AWS Region
        +-------------------------+
        |                         |
        | AZ-A      AZ-B      AZ-C|
        |  |         |         |  |
        | DC        DC        DC  |
        |                         |
        +-------------------------+
```

**A subnet belongs to exactly one AZ** — you never stretch one subnet
across two AZs:

```
Region
 |
 +-- AZ-A
 |    +-- Subnet A   10.0.1.0/24
 |
 +-- AZ-B
 |    +-- Subnet B   10.0.2.0/24
 |
 +-- AZ-C
      +-- Subnet C   10.0.3.0/24
```

**Why this matters for real availability:** an application running in only
one AZ goes down completely if that AZ has a serious failure.

```
Single-AZ (fragile):                 Multi-AZ (resilient):

  Load Balancer                        Load Balancer
       |                                    |
     AZ-A                          +--------+--------+
       |                           v                 v
     EC2-A                       AZ-A               AZ-B
                                 EC2-A              EC2-B

  AZ-A fails -> app is           AZ-A fails -> traffic
  fully down                     shifts to AZ-B, app
                                  keeps serving
```

This is the entire reason you'll keep hearing "deploy across multiple AZs"
— it's not a checkbox, it's what actually keeps an application alive
through a data-center-level failure.

## CIDR planning across AZs — a realistic layout

Putting the CIDR block and the AZ concept together, a typical two-AZ VPC
gets carved up like this:

```
             VPC 10.0.0.0/16
                    |
        +-----------+-----------+
        |                       |
      AZ-A                    AZ-B
        |                       |
   +----+----+             +----+----+
   |         |             |         |
Public    Private        Public    Private
10.0.1   10.0.11        10.0.2    10.0.12
```

Four subnets, two per AZ (one public, one private), all carved out of the
same `/16`. This is the shape almost every real two-tier architecture
starts from.

---

## Vocabulary Reference

| Term | Plain definition |
|---|---|
| VPC | Your isolated private network inside AWS |
| CIDR block | The address range assigned to the VPC or subnet |
| Subnet | A subdivision of the VPC's address range, tied to one Availability Zone |
| Availability Zone (AZ) | A physically separate data center within an AWS region |
| Internet Gateway (IGW) | The single attachment point that lets a VPC reach the public internet |

---

## Why companies use multiple VPCs — blast radius

```
                    AWS Account
                         |
          +--------------+--------------+
          |              |              |
        Dev VPC       Staging VPC     Prod VPC
          |              |              |
       testing         testing         real users
```

If someone makes a bad networking change in Dev, a separate VPC boundary
means that mistake has no path into Staging or Prod:

```
Dev mistake  ---X--->  Production   (blocked by the VPC boundary itself,
                                     not just by discipline)
```

This is what "controlling blast radius" means in practice — the isolation
is structural, not just a naming convention.

## CIDR overlap — the problem that bites you later

Two VPCs each built with the same range look fine in isolation:

```
VPC-A: 10.0.0.0/16          VPC-B: 10.0.0.0/16

     both contain 10.0.1.10 -- but they mean
     two completely different machines
```

The moment you need those VPCs to talk to each other (VPC peering, a
Transit Gateway, a VPN), the overlap becomes a real blocker — peered VPCs
cannot have overlapping CIDR blocks, and there's no clean fix after the
fact. This is why CIDR planning happens **before** building out
infrastructure, not after.

---

## Real-World Grounding

- Companies use VPCs to give each environment (dev/staging/prod) — or sometimes
  each team — a hard isolation boundary, not just a naming convention.
- A VPC also underpins compliance requirements (PCI-DSS, HIPAA, etc.) where
  auditors need to see network-level proof that sensitive systems are isolated.
- VPC peering and Transit Gateway exist because companies eventually need
  multiple VPCs to talk to each other in a controlled way — and CIDR planning
  done early is what makes that possible later.

---

## Interview Questions

1. What is a VPC and why does every AWS resource live inside one?
2. What does the `/16` vs `/24` in a CIDR block actually mean?
3. Why is a subnet tied to exactly one Availability Zone, and why does that
   matter for availability?
4. Why would a company use multiple VPCs instead of one big one?
5. Why does CIDR overlap between two VPCs become a real problem, and when
   does it actually surface?

---

## Common Mistakes

- Assuming a bigger CIDR range is always better — oversized ranges waste address
  space and make subnet planning harder later.
- Reusing overlapping CIDR ranges across VPCs that will eventually need to be
  peered together (peered VPCs cannot have overlapping CIDR blocks).
- Doing default-VPC work in a real project just because it's already there.
- Running a "highly available" application entirely inside one Availability
  Zone, which defeats the purpose before a single line of infrastructure
  code is written.
