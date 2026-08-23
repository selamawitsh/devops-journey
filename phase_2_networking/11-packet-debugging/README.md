# 11 — Packet Debugging

## Learning Objectives
By the end of this module you should be able to:
- Capture live traffic with `tcpdump`
- Read a capture in Wireshark and filter it meaningfully
- Identify a TCP three-way handshake and a DNS query in a capture
- Follow a systematic top-down debugging workflow when "the network is broken"

## Why This Matters
This is the module that turns "I think it's a network problem" into "here's the exact packet where it breaks." Every module before this one taught you what *should* happen — this one teaches you how to prove what's *actually* happening when it doesn't. It's one of the highest-leverage skills in the entire DevOps toolkit.

## Core Concepts

### Why capture packets at all
Logs tell you what your *application* thinks happened. A packet capture tells you what actually crossed the wire — no interpretation, no assumptions. When application logs and reality disagree, the packet capture is the tiebreaker.

### tcpdump vs. Wireshark
- **tcpdump**: command-line, lightweight, great for capturing on a remote server over SSH (no GUI needed). You capture with it, and often *analyze* somewhere else.
- **Wireshark**: GUI analyzer with rich filtering, colorized protocol breakdowns, and the ability to "Follow TCP Stream" to reconstruct a whole conversation. Typically you capture with tcpdump on a server, copy the `.pcap` file to your laptop, and open it in Wireshark.

### The TCP three-way handshake
Before any TCP data flows, you'll always see this pattern in a capture:
```
Client → Server:  SYN                (client: "let's connect")
Server → Client:  SYN, ACK           (server: "ok, and you too?")
Client → Server:  ACK                (client: "confirmed")
```
If you only ever see a lone `SYN` with no reply, that's a strong signal of a firewall silently dropping the packet (a "reject" would send back an ICMP or `RST` instead — silence usually means a drop rule).

### A systematic debugging workflow
When something is "unreachable," work top-down instead of guessing:
1. **`ping`** — is there basic IP connectivity at all? (Note: ICMP can be blocked even when the actual service works — don't over-trust a failed ping.)
2. **`traceroute`** — where does the path stop responding?
3. **`nc -zv` / `telnet`** — is the specific port open?
4. **`tcpdump`/Wireshark** — what's actually happening at the packet level? Are SYNs going unanswered? Is DNS resolving to the wrong IP? Is a `RST` coming back immediately?
5. **Application logs** — only now, once the network path is confirmed working, look at the app.

This ordering matters: jumping straight to app logs when the real issue is a missing firewall rule wastes time.

## Key Commands Cheat Sheet
```bash
sudo tcpdump -i eth0 -w capture.pcap          # capture everything on eth0 to a file
sudo tcpdump -i eth0 host 10.0.0.5            # filter by host
sudo tcpdump -i eth0 port 443                 # filter by port
sudo tcpdump -r capture.pcap                  # read a saved capture
sudo tcpdump -i eth0 -n 'tcp[tcpflags] & tcp-syn != 0'  # SYN packets only
```
Wireshark display filters:
```
tcp.flags.syn == 1 && tcp.flags.ack == 0
dns
http.request
ip.addr == 10.0.0.5
```

---

## Lab Exercise (`captures/`)

### Prerequisites
- A Linux host/VM with `tcpdump` installed
- Wireshark installed on your laptop (for analysis)

### Steps
1. **Start a capture**, saving to the `captures/` folder:
   ```bash
   sudo tcpdump -i any -w captures/session1.pcap
   ```
2. **In a second terminal, generate some traffic**:
   ```bash
   ping -c 4 example.com
   curl -v http://example.com
   ```
3. **Stop the capture** (Ctrl+C) once the commands finish.
4. **Inspect on the command line first**:
   ```bash
   sudo tcpdump -r captures/session1.pcap
   sudo tcpdump -r captures/session1.pcap port 53      # isolate the DNS lookup
   sudo tcpdump -r captures/session1.pcap port 80      # isolate the HTTP request
   ```
5. **Copy `session1.pcap` to your laptop and open it in Wireshark.** Apply the filter `dns` and find the query for `example.com` and its answer. Note the resolved IP.
6. **Apply the filter `tcp.flags.syn == 1`** and find the SYN and SYN-ACK for the HTTP connection. Confirm the destination IP matches what DNS returned.
7. **Right-click the HTTP packet → Follow → TCP Stream** to see the full request/response as a readable conversation.
8. **Deliberately break something**: point `curl` at a port nothing is listening on (`curl http://example.com:9999` with a short timeout, or an internal IP with no service). Capture that attempt too, and note what a *failed* connection looks like at the packet level (repeated SYNs with no reply, or an immediate `RST`).

### Checkpoint Questions
1. In your capture, how many packets made up the full TCP handshake before any HTTP data was sent?
2. What's the visible difference in a capture between "port is closed" (RST comes back) and "port is filtered/firewalled" (nothing comes back)?
3. Why did the DNS query need to happen *before* the TCP handshake could even begin?
4. If `ping` fails but `curl` on port 443 succeeds to the same host, what does that tell you about the network path?
