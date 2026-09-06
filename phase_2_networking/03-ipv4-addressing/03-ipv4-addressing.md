# Session 03 — IPv4 Addressing

Subnetting, routing, cloud networking, security groups, VPCs — almost
everything later in DevOps depends on understanding IP addresses
properly. This session builds that foundation.

## What you'll be able to do after this session

- Explain what an IPv4 address represents
- Understand network portion vs host portion
- Understand subnet masks
- Identify private vs public IP addresses
- Understand loopback addresses
- Understand static IP vs DHCP
- Read the IP configuration of your own machine
- Configure IPv4 addresses in Packet Tracer
- Troubleshoot basic IP-address problems

## What is an IP address?

An IP address identifies a network interface on an IP network — the same
way a street address identifies a house:

```
House #25, Example Street   →   where to deliver something, physically
192.168.1.10                →   where to deliver something, on a network
```

```
       Switch
      /      \
     /        \
   PC1        PC2

PC1 = 192.168.1.10
PC2 = 192.168.1.20
```

For PC1 to send data to PC2, it needs to know where `192.168.1.20` is —
that's what IP addressing solves: identifying which network the
destination belongs to, and which host within that network it is.

## IPv4 structure: 32 bits, 4 octets

```
192       .   168      .    1      .    10
octet         octet         octet       octet
(8 bits)      (8 bits)      (8 bits)    (8 bits)

8 + 8 + 8 + 8 = 32 bits total
```

Each octet ranges `0–255` — that's why `192.168.1.300` is invalid (300 >
255).

Underneath the decimal, each octet is binary:

```
192 = 11000000
168 = 10101000
1   = 00000001
10  = 00001010

Full address: 11000000.10101000.00000001.00001010
```

You don't need to convert binary by hand yet — that's Session 04
(Subnetting). For now: **IPv4 = 32 bits = 4 octets = each octet 0–255.**

## Network portion vs host portion

The most important concept in this session. An IP address has two
logical parts:

```
192.168.1.10/24

Network            Host
<--------------->  <---->
192.168.1          10
```

The `/24` says how many of the 32 bits belong to the network portion.

### Apartment-building analogy

```
Building: 192.168.1        →  the network
Apartment: 10               →  the host

192.168.1.10 = "Apartment 10 inside building 192.168.1"
192.168.1.20 = "Apartment 20 inside the same building"
```

Two devices with the same `/24` network portion (`192.168.1.x`) are on
the same network and can talk directly — no router needed.

## CIDR notation

```
32 total bits
- 24 network bits
----------------
  8 host bits

/24  →  Network = 24 bits, Host = 8 bits
```

## Subnet mask

`/24` and `255.255.255.0` mean the same thing:

```
192.168.1.10/24
        ≡
IP address:  192.168.1.10
Subnet mask: 255.255.255.0
```

| CIDR | Subnet Mask |
|---|---|
| `/8` | `255.0.0.0` |
| `/16` | `255.255.0.0` |
| `/24` | `255.255.255.0` |

*Why these specific values work is covered in the subnetting session —
for now, just memorize the pairing.*

## Network address, host range, broadcast address

For `192.168.1.10/24`:

```
192.168.1 | 10
^^^^^^^^^   ^^
 network    host
```

```
Network address:   192.168.1.0        (represents the whole network)
Usable hosts:       192.168.1.1  →  192.168.1.254   (254 addresses)
Broadcast address:  192.168.1.255      (send to everyone on this subnet)
```

### Broadcast, as an analogy

Someone standing outside the apartment building shouting "EVERYONE
INSIDE, LISTEN!" — that's a broadcast. For `192.168.1.0/24`, that's
`192.168.1.255`.

## Private vs public IP addresses

Common private ranges:

```
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16
```

```
                Internet
                   |
                Router
                   |
        ┌──────────┴──────────┐
        │                     │
      Laptop                Phone
  192.168.1.8           192.168.1.9
```

These addresses only mean something inside your local network — your
router has a separate address on the internet side. This is the same
concept you'll see again in AWS VPCs:

```
VPC
├── Private subnet
│   ├── EC2
│   └── Database
│
└── Public subnet
    └── Load Balancer
```

## Loopback address

```
127.0.0.1
     |
     v
   ME  →  this computer, itself
```

`ping 127.0.0.1` tests your own machine's networking stack, not your
Wi-Fi or router. `localhost` normally resolves to `127.0.0.1`.

## Static IP vs DHCP

| | Static IP | DHCP |
|---|---|---|
| How it's set | Manually configured | Automatically assigned |
| Typical use | Servers, routers, infrastructure — anything needing a predictable address | Laptops, phones — anything that just needs "an" address |
| Flow | You type the IP, mask, gateway, DNS yourself | Device asks a DHCP server, which replies with IP/mask/gateway/DNS |

```
Laptop
   |
   | "I need network configuration"
   v
DHCP Server
   |
   | "Here you go"
   v
192.168.1.8
```

## Reading your own machine's config

```
Interface: wlp0s20f3
IP:        192.168.1.8/24
Network:   192.168.1.0/24
Mask:      255.255.255.0
Broadcast: 192.168.1.255

192.168.1.0/24
│
├── 192.168.1.1
├── 192.168.1.2
├── ...
├── 192.168.1.8   ← this machine
├── ...
└── 192.168.1.254
```

## Labs

### Lab 1 — Inspect your Ubuntu IP

```bash
ip addr
ip addr show wlp0s20f3
ip route
```

Expect to see `inet 192.168.1.8/24` and `default via 192.168.1.1 dev
wlp0s20f3` (your actual gateway may differ).

### Lab 2 — Loopback

```bash
ping -c 4 127.0.0.1
ping -c 4 localhost
```

### Lab 3 — Identify your network

```bash
ip -4 addr
```

Fill in from your output: IP, CIDR, Network, Subnet mask, Broadcast,
Default gateway.

### Packet Tracer lab

```
Topology:  PC1 ── Switch ── PC2

PC1:
  IP Address:      192.168.10.10
  Subnet Mask:     255.255.255.0
  Default Gateway: (leave empty)

PC2:
  IP Address:      192.168.10.20
  Subnet Mask:     255.255.255.0
  Default Gateway: (leave empty)

Test:
  ping 192.168.10.20   (from PC1)   → expect reply
```

**Break it intentionally:**

```
Change PC2's IP to: 192.168.20.20
Keep PC1 at:         192.168.10.10/24

ping 192.168.20.20   (from PC1)   → expect failure

Reason: 192.168.10.0/24 and 192.168.20.0/24 are different
networks, and there is no router connecting them.
```

## Mental model

```
IPv4
 ├── 32 bits
 ├── 4 octets
 ├── Network portion
 └── Host portion

192.168.1.10/24
   NETWORK       HOST
  <-------->   <---->
   192.168.1      10

192.168.1.0/24    = the network
192.168.1.255     = broadcast
127.0.0.1         = yourself
```

## Real-world grounding

The network/host split you're learning here is the exact same idea
you'll meet again in AWS VPC CIDR blocks and subnet sizing — a `/24` VPC
subnet behaves by the same math as a `/24` on your home Wi-Fi, just at
cloud scale. Getting comfortable with "which bits are network, which
bits are host" now is what makes subnetting, route tables, and security
group scoping click quickly later instead of feeling like new material.

## Common mistakes

- Assuming two devices can talk directly just because they're both
  "on a switch" — they also need to be in the same network (same network
  portion of the address), not just physically connected.
- Confusing the network address (`.0`) or broadcast address (`.255`) with
  a usable host address — neither can be assigned to a device.
- Treating a private IP as if it's directly reachable from the internet —
  it isn't, by itself; that's a separate (NAT/routing) concern.
- Mixing up subnet mask and default gateway when configuring a device
  manually.


## Active recall — don't look back 

1. How many bits does IPv4 have?
2. How many octets are in an IPv4 address?
3. What is the valid range of one IPv4 octet?
4. What does `/24` mean?
5. For `192.168.1.50/24`, what is the network address?
6. What is the broadcast address of `192.168.1.0/24`?
7. What is the difference between a private IP and a public IP?
8. What does `127.0.0.1` mean?
9. What's the difference between static IP addressing and DHCP?
10. Why can `192.168.1.10/24` and `192.168.1.20/24` communicate directly
    without a router, but `192.168.1.10/24` and `192.168.2.20/24`
    cannot, through just a switch?
