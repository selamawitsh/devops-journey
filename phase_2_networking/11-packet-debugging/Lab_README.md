# 11 — Packet Debugging

## Learning Objectives
By the end of this module you should be able to:
- Use Packet Tracer's Simulation Mode to capture and step through live traffic
- Identify a TCP three-way handshake and an ARP exchange in an event list
- Inspect a packet's full protocol stack at each hop (OSI Model view)
- Follow a systematic top-down debugging workflow when "the network is broken"

## Why This Matters
This is the module that turns "I think it's a network problem" into "here's the exact packet where it breaks." Every module before this one taught you what *should* happen — this one teaches you how to prove what's *actually* happening when it doesn't.

## Core Concepts

### Why inspect packets at all
Logs tell you what your *application* thinks happened. A packet-level view tells you what actually happened on the wire — no interpretation, no assumptions. When application behavior and your mental model disagree, the packet trace is the tiebreaker.

### The TCP three-way handshake
Before any TCP data flows, you'll always see this pattern:
```
Client → Server:  SYN                (client: "let's connect")
Server → Client:  SYN, ACK           (server: "ok, and you too?")
Client → Server:  ACK                (client: "confirmed")
```
A lone `SYN` with no reply at all is a strong signal of something silently dropping the packet (compare this to Module 10's ACL work).

### A systematic debugging workflow
When something is "unreachable," work top-down instead of guessing:
1. **`ping`** — basic IP connectivity at all?
2. **`tracert`** — where does the path stop responding?
3. **Port-level test** (e.g. `telnet <ip> <port>`) — is the specific service reachable?
4. **Packet-level inspection** — what's actually happening? Unanswered ARP? Missing SYN-ACK?
5. **Application/service config** — only once the network path is confirmed working.

## Key Tools in Packet Tracer
- **Simulation Mode** (bottom-right tab, next to Realtime) — the closest thing PT has to Wireshark/tcpdump. It doesn't produce a real `.pcap` file, but it lets you watch and inspect every packet event hop-by-hop.
- **Event List Filters** — control which protocols show up (ARP, ICMP, TCP, HTTP, DNS, etc.)
- **PDU Information window → OSI Model tab** — click any packet event to see exactly what's in it at each layer, at that specific hop.

---

## Lab Exercise (Packet Tracer — screenshots saved to `captures/`)

Note: Packet Tracer does not produce a real `.pcap` file or run actual tcpdump/Wireshark — Simulation Mode is its built-in substitute, and it's genuinely good for seeing per-hop behavior, which is the core skill this module is after.

### Steps
1. **Reuse the 3-router topology from Module 08** (or a simpler 2-PC-through-a-router setup).
2. **Switch to Simulation Mode** (bottom-right tab).
3. **Open Event List Filters** and make sure ICMP, ARP, TCP, and HTTP are checked.
4. **From PC-A, start a ping** to a PC on a different subnet (`ping <ip>`), then step through the event list with the **Play/Forward Step** button.
5. **Watch for ARP first**: if the next hop's MAC isn't already known, you should see ARP request/reply events *before* the actual ICMP packets move.
6. **Click on individual packet events** (on the topology or in the Event List) to open **PDU Information → OSI Model tab**.
7. **Confirm the core "aha" of routing**: as the packet crosses each router hop, the **source/destination MAC address changes** while the **source/destination IP address stays the same** end-to-end. Screenshot this and save it to `captures/`.
8. **Generate HTTP traffic**: open a PC's Web Browser pointed at a server in the topology, switch to Simulation Mode, and step through. Identify the **TCP handshake** (SYN, SYN-ACK, ACK) events happening *before* the `HTTP GET` event appears.
9. **Break something on purpose**: disconnect a cable or misconfigure an IP, then re-run the capture. Note what a failure looks like in the event list (packets simply stop appearing, or you see repeated ARP requests with no reply) — compare this to a normal successful run.
10. **Save at least two screenshots** (a normal OSI breakdown, and the broken scenario) into `captures/`.

### Checkpoint Questions
1. At the second router hop, why did the destination MAC address change but the destination IP address did not?
2. Where in the event list did the ARP exchange sit relative to the actual ICMP echo request?
3. What did the TCP handshake look like in the event list before the HTTP GET was sent?
4. When you broke connectivity on purpose, how could you tell from the event list alone — without any explicit error message — that something had failed?
