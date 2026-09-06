# Session 05 — CIDR & VLSM

## The problem with fixed-size subnetting

Session 04 subnetted a network into equal-sized pieces. But real
departments don't need equal-sized networks:

```
Department        Hosts needed
----------        ------------
Sales                50
Engineering          20
Finance              10
Router link           2
```

If you force all four into equal `/26` subnets (62 hosts each), the
Finance and router-link subnets waste dozens of addresses each. **VLSM
(Variable Length Subnet Masking)** fixes this by sizing each subnet to
what it actually needs.

## The VLSM rule: allocate largest first

```
1. Sort needs largest to smallest
2. Assign the smallest subnet that still fits each need
3. Start the next allocation right after the previous one ends
```

## Worked example: allocating from 192.168.1.0/24

| Need | Hosts needed | Smallest fitting prefix | Usable hosts | Subnet assigned |
|---|---|---|---|---|
| Sales | 50 | /26 | 62 | 192.168.1.0/26 |
| Engineering | 20 | /27 | 30 | 192.168.1.64/27 |
| Finance | 10 | /28 | 14 | 192.168.1.96/28 |
| Router link | 2 | /30 | 2 | 192.168.1.112/30 |

```
192.168.1.0/24
     |
     +-- 192.168.1.0/26    (Sales, 62 hosts)
     +-- 192.168.1.64/27   (Engineering, 30 hosts)
     +-- 192.168.1.96/28   (Finance, 14 hosts)
     +-- 192.168.1.112/30  (Router link, 2 hosts)
     +-- 192.168.1.116 – .255  (still free for future growth)
```

Compare that with equal `/26`s for all four: `4 × 64 = 256` addresses used
just for the *first two* needs' worth of waste. VLSM leaves over 130
addresses unused and available for future growth instead.

## Why point-to-point links get /30 (or /31)

A link between two routers only ever has two devices on it. A `/30` gives
exactly 2 usable addresses — no more, no less:

```
192.168.1.112/30
  Network:   .112
  Host 1:    .113  (router A)
  Host 2:    .114  (router B)
  Broadcast: .115
```

Some environments use `/31` for point-to-point links (2 addresses, no
network/broadcast reserved) — worth knowing exists, not needed for this
session's labs.

## Route summarization — the reverse operation

VLSM breaks one network into many. **Summarization** does the opposite:
representing many contiguous networks as one route, so routing tables
stay small.

```
192.168.0.0/24
192.168.1.0/24
192.168.2.0/24
192.168.3.0/24
        |
        v
  summarized as: 192.168.0.0/22
```

One routing table entry instead of four — this is why VLSM allocations
are usually planned to stay contiguous.

## Real-world grounding

This is exactly how VPC subnets get sized in practice: a small `/28` for
a NAT gateway or bastion subnet, a larger `/24` for an application tier,
maybe a `/26` for a database tier — all carved out of one VPC CIDR block
using the same "size each subnet to its actual need" logic, not equal
slices.

## Common mistakes

- Allocating the smallest needs first, fragmenting the address space so
  the largest need no longer fits contiguously.
- Forgetting to leave room for growth — allocating every address
  immediately with nothing spare.
- Using a `/24` for a 2-host router link out of habit instead of a `/30`.
- Assuming VLSM subnets must still all share the same prefix length —
  the entire point is that they don't.

## Interview answers

**1. What is VLSM and why does it exist?**
Variable Length Subnet Masking allows different subnets within the same
network to have different sizes, so each subnet is sized to its actual
host requirement instead of forcing a uniform, wasteful subnet size
across the board.

**2. Why allocate largest-to-smallest in VLSM?**
Because starting with the biggest need first keeps allocations
contiguous and avoids fragmenting the remaining address space in a way
that makes a later, larger allocation no longer fit.

**3. What's the difference between subnetting and route summarization?**
Subnetting divides one network into many smaller ones; summarization
does the reverse — representing multiple contiguous networks as a single,
larger route to keep routing tables smaller.

## Labs

### Manual VLSM worksheet

```bash
ipcalc 192.168.1.0/26
ipcalc 192.168.1.64/27
ipcalc 192.168.1.96/28
ipcalc 192.168.1.112/30
```

Verify each subnet's network, broadcast, and usable range match the
table above.

### Packet Tracer

1. Add 1 router, 4 switches, PCs matching each department's headcount
   (or a representative few per switch).
2. Router sub-interfaces / physical interfaces, one per department:
   ```
   Gi0/0: 192.168.1.1/26    (Sales)
   Gi0/1: 192.168.1.65/27   (Engineering)
   Gi0/2: 192.168.1.97/28   (Finance)
   ```
3. Configure each PC with an IP from its department's usable range and
   the matching gateway.
4. Ping across departments (e.g. a Sales PC to a Finance PC) → expect
   reply, routed through the router.
5. Add a second router, connect it to the first over the
   `192.168.1.112/30` link, and configure both router ends
   (`.113` and `.114`).
6. Ping across the router-to-router link → expect reply.

## Active recall — don't look back

1. What problem does VLSM solve that plain subnetting doesn't?
2. Why allocate the largest subnet first in a VLSM plan?
3. What's the smallest prefix that fits 20 hosts? Show the math.
4. Why is `/30` a common choice for a router-to-router link?
5. What does route summarization do, and why does it matter for routing
   tables?
6. Summarize `10.0.0.0/24` through `10.0.3.0/24` into a single CIDR
   block.
7. If you allocate the smallest subnets first, what problem can you run
   into later?
8. True or false: all subnets produced by VLSM must share the same
   prefix length.
9. Why leave unused address space at the end of a VLSM plan?
10. In your own words, explain the difference between subnetting and
    summarization.
