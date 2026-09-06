# Session 06 — ARP & Ethernet

## The problem IP addressing alone doesn't solve

An IP address tells you *which network* and *which host*. But on the
actual wire, a switch doesn't forward traffic by IP address — it forwards
**Ethernet frames** by **MAC address**. Before your PC can actually send
a packet to `192.168.1.20`, something has to answer: *"which physical
interface is that?"*

```
IP address   → logical, "which network / which host" (Layer 3)
MAC address  → physical, "which actual network card" (Layer 2)
```

## The Ethernet frame

```
+-------------+-------------+----------+----------------+-----+
| Dest MAC    | Src MAC     | EtherType|    Payload      | FCS |
| (6 bytes)   | (6 bytes)   | (2 bytes)|  (IP packet)     |     |
+-------------+-------------+----------+----------------+-----+
```

The IP packet (with its source/destination IP addresses) rides inside
the Ethernet frame's payload. The frame itself is addressed with MAC
addresses, not IP addresses — that's the layer switches actually operate
on.

## MAC address format

```
AA:BB:CC:DD:EE:FF
^^^^^^^^^^^   ^^^^^^^^^
   OUI          device-specific
(vendor ID)      (unique per NIC)
```

6 bytes (48 bits) total, burned into (or assigned to) the network
interface. First 3 bytes typically identify the manufacturer.

## ARP: resolving IP to MAC

**Address Resolution Protocol** is the "who has this IP? tell me your
MAC" mechanism.

```
PC1 (192.168.1.10) wants to reach PC2 (192.168.1.20)
PC1 knows PC2's IP, but not PC2's MAC yet.

PC1 broadcasts (to everyone on the LAN):
   "Who has 192.168.1.20? Tell 192.168.1.10"

PC2 recognizes its own IP, replies directly (unicast) to PC1:
   "192.168.1.20 is at AA:BB:CC:11:22:33"

PC1 now has PC2's MAC and can send the Ethernet frame directly.
```

```
PC1                    Switch                   PC2
 |-- ARP Request (broadcast) -------------------->|
 |                                                  |
 |<------------- ARP Reply (unicast) --------------|
 |
 |-- Ethernet frame, dest MAC = PC2's MAC --------->|
```

## The ARP cache

Once resolved, the mapping is cached briefly so PC1 doesn't have to ARP
again for every packet:

```
IP Address       MAC Address          Type
192.168.1.20     AA:BB:CC:11:22:33    dynamic
192.168.1.1      AA:BB:CC:00:00:01    dynamic
```

## Analogy

An IP address is like a person's name — useful for figuring out which
building they're in. A MAC address is like the exact door of their
apartment. ARP is the act of asking the building directory once — "which
door is Sara behind?" — and then remembering the answer instead of asking
again for every letter you send her.

## What happens across networks

ARP is broadcast-based, and broadcasts don't cross routers — so ARP only
ever resolves addresses on the *same* network.

```
Same network:
  PC1 ARPs directly for PC2's MAC.

Different network:
  PC1 ARPs for its DEFAULT GATEWAY's MAC instead
  (never for the final destination's MAC directly).
  The gateway then handles getting the packet onward.
```

This connects straight back to Session 03: if the destination isn't on
your own network, your device only ever needs to resolve the *gateway's*
MAC — the packet's IP header still says the real final destination, but
the Ethernet frame is addressed to the gateway's MAC for the first hop.

## Real-world grounding

ARP is also a common attack surface — **ARP spoofing** (a device lying
about which MAC owns an IP, usually the gateway's) is a classic technique
for intercepting LAN traffic, which is part of why network segmentation
and switch security features matter beyond just IP-level controls like
security groups.

## Common mistakes

- Assuming ARP resolves the *final* destination's MAC even when that
  destination is on a different network — it resolves the gateway's MAC
  in that case, not the remote host's.
- Confusing MAC addresses (Layer 2, local to a network) with IP addresses
  (Layer 3, can be routed across networks).
- Forgetting ARP requests are broadcasts and therefore stay within a
  single broadcast domain/network.
- Treating the ARP cache as permanent — entries expire and get
  re-resolved.

## Interview answers

**1. What does ARP do?**
It resolves a known IP address to the corresponding MAC address on the
local network, so a device knows which physical interface to actually
address an Ethernet frame to.

**2. Why is ARP a broadcast?**
Because the sender doesn't yet know who owns the target IP — it has to
ask everyone on the local network, and only the device that owns that IP
replies.

**3. If PC1 wants to reach a device on a different network, what MAC
address does it actually resolve via ARP?**
Its default gateway's MAC address — not the remote device's — since the
frame's first hop is always to the gateway when the destination is off
the local network.

## Labs

### Ubuntu

```bash
arp -a
ip neigh
ping -c 2 192.168.1.1
arp -a
```

(the second `arp -a` should now show a fresh entry for the address you
just pinged)

### Packet Tracer

1. Add 2 PCs and 1 switch, same subnet (`192.168.1.10` and
   `192.168.1.20`, `/24`).
2. Switch to Simulation mode (not Realtime).
3. From PC1 command prompt: `ping 192.168.1.20`.
4. Step through the captured PDUs one at a time and identify:
   - the ARP Request frame (broadcast)
   - the ARP Reply frame (unicast, back to PC1)
   - the subsequent ICMP Echo Request/Reply frames
5. Click the ARP Request PDU and inspect the Ethernet header — confirm
   the destination MAC is `FFFF.FFFF.FFFF` (broadcast).
6. Click the ARP Reply PDU and confirm the destination MAC is now PC1's
   specific MAC address, not broadcast.

## Active recall — don't look back

1. What problem does ARP solve that IP addressing alone doesn't?
2. Is an ARP request sent as a broadcast or a unicast? What about the
   reply?
3. What does an ARP cache entry contain?
4. If PC1 wants to reach a device on a different subnet, whose MAC
   address does it actually ARP for?
5. What's inside the payload portion of an Ethernet frame?
6. How many bytes is a MAC address, and what do the first bytes
   typically identify?
7. Why doesn't an ARP request cross a router onto another network?
8. What's the practical difference between a MAC address and an IP
   address?
9. What is ARP spoofing, in your own words?
10. Explain, step by step, what happens from the moment PC1 runs
    `ping 192.168.1.20` (same subnet) to the first ICMP reply arriving.
