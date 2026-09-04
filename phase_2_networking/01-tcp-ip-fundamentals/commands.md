# Session 01 — Command Reference

Every command used in this session's lab, in order, with what to actually
look for in the output.

## Part 1 — Ubuntu Terminal

```bash
ip addr
```
Lists every network interface and its assigned IP address. Look for a line
like `inet 192.168.1.15/24` under your active interface (commonly something
like `enp0s31f6` or `wlp0s20f3`, not `lo` — that one's the loopback
interface, not your real network connection).

```bash
ip route
```
Shows the routing table. Look for a line starting with `default via` — that
IP is your default gateway, the router your machine sends traffic to when
the destination isn't on your local network.

```bash
ping -c 4 8.8.8.8
```
Sends 4 ICMP Echo Requests directly to Google's public DNS server by IP —
no DNS lookup involved. A successful reply here confirms your machine can
reach the internet through IP routing alone.

```bash
ping -c 4 google.com
```
Same idea, but starts with a hostname instead of an IP. Your machine has to
resolve `google.com` to an IP address via DNS before it can send anything —
so a failure here with a working `ping 8.8.8.8` above points at DNS, not at
basic connectivity.

## Part 2 — Cisco Packet Tracer

After building `PC1 --- Switch --- PC2` and configuring both PCs' IPs, from
PC1's command prompt:

```bash
ping 192.168.1.20
```
Both PCs are on the same `/24` subnet, so this ping goes straight through
the switch with no router involved — a direct test of local-network
delivery. A successful reply means the switch is correctly forwarding
frames between the two hosts.
