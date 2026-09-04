# 02 — OSI Model & Encapsulation

The OSI model isn't seven names to memorize. It's a troubleshooting tool.
"The internet isn't working" could mean a dozen different things — a dead
cable, a missing route, a DNS failure, a firewall rule, an app that's just
down. The OSI model exists to turn "the network is broken" into "which
layer is broken," which is a question you can actually answer.

## What you'll be able to do

- Explain all 7 OSI layers in plain language
- Map OSI onto the 4-layer TCP/IP model from 01-tcp-ip-fundamentals
- Walk data → segment → packet → frame → bits in both directions
- Use the OSI model as an actual troubleshooting checklist, not trivia

---

## 1. The 7 OSI Layers

Built bottom-up, since that's the order data actually travels on the way
out:

```
        ┌─────────────────────┐
  L7    │ Application          │
        ├─────────────────────┤
  L6    │ Presentation         │
        ├─────────────────────┤
  L5    │ Session              │
        ├─────────────────────┤
  L4    │ Transport            │
        ├─────────────────────┤
  L3    │ Network              │
        ├─────────────────────┤
  L2    │ Data Link            │
        ├─────────────────────┤
  L1    │ Physical             │
        └─────────────────────┘
```

### Layer 1 — Physical

**Question it answers:** how do bits physically travel?

Ethernet cable, fiber, radio waves, electrical signals — the actual medium.
At this level it's just `0 1 0 1 1 0 0 1`.

```
Computer → Electrical/radio/optical signals → Network medium
```

**Check it with:**
```bash
ip link
```
A real example worth knowing how to read: an interface reporting
`NO-CARRIER` and `state DOWN` (common on `enp0s31f6` when no Ethernet cable
is plugged in) has no physical connection at all — nothing above Layer 1
matters until that's fixed. An interface reporting `LOWER_UP` and
`state UP` (common on a Wi-Fi interface like `wlp0s20f3` when connected) is
physically live.

### Layer 2 — Data Link

**Question it answers:** how do devices talk on the *same* local network?

MAC addresses, Ethernet, Wi-Fi frames, switches, ARP, VLANs all live here.
A MAC address (e.g. `40:ec:99:d3:19:72`) is a Layer 2 address — a switch
uses it to decide where to deliver a frame within one local network.

```
PC1 (192.168.1.10, AA:AA:AA...)      PC2 (192.168.1.20, BB:BB:BB...)
              \                              /
               \                            /
                    ┌──────────┐
                    │  Switch  │
                    └──────────┘
```

Before PC1 can actually send anything to PC2, it has to answer: "what MAC
address belongs to 192.168.1.20?" That question is answered by ARP, covered
in full in 06-arp-ethernet.

### Layer 3 — Network

**Question it answers:** where does this IP packet need to go?

IP addresses and routing live here. Routers operate primarily at this
layer, reading the destination IP and deciding where to forward the packet.

```
Network A (192.168.1.0/24) → Router → Network B (10.0.0.0/24)
```

### Layer 4 — Transport

**Question it answers:** which process on the destination should get this?

TCP and UDP live here, along with port numbers.

```
Client                    Server
 SYN ───────────────────►
      ◄──────────────── SYN-ACK
 ACK ───────────────────►
```

```
192.168.1.8:54321 ── TCP ──► 192.168.1.20:443
      source port              destination port
```

TCP gives reliable, ordered delivery. Full port detail is in
10-ports-firewalls.

### Layer 5 — Session

**Question it answers:** how is this ongoing conversation between two
applications managed — established, maintained, torn down?

Worth being honest about this one: **modern protocols don't always have a
clean, separate Layer 5 implementation.** OSI is a conceptual model first;
don't expect Session to feel as concrete as Transport or Network.

### Layer 6 — Presentation

**Question it answers:** how should the data actually be represented?

Encoding, encryption, compression.

```
Original data → Encryption → Transmitted data
```

Same caveat as Layer 5 — real protocols rarely map onto exactly one OSI
layer.

### Layer 7 — Application

**Question it answers:** what is the actual application-level protocol?

HTTP, HTTPS, DNS, SSH, SMTP — the layer closest to what you're actually
using.

```
Browser → HTTPS → Web server
```

**Remembering the order**, top to bottom: Application, Presentation,
Session, Transport, Network, Data Link, Physical — "A P S T N D P," or build
your own sentence.

---

## 2. OSI vs TCP/IP

OSI has 7 layers; the TCP/IP model from 01-tcp-ip-fundamentals has 4. The
mapping is approximate, not exact:

```
OSI                              TCP/IP

Application    ┐
Presentation   ├─────────────►  Application
Session        ┘

Transport      ─────────────►  Transport

Network        ─────────────►  Internet

Data Link      ┐
Physical       ┴─────────────►  Link
```

TCP/IP simply combines several OSI layers into fewer, broader ones.

---

## 3. Encapsulation — Sending "Hello"

Same idea as addressing a physical package: the item goes in a box, the box
gets an address, the address gets shipping info. Data gets the same kind of
wrapping, one layer at a time, on the way out.

**Step 1 — Application data.** The application creates `Hello`.

**Step 2 — Transport.** TCP adds a header (ports, sequencing):

```
┌──────────────┬──────────────┐
│ TCP Header    │ Data          │
│ ports, etc.   │ "Hello"       │
└──────────────┴──────────────┘
```
Now it's a **TCP segment**.

**Step 3 — Network.** IP adds its own header (source/destination IP):

```
┌──────────────┬──────────────┬──────────────┐
│ IP Header     │ TCP Header    │ Data          │
│ source/dest   │ ports         │ "Hello"       │
└──────────────┴──────────────┴──────────────┘
```
Now it's an **IP packet**.

**Step 4 — Data Link.** Ethernet/Wi-Fi adds a frame header and trailer
(MAC addresses):

```
┌─────────┬─────────┬─────────┬─────────┐
│ Ethernet │ IP       │ TCP      │ Data     │
│ Header   │ Header   │ Header   │ "Hello"  │
└─────────┴─────────┴─────────┴─────────┘
```
Now it's a **frame**.

**Step 5 — Physical.** The frame becomes bits, becomes signals, hits the
medium.

The full trip:

```
Application   "Hello"
     │
Transport     Segment
     │
Internet      Packet
     │
Link          Frame
     │
Physical      Bits
```

**That's encapsulation.**

## 4. Decapsulation

The receiver reverses the exact same process:

```
Bits → Frame → Packet → Segment → Data
```

```
Sender                    Receiver

Data                      Data
 │                          ▲
Segment                   Segment
 │                          ▲
Packet                    Packet
 │                          ▲
Frame                     Frame
 │                          ▲
Bits ───────────────────► Bits
```

---

## 5. Terminology — Data Unit Per Layer

| Layer | Data unit |
|---|---|
| Application | Data |
| Transport | Segment |
| Network | Packet |
| Data Link | Frame |
| Physical | Bits |

One detail worth keeping straight: **TCP calls its transport-layer unit a
segment; UDP calls its a datagram.**

```
TCP      → Segment
UDP      → Datagram
IP       → Packet
Ethernet → Frame
```

---

## 6. IP vs MAC, One More Time — With a Real Example

Say your laptop (`wlp0s20f3`, IP `192.168.1.8/24`, MAC
`40:ec:99:d3:19:72`) sends something to `192.168.1.20`:

```
Application   Data
     │
Transport     TCP Segment
     │
Internet      IP Packet
     │
Link          Wi-Fi Frame
     │
Physical      Radio signals
     │
Network
```

**IP answers:** which host/network should this packet reach?
**MAC answers:** which local interface should receive this frame on this
local link?

Full detail on how those two get linked together (ARP) is in
06-arp-ethernet.

---

## 7. DevOps Troubleshooting: `curl` Fails, Now What

Running `curl https://example.com` and getting nothing back is not evidence
the server is down — it's evidence you haven't located the layer yet. Work
down from the top:

**Layer 1 — is the interface up?**
```bash
ip link
```

**Layer 2 — can the machine talk to the local network? (ARP/MAC issues?)**
```bash
ip neigh
```

**Layer 3 — is there an IP and a route?**
```bash
ip addr
ip route
```

**Layer 4 — is the destination port actually reachable?**
```bash
ss
```

**DNS / Application — does the hostname resolve, does HTTP work?**
```bash
dig example.com
curl https://example.com
```

This ordered checklist — not guessing, not restarting things at random — is
what makes the OSI model actually useful day to day instead of trivia.

---

## Hands-On Lab: Watch a Packet Move Through the Layers

### Part 1 — Build and Connect

```
PC1 ─────── Switch ─────── PC2
```

| Device | IP | Subnet mask |
|---|---|---|
| PC1 | `192.168.1.10` | `255.255.255.0` |
| PC2 | `192.168.1.20` | `255.255.255.0` |

No gateway needed — same subnet. From PC1:

```bash
ping 192.168.1.20
```

Confirm successful replies before moving to Part 2.

### Part 2 — Simulation Mode

Switch Packet Tracer from **Realtime** to **Simulation**, then send the
ping again. Watch the packet actually move:

```
PC1 → Switch → PC2
```

Click the packet at each hop and inspect what's visible at each layer —
you'll see Layer 2 (MAC) and Layer 3 (IP) information directly, and confirm
that the ping itself is carried by ICMP, not TCP or UDP, exactly as covered
in Session 01.

Save a screenshot of the simulation showing the packet in transit as
[`packet-flow.png`](./packet-flow.png) in this folder.

---

## 8. OSI Is a Conceptual Model — Don't Force Reality to Fit It

Not every real protocol maps cleanly onto exactly one OSI layer — modern
HTTPS in particular touches several layers' worth of concerns at once. OSI's
value isn't perfect categorization, it's the mental framework: when
something breaks, narrow it down layer by layer instead of guessing.

```
Physical? → Data Link? → Network? → Transport? → Application?
```

---

## Active Recall

Don't check back against the material above if you can help it.

**Part A — Basics**
1. How many layers does OSI have?
2. Which layer is responsible for IP addressing and routing?
3. Which layer uses TCP and UDP?
4. Which layer deals with MAC addresses and Ethernet?
5. Which layer represents physical transmission — cables, fiber, radio?

**Part B — Data units**

Put these in order from application down to physical:
```
Frame
Bits
Data
Packet
Segment
```

**Part C — The important one**

```
PC1 (192.168.1.10) → Switch → PC2 (192.168.1.20)
```

PC1 sends `"Hello"` to PC2. Explain what happens as `"Hello"` travels down
the layers, using the words: Data, Segment, Packet, Frame, Bits.

**Part D — DevOps troubleshooting**

`curl https://example.com` fails. Which command(s) would you use to
investigate each of these, specifically?
1. An interface problem
2. An IP/routing problem
3. A DNS problem
4. An application/HTTP problem

---

## Key Takeaways

| Concept | One-line summary |
|---|---|
| OSI model | A troubleshooting framework, not just seven names to recite |
| Layers 1-4 | Physical, Data Link, Network, Transport — concrete, map directly to TCP/IP |
| Layers 5-7 | Session, Presentation, Application — conceptual, don't always map to real protocols cleanly |
| Encapsulation | Data → Segment → Packet → Frame → Bits, one header added per layer down |
| Decapsulation | The receiver reverses that exact process |
| TCP vs UDP unit | TCP = segment, UDP = datagram |
| Troubleshooting | Work layer by layer — interface, then local link, then IP/route, then port, then DNS/app |

**Next up:** 03-ipv4-addressing.
