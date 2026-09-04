# 01 — TCP/IP Fundamentals

The goal of this session is not to memorize terms. It's to be able to answer
one question:

> **What happens when one computer sends data to another computer?**

Everything later — subnetting, routing, DNS, firewalls, Docker networking,
AWS VPCs, Kubernetes networking — builds on this answer.

---

## 1. What Is a Network

A network is just a group of devices that can communicate with each other.

```
PC1 ─────────── PC2
```

Add a third device and it's still a network:

```
PC1
 │
PC2
 │
PC3
```

Real networks use dedicated devices — switches and routers — to manage that
communication instead of wiring every device to every other device directly.

---

## 2. Switch — Connects Devices Inside a Local Network

```
              ┌─────────┐
   PC1 ───────│         │
   PC2 ───────│ Switch  │
   PC3 ───────│         │
   PC4 ───────│         │
              └─────────┘
```

If PC1 wants to reach PC3, the switch delivers the Ethernet frame to the
right device. Think of it as a traffic coordinator for one local network.
MAC addresses and how the switch actually makes that delivery decision are
covered in 06-arp-ethernet and 07-switching-vlans.

**Switch = connects devices inside a local network.**

---

## 3. Router — Connects Different Networks

```
  Network A                      Network B
  PC1                            PC3
   │                              │
 Switch                        Switch
   │                              │
   └────────────Router────────────┘

  192.168.1.0/24  ──  Router  ──  192.168.2.0/24
```

**Router = connects different IP networks and forwards packets between
them.**

Switch and router solve different problems: one operates inside a single
local network, the other moves data between separate networks entirely.
Full routing detail lives in 08-routing.

---

## 4. Data Gets Wrapped: Encapsulation (Preview)

An application can't just throw raw text onto the wire. Data gets packaged
with the information needed to deliver it — the same idea as addressing a
physical package before shipping it:

```
┌─────────────────────┐
│ PACKAGE              │
│ To:   Nahom           │
│ From: Selamawit        │
│ Hello                   │
└─────────────────────┘
```

This wrapping process is called **encapsulation**, covered in full in
02-osi-encapsulation. For now, just hold onto the idea that data gets
layers added to it before it travels.

---

## 5. Packets

A packet is a unit of data being transmitted across the network at the IP
layer:

```
Your Data
   │
┌───────────────────────┐
│ Network information    │
│ Your actual data       │
└───────────────────────┘
   │
Packet
```

When someone says "the packet is going from server A to server B," this is
what they mean.

---

## 6. IP Address vs MAC Address

Two different addresses answer two different questions.

| | IP address | MAC address |
|---|---|---|
| Question it answers | Which network/building am I trying to reach? | Which specific interface on this local network receives the frame? |
| Layer | Internet layer — logical address | Link layer — local network interface address |
| Example | `192.168.1.10` | `40:EC:99:D3:19:72` |
| Scope | Routable between networks | Only meaningful on the local network |

```
PC1                              PC2
192.168.1.10  ──── data ────►  192.168.1.20
```

Don't confuse the two — full addressing detail lives in 03-ipv4-addressing,
and ARP (how IP and MAC actually get linked together) is covered in
06-arp-ethernet.

---

## 7. Protocols

A protocol is a set of agreed-upon rules for communication — the same
problem two people have if one only speaks English and the other only
Amharic. Computers need the same kind of shared agreement.

| Protocol | Purpose |
|---|---|
| HTTP | Web communication |
| DNS | Name resolution |
| TCP | Reliable transport |
| UDP | Connectionless transport |
| IP | Addressing and routing |
| SSH | Secure remote access |

---

## 8. The TCP/IP Model

The Internet is generally described using four layers:

```
┌─────────────────────────┐
│      APPLICATION         │   HTTP, DNS, SSH
├─────────────────────────┤
│       TRANSPORT          │   TCP, UDP
├─────────────────────────┤
│        INTERNET          │   IP
├─────────────────────────┤
│          LINK            │   Ethernet, Wi-Fi
└─────────────────────────┘
```

**Application** — where applications talk using network protocols (HTTP,
HTTPS, DNS, SSH, SMTP). Opening `https://example.com` is HTTP/HTTPS at this
layer.

**Transport** — TCP or UDP. TCP establishes a connection and guarantees
reliable, ordered delivery. UDP skips that overhead entirely — no
connection, no ordering guarantee — which is why it fits DNS queries and
real-time applications where speed matters more than guaranteed delivery.

**Internet** — primarily IP. Its job is getting packets between networks;
routers make forwarding decisions here based on IP information and their
routing tables.

**Link** — the local network technology itself: Ethernet, Wi-Fi. Frames,
MAC addresses, and local delivery live here.

---

## 9. Encapsulation and Decapsulation, Put Together

Sending "Hello" through the stack, layer by layer:

```
APPLICATION   HTTP + Hello
     │ data
     ▼
TRANSPORT     TCP + HTTP + Hello
     │ segment
     ▼
INTERNET      IP + TCP + HTTP + Hello
     │ packet
     ▼
LINK          Ethernet + IP + TCP + HTTP + Hello
     │ frame
     ▼
   NETWORK
```

The receiving computer does the exact reverse — **decapsulation** — peeling
each layer off in order until only the original application data is left:

```
Frame → Packet → Segment → Application data
```

Full round trip:

```
SENDER                              RECEIVER
Application                         Application
   │                                    ▲
Transport                           Transport
   │                                    ▲
Internet                            Internet
   │                                    ▲
Link                                 Link
   │                                    ▲
   └──────────── NETWORK ───────────────┘
```

---

## 10. A Real Example: `ping 8.8.8.8` vs `ping google.com`

```
ping 8.8.8.8

Laptop (192.168.x.x) → Gateway/router → Internet → 8.8.8.8
```

The IP layer handles addressing and routing this packet directly. Notably,
**ping doesn't use TCP or UDP** — it uses ICMP, operating alongside IP at
the Internet layer.

```
ping google.com

google.com → DNS → IP address → network communication
```

This one is different: the hostname has to be resolved to an IP address via
DNS *before* any of the above can happen. DNS gets its own full session in
09-dns.

---

## 11. Troubleshooting Mental Model

If someone says "the application can't connect," the answer isn't
"the network is broken" — it's to go layer by layer:

```
Is the application running?
        │
Is the port listening?
        │
Is the firewall allowing it?
        │
Can I reach the host?
        │
Is routing correct?
        │
Is DNS resolving?
        │
Is the local interface up?
        │
Is the physical/link connection working?
```

A tool exists for almost every layer in that chain (full detail in
11-packet-debugging and 10-ports-firewalls):

| Problem | Useful tool |
|---|---|
| Interface | `ip link` |
| IP | `ip addr` |
| Routing | `ip route` |
| DNS | `dig` |
| Ports | `ss` |
| Connectivity | `ping` |
| Path | `traceroute` |
| Packets | `tcpdump` |
| Firewall | `ufw` / `nft` |

This layer-by-layer instinct is the actual DevOps troubleshooting mindset —
not randomly restarting things and hoping.

---

## Hands-On Lab

Two parts: a Linux terminal lab and a Packet Tracer lab. Full command
reference is in [`commands.md`](./commands.md) in this folder.

### Part 1 — Ubuntu Terminal

Run the commands in `commands.md`, then record what you observe:

| Item | Value |
|---|---|
| Interface | |
| IP address | |
| CIDR | |
| Default gateway | |
| Your network | |
| `ping 8.8.8.8` result | |
| `ping google.com` result | |

### Part 2 — Cisco Packet Tracer

Build:

```
PC1 ─────── Switch ─────── PC2
```

Configure:

| Device | IP | Subnet mask |
|---|---|---|
| PC1 | `192.168.1.10` | `255.255.255.0` |
| PC2 | `192.168.1.20` | `255.255.255.0` |

No default gateway needed yet — they're on the same subnet. From PC1, run
the ping command from `commands.md`, then save a screenshot of the topology
and successful reply as [`topology.png`](./topology.png) in this folder.

---

## Self-Check — Explain Without Looking

1. What is a network?
2. What's the difference between a switch and a router?
3. What's the difference between an IP address and a MAC address?
4. What are the four TCP/IP layers?
5. What is encapsulation?
6. If PC1 is `192.168.1.10/24` and PC2 is `192.168.1.20/24`, why can they
   communicate directly through a switch without a router?
7. Bonus: what do you think actually happens, step by step, when you run
   `ping 192.168.1.20` from PC1?

---

## Key Takeaways

| Concept | One-line summary |
|---|---|
| Network | Devices that can communicate with each other |
| Switch | Connects devices within a local network |
| Router | Connects different IP networks, forwards packets |
| IP address | Logical address for communication between networks |
| MAC address | Address tied to a network interface, local-link only |
| Protocol | Agreed-upon rules for communication |
| TCP/IP model | Application → Transport → Internet → Link |
| Encapsulation | Data → Segment → Packet → Frame |
| Decapsulation | The receiver unwraps those layers in reverse |

**Next up:** 02-osi-encapsulation goes deep on encapsulation itself.
