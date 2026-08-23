# 07 — Switching & VLANs

## Learning Objectives
By the end of this module you should be able to:
- Explain how an Ethernet switch forwards frames using MAC addresses
- Distinguish a collision domain from a broadcast domain
- Explain *why* VLANs exist and what problem they solve
- Configure access ports, trunk ports, and 802.1Q tagging
- Read `show vlan brief`, `show interfaces trunk`, and `show mac address-table` output

## Why This Matters
Every container platform, cloud VPC, and Kubernetes cluster you'll touch later sits on top of this layer. "Security groups" and "subnets" in AWS are the cloud-native descendants of VLANs and access ports. If switching and VLANs feel solid, isolating environments in the cloud will feel like déjà vu instead of new material.

## Core Concepts

### How a switch actually forwards traffic
A switch operates at Layer 2 (Ethernet). It keeps a **MAC address table**: a map of `MAC address → physical port`, built by watching the *source* MAC address of every frame that arrives.

- If the destination MAC is in the table → frame goes out that one port only.
- If the destination MAC is unknown → the switch **floods** the frame out every port (except the one it came in on).
- If the destination is a broadcast address (`FF:FF:FF:FF:FF:FF`) → it always floods.

### Collision domain vs. broadcast domain
- **Collision domain**: a segment where frames can collide if two devices transmit at once. Modern switches give every port its own collision domain (this problem is basically solved on wired Ethernet).
- **Broadcast domain**: the set of devices that receive each other's broadcasts. By default, *every port on a switch is in the same broadcast domain* — this is the actual problem VLANs solve.

### Why VLANs exist
As a flat network grows, broadcast traffic (ARP requests, DHCP discovers, etc.) goes to every single device, and any device can talk to any other device by default. That's bad for both performance and security.

A **VLAN (Virtual LAN)** logically splits one physical switch into multiple isolated broadcast domains. Devices in VLAN 10 cannot see broadcasts from VLAN 20, and by default cannot reach VLAN 20 at all — even though they're plugged into the same physical switch.

### Access ports vs. trunk ports
- **Access port**: belongs to exactly one VLAN. This is what an end device (PC, printer, server) plugs into. The device has no idea VLANs exist — the switch handles it.
- **Trunk port**: carries traffic for *multiple* VLANs over a single link, usually between switches, or between a switch and a router. To keep frames sorted by VLAN, trunk links tag each frame.

### 802.1Q tagging
When a frame crosses a trunk link, the switch inserts a small **VLAN tag** into the Ethernet header containing the VLAN ID (1–4094). The receiving switch reads the tag, strips it, and forwards the frame out the correct access port for that VLAN. End devices never see the tag — tagging only happens on trunk links.

One VLAN can be marked the **native VLAN** on a trunk — its frames are sent untagged. This exists for legacy compatibility and is a common misconfiguration/security gotcha in real networks, so it's worth remembering even at this stage.

### Inter-VLAN routing (preview)
VLANs isolate traffic at Layer 2 — meaning a plain switch **cannot** route between VLAN 10 and VLAN 20. That requires something with Layer 3 capability: a router, or an L3 switch. You'll touch this briefly in the lab below and in more depth in Module 08.

## Key Commands Cheat Sheet
```
vlan 10
 name ENGINEERING
!
interface fastEthernet 0/1
 switchport mode access
 switchport access vlan 10
!
interface fastEthernet 0/24
 switchport mode trunk
 switchport trunk allowed vlan 10,20
!
show vlan brief
show interfaces trunk
show mac address-table
```

---

## Lab Exercise (`lab.pkt`)

### Topology
Build this in Packet Tracer:
```
   PC1 (VLAN10)        PC3 (VLAN10)
      |                    |
   [Switch A]===trunk===[Switch B]
      |                    |
   PC2 (VLAN20)        PC4 (VLAN20)
```
- 2 switches, 4 PCs
- PC1 & PC2 connect to Switch A; PC3 & PC4 connect to Switch B
- PC1/PC3 → VLAN 10 (`10.10.10.0/24`)
- PC2/PC4 → VLAN 20 (`10.10.20.0/24`)

### Steps
1. **Wire it up** in Packet Tracer using straight-through cables for PC↔switch, and a crossover (or auto-MDIX) for switch↔switch.
2. **Create VLANs** on both switches:
   ```
   vlan 10
    name USERS
   vlan 20
    name SERVERS
   ```
3. **Assign access ports** on each switch (the ports facing PCs):
   ```
   interface fa0/1
    switchport mode access
    switchport access vlan 10
   ```
4. **Configure the trunk** on the switch-to-switch link on *both* switches:
   ```
   interface fa0/24
    switchport mode trunk
    switchport trunk allowed vlan 10,20
   ```
5. **Assign IP addresses** to the PCs (matching their VLAN's subnet) and set no gateway yet.
6. **Verify** on each switch:
   ```
   show vlan brief
   show interfaces trunk
   ```
7. **Test connectivity**:
   - `ping` from PC1 → PC3 (same VLAN, different switch) → should **succeed**
   - `ping` from PC1 → PC2 (different VLAN) → should **fail** (this is expected — VLANs are doing their job)
8. **Check the MAC table**: `show mac address-table` — confirm PC1 and PC3's MACs show up learned on the correct ports/VLAN.

### Stretch Goal — Router-on-a-Stick
Add a router connected to Switch A via a trunk link. Configure two subinterfaces (`fa0/0.10`, `fa0/0.20`), each with `encapsulation dot1Q <vlan-id>` and an IP address acting as the gateway for that VLAN. Re-test PC1 → PC2 — it should now succeed, routed through the router.

### Checkpoint Questions
1. Why can PC1 ping PC3 but not PC2, even though all four are on the same physical switch fabric?
2. What would happen if you forgot to add `switchport trunk allowed vlan 10,20` on the trunk port?
3. What's actually inside an 802.1Q tag, and where does it get added/removed?
4. Why do end devices (PCs) never need to know VLANs exist?
