# Session 04 — Subnetting

## What subnetting solves

A `/24` gives you one network with 254 usable hosts. But real networks
need to be split up — app servers isolated from database servers,
management traffic isolated from user traffic. **Subnetting** means
borrowing bits from the host portion to create multiple, smaller
networks out of one larger one.

## Borrowing bits, visually

```
Before:  192.168.1.0/24
         Network (24 bits)        Host (8 bits)
         <-------------------->  <-------->

After (borrow 2 bits for 4 subnets):  /26
         Network (24 bits) + 2 borrowed   Host (6 bits)
         <--------------------------->  <------>
```

Borrowing bits grows the network portion — more networks, fewer hosts
per network.

## The two numbers that matter

```
Number of subnets            = 2 ^ (borrowed bits)
Number of usable hosts/subnet = 2 ^ (remaining host bits) - 2
```

Example — `/24` → `/26` (borrow 2 bits):

```
2 borrowed bits  → 2^2 = 4 subnets
6 remaining bits → 2^6 - 2 = 62 usable hosts per subnet
```

## Worked example: 192.168.1.0/24 → four /26 subnets

| Subnet | Network | Usable range | Broadcast |
|---|---|---|---|
| 0 | 192.168.1.0/26 | .1 – .62 | .63 |
| 1 | 192.168.1.64/26 | .65 – .126 | .127 |
| 2 | 192.168.1.128/26 | .129 – .190 | .191 |
| 3 | 192.168.1.192/26 | .193 – .254 | .255 |

```
192.168.1.0/24
     |
     +-- 192.168.1.0/26    (subnet 0)
     +-- 192.168.1.64/26   (subnet 1)
     +-- 192.168.1.128/26  (subnet 2)
     +-- 192.168.1.192/26  (subnet 3)
```

## The "magic number" shortcut

```
Mask octet value  →  block size
255.255.255.192   →  256 - 192 = 64

Subnets start at multiples of the block size: 0, 64, 128, 192
```

This is the fast way to find subnet boundaries without listing binary
every time.

## CIDR / mask / hosts reference

| CIDR | Mask | Host bits | Usable hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 8 | 254 |
| /25 | 255.255.255.128 | 7 | 126 |
| /26 | 255.255.255.192 | 6 | 62 |
| /27 | 255.255.255.224 | 5 | 30 |
| /28 | 255.255.255.240 | 4 | 14 |
| /29 | 255.255.255.248 | 3 | 6 |
| /30 | 255.255.255.252 | 2 | 2 |

## Real-world grounding

AWS VPC subnets are sized with exactly this math — splitting a `/16` VPC
into `/24` subnets across Availability Zones, or a `/24` subnet further
into `/28`s for a specific tier. One AWS-specific wrinkle worth
remembering once you get there: AWS reserves 5 addresses per subnet (not
2) for networking overhead — the math above is the general-networking
baseline you'll adjust from.

## Common mistakes

- Forgetting that AWS reserves more addresses per subnet than the
  general "-2" rule.
- Miscounting host bits vs. borrowed bits when moving from `/24` to a
  smaller prefix.
- Assuming every subnet from one subnetting operation must be the same
  size — that constraint is exactly what VLSM (Session 05) removes.
- Picking a subnet boundary that isn't a multiple of the block size.

## Interview answers

**1. What does subnetting actually do?**
It borrows bits from the host portion of an address to create multiple
smaller networks from one larger one, at the cost of fewer usable hosts
per network.

**2. How many usable hosts are in a /27?**
30 — 5 host bits, `2^5 - 2 = 30`.

**3. How do you find subnet boundaries quickly?**
Take the block size (`256 - mask octet value`) and list its multiples —
those are your subnet network addresses.

## Labs

### Ubuntu

```bash
sudo apt install ipcalc
ipcalc 192.168.1.0/26
ipcalc 192.168.1.64/26
```

### Packet Tracer

1. Add 1 router, 2 switches, 4 PCs (2 per switch).
2. Router interface Gi0/0:
   ```
   IP Address: 192.168.1.1
   Subnet Mask: 255.255.255.192
   ```
3. Router interface Gi0/1:
   ```
   IP Address: 192.168.1.65
   Subnet Mask: 255.255.255.192
   ```
4. PC1 (on switch 1):
   ```
   IP Address:      192.168.1.10
   Subnet Mask:     255.255.255.192
   Default Gateway: 192.168.1.1
   ```
5. PC2 (on switch 1):
   ```
   IP Address:      192.168.1.20
   Subnet Mask:     255.255.255.192
   Default Gateway: 192.168.1.1
   ```
6. PC3 (on switch 2):
   ```
   IP Address:      192.168.1.70
   Subnet Mask:     255.255.255.192
   Default Gateway: 192.168.1.65
   ```
7. PC4 (on switch 2):
   ```
   IP Address:      192.168.1.80
   Subnet Mask:     255.255.255.192
   Default Gateway: 192.168.1.65
   ```
8. From PC1: `ping 192.168.1.70` → expect reply (routed between subnets).
9. Remove the router's IP config on Gi0/0 → repeat step 8 → expect
   failure.

## Active recall — don't look back

1. What does subnetting actually do to an IP address?
2. If you subnet a `/24` into 8 subnets, what's the new CIDR prefix?
3. How many usable hosts are in a `/28` subnet?
4. What is the block size for a `/27` network?
5. List the four subnet boundaries when subnetting `10.0.0.0/24` into
   `/26` subnets.
6. What's the broadcast address of `192.168.1.64/26`?
7. Why does the usable-host formula subtract 2?
8. True or false: every subnet from one subnetted network must be the
   same size.
9. What's the difference between a network address and the first usable
   host address?
10. In your own words, why does borrowing more bits mean fewer hosts per
    subnet?
