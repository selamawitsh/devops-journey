# 08 — Routing

## Learning Objectives
By the end of this module you should be able to:
- Explain what a routing table is and how a router chooses a path
- Configure static routes and a default route
- Understand administrative distance at a basic level
- Know the *names* and *purpose* of common dynamic routing protocols (not configure them yet)
- Diagnose a broken path using `show ip route`, `ping`, and `traceroute`

## Why This Matters
Every time you set up a VPC route table, a Kubernetes pod-to-pod network, or a VPN, you're configuring the cloud-native version of what you'll do here manually. Static routes are also exactly what you'll debug when "the service can't reach the database" turns out to be a missing route, not a firewall or DNS problem.

## Core Concepts

### What routing is
Switching moves frames *within* a broadcast domain (Layer 2, by MAC address). **Routing** moves packets *between* different networks (Layer 3, by IP address). A router's whole job is: "given this destination IP, which interface/next-hop do I send this out of?"

### The routing table
Every router keeps a table of known networks. For each packet, the router picks the entry with the **longest prefix match** — the most specific matching route wins over a more general one. A route to `10.10.10.0/24` is preferred over a route to `10.0.0.0/8` if both match, because `/24` is more specific.

Routes get into the table one of three ways:
- **Directly connected (C)** — a network on an interface the router is physically configured for
- **Static (S)** — you typed it in by hand
- **Dynamic (learned via a routing protocol)** — routers exchange routes automatically

### Static routes
Syntax pattern (Cisco IOS):
```
ip route <destination-network> <subnet-mask> <next-hop-ip>
```
Example:
```
ip route 10.10.30.0 255.255.255.0 10.10.20.2
```
This says: "to reach `10.10.30.0/24`, send packets to `10.10.20.2`."

### The default route
A **default route** is the "catch-all" — used when no more specific route matches:
```
ip route 0.0.0.0 0.0.0.0 <next-hop>
```
This is exactly what your home router uses to send all internet-bound traffic to your ISP.

### Administrative distance (just enough to know it exists)
When a router learns the *same* destination from two different sources (e.g., a static route and OSPF), **administrative distance (AD)** decides which one wins — lower AD wins. Directly connected = 0, static = 1 (very trusted), OSPF = 110, RIP = 120, etc. You don't need to memorize the full table yet — just know this is *why* a static route can silently override a dynamic one.

### Dynamic routing protocols (awareness level only)
You won't configure these yet, but know what they are for:
- **RIP** — oldest, simplest, hop-count based. Rarely used in production today.
- **OSPF** — link-state protocol, very common inside a single organization's network.
- **EIGRP** — Cisco-proprietary, popular in enterprise networks.
- **BGP** — the protocol that runs the actual internet; used *between* organizations/ISPs, and inside cloud provider backbones.

## Key Commands Cheat Sheet
```
ip route 10.10.30.0 255.255.255.0 10.10.20.2
ip route 0.0.0.0 0.0.0.0 203.0.113.1

show ip route
show ip interface brief
ping 10.10.30.5
traceroute 10.10.30.5
```

---

## Lab Exercise (`lab.pkt`)

### Topology
```
 LAN-A            LAN-B            LAN-C
10.10.10.0/24   10.10.20.0/24   10.10.30.0/24
   |                 |                 |
 [PC-A]--[Router1]--[Router2]--[Router3]--[PC-C]
                       |
                     [PC-B]
```
- 3 routers in a line, each with a LAN behind it
- Router1 ↔ Router2 link: `10.0.12.0/30`
- Router2 ↔ Router3 link: `10.0.23.0/30`

### Steps
1. **Build the topology** in Packet Tracer with 3 routers, 3 switches (one per LAN), and one PC per LAN.
2. **Assign IP addresses**:
   - Each router's LAN-facing interface gets the `.1` address of its LAN subnet (this is each PC's gateway)
   - Each router-to-router link gets addresses from its `/30`
   - Each PC gets an IP in its LAN's subnet with the router as its default gateway
3. **Verify directly connected routes** on each router: `show ip route` — you should see `C` entries for every directly attached subnet, but nothing for the *other* routers' LANs yet.
4. **Configure static routes** so every router can reach every subnet. On Router1, you need routes to LAN-B and LAN-C (via Router2). On Router3, you need routes to LAN-A and LAN-B (via Router2). Router2 needs nothing extra — it's directly connected to both links.
   - Tip: Router1 and Router3 each need **two** static route lines (one per remote subnet), since they aren't directly attached to Router2's far side.
5. **Verify** `show ip route` on all three routers — confirm `S` entries appear for the remote subnets.
6. **Test end-to-end**: `ping` from PC-A to PC-C. It should succeed and cross both router hops.
7. **Trace the path**: run `tracert` (Packet Tracer) or `traceroute` from PC-A to PC-C and confirm you see Router1 → Router2 → Router3 as hops.

### Stretch Goal — Break It On Purpose
Delete one static route (e.g., Router3's route back to LAN-A) and re-run the ping from PC-A to PC-C. Notice it now fails — but only in *one direction* if you didn't also break the return route. This "one-way failure" pattern is one of the single most common real-world networking bugs — get comfortable spotting it now.

### Checkpoint Questions
1. Why doesn't Router2 need any static routes in this topology, but Router1 and Router3 do?
2. If a router has both a static route and an OSPF-learned route to the same destination, which one wins, and why?
3. What does "longest prefix match" mean, and why does it matter?
4. In the "break it on purpose" exercise — why did deleting only Router3's return route cause a failure even though Router1's route to LAN-C was still fine?
