# VPC Fundamentals

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

| Compound piece | AWS name | Job |
|---|---|---|
| The wall | VPC | Your own isolated space |
| Rooms inside | Subnets | Some public (street-facing), some private (inner office) |
| The front gate | Internet Gateway | The one controlled door to the internet |
| The guard's rulebook | Security groups + route tables | Who may pass, and which direction |

Every AWS account gets a **default VPC** per region so you can launch something on
day one. In real work you always build your own VPC, because you want control over
the address range, the subnet layout, and the isolation boundary between
dev/staging/prod.

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

## Vocabulary Reference

| Term | Plain definition |
|---|---|
| VPC | Your isolated private network inside AWS |
| CIDR block | The address range assigned to the VPC or subnet |
| Subnet | A subdivision of the VPC's address range, tied to one Availability Zone |
| Availability Zone (AZ) | A physically separate data center within an AWS region |
| Internet Gateway (IGW) | The single attachment point that lets a VPC reach the public internet |

---

## Real-World Grounding

- Companies use VPCs to give each environment (dev/staging/prod) — or sometimes
  each team — a hard isolation boundary, not just a naming convention.
- A VPC also underpins compliance requirements (PCI-DSS, HIPAA, etc.) where
  auditors need to see network-level proof that sensitive systems are isolated.
- VPC peering and Transit Gateway exist because companies eventually need
  multiple VPCs to talk to each other in a controlled way — that's a topic
  beyond this session, but it's the natural next question once you're
  comfortable here.

---

## Interview Questions

1. What is a VPC and why does every AWS resource live inside one?
2. What does the `/16` vs `/24` in a CIDR block actually mean?
3. Why would a company use multiple VPCs instead of one big one?
4. What's the difference between the default VPC and a VPC you create yourself?

---

## Common Mistakes

- Assuming a bigger CIDR range is always better — oversized ranges waste address
  space and make subnet planning harder later.
- Reusing overlapping CIDR ranges across VPCs that will eventually need to be
  peered together (peered VPCs cannot have overlapping CIDR blocks).
- Doing default-VPC work in a real project just because it's already there.
