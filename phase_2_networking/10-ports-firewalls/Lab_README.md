# 10 — Ports & Firewalls

## Learning Objectives
By the end of this module you should be able to:
- Explain what a port is and how it lets one IP run many services
- Distinguish TCP vs UDP at a practical level
- Know common well-known ports on sight
- Understand stateful vs. stateless firewalls
- Write and apply a Cisco extended ACL to permit/deny specific ports

## Why This Matters
"Security groups" in AWS, "firewall rules" in GCP, and Kubernetes `NetworkPolicy` objects are all just friendlier front-ends over the exact concepts in this module. Cisco ACLs are the router-level equivalent of a firewall, and they're genuinely what protects the perimeter of a huge number of real production networks — this isn't a "toy" substitute, it's the real mechanism.

## Core Concepts

### What a port actually is
An IP address gets traffic to the right *machine*. A **port** (0–65535) gets traffic to the right *application* on that machine. A connection is uniquely identified by the 4-tuple: `(source IP, source port, destination IP, destination port)` — that's how a server can handle thousands of simultaneous connections on the same port 443.

- **Well-known ports (0–1023)**: reserved for standard services — `22` SSH, `23` Telnet, `80` HTTP, `53` DNS.
- **Registered ports (1024–49151)**: used by specific applications (e.g., `3306` MySQL).
- **Ephemeral ports (49152–65535)**: temporary, auto-assigned to the *client side* of a connection.

### TCP vs UDP
- **TCP**: connection-oriented, reliable, ordered — handshake (SYN, SYN-ACK, ACK), retransmits lost data. Used for HTTP, SSH, databases.
- **UDP**: connectionless, no delivery guarantee. Lower overhead. Used for DNS queries, streaming — anything latency-sensitive.

### Stateless vs. stateful firewalls
- **Stateless**: evaluates every packet in isolation. You must explicitly allow both the request *and* the reply traffic.
- **Stateful**: tracks active connections; allowing outbound automatically allows the matching inbound reply. Cloud security groups and host firewalls (`ufw`/`iptables`) are stateful. A standard Cisco ACL, by contrast, **is stateless** — worth noting explicitly, since it's a real behavioral difference from what you'll use in the cloud later.

### Default-deny principle
Security best practice: **deny everything by default, then explicitly allow only what's needed.**

## Key Commands Cheat Sheet
```
ip access-list extended BLOCK_TELNET
 deny tcp 10.10.10.0 0.0.0.255 host 10.10.20.5 eq 23
 permit ip any any
!
interface g0/0
 ip access-group BLOCK_TELNET in
!
show access-lists
show ip interface g0/0
```

---

## Lab Exercise (Packet Tracer — `lab.pkt`)

Packet Tracer doesn't run `iptables`/`ufw`, but Cisco **extended ACLs** applied to a router interface are the direct, real-world equivalent for filtering by port — this lab uses them instead.

### Topology
```
LAN-A (PC1)  10.10.10.0/24
      |
   [Router]
      |
LAN-B (Server)  10.10.20.0/24
```

### Steps
1. **Build the topology**: PC1 on LAN-A, a Server on LAN-B, connected through a Router with one interface on each LAN. Assign IPs, masks, and correct default gateways on PC1 and the Server.
2. **Enable services on the Server**: Services tab → turn on **HTTP** and **Telnet** (set a Telnet password when prompted).
3. **Confirm the baseline works first** — before any ACL exists, from PC1: `ping <server-ip>`, `telnet <server-ip>`, and `http://<server-ip>` in the Web Browser should all succeed.
4. **Create a named extended ACL** on the router:
   ```
   ip access-list extended BLOCK_TELNET
    deny tcp 10.10.10.0 0.0.0.255 host <server-ip> eq 23
    permit ip any any
   ```
5. **Apply it inbound** on the router interface facing LAN-A:
   ```
   interface g0/0
    ip access-group BLOCK_TELNET in
   ```
6. **Re-test from PC1**: `telnet <server-ip>` should now fail/time out. `ping` and the Web Browser `http://<server-ip>` should still succeed.
7. **Verify**: `show access-lists` (check the match counters incrementing as you retest Telnet) and `show ip interface g0/0` (confirm the ACL is applied inbound).
8. **Document your rule** in `firewall-rules.md` in this folder: what it blocks, why, and which interface/direction it's applied to — treat it like a real change record.
9. **Stretch**: add a line denying ICMP from one *specific* host only, leaving the rest of LAN-A able to ping — practice precise `host` matching instead of a blanket subnet rule.

### Checkpoint Questions
1. Why did you apply the ACL `in` on the LAN-A-facing interface rather than the LAN-B-facing one?
2. What would happen to *all* traffic through this router if you forgot the final `permit ip any any` line?
3. Cisco ACLs are stateless — what extra rule would you need to add if you wanted return traffic handled explicitly, the way a stateful firewall does automatically?
4. What did the match counters in `show access-lists` tell you that a single ping/telnet test alone wouldn't?
