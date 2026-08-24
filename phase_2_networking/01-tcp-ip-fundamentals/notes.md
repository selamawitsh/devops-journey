# TCP/IP Fundamentals

## The 4-Layer Model (What Actually Runs the Internet)

| Layer | Name | What It Does | Key Identifiers |
|-------|------|-------------|-----------------|
| 4 | Application | User-facing protocols | HTTP, DNS, SSH |
| 3 | Transport | Reliable delivery, ports | TCP/UDP, port numbers |
| 2 | Internet | Routing across networks | IP addresses |
| 1 | Link | Moving frames between directly connected devices | MAC addresses |

## Encapsulation

When you send data, each layer wraps the layer above it:
    Application: GET / HTTP/1.1
    Transport: [Src Port: 54321 | Dst Port: 443 | Seq # | APPLICATION DATA]
    Internet: [Src IP: 192.168.1.42 | Dst IP: 8.8.8.8 | TRANSPORT SEGMENT]
    Link: [Src MAC: aa:bb:cc | Dst MAC: GATEWAY | INTERNET PACKET]



Each layer only cares about its own header. Ethernet doesn't know it's carrying HTTP.

## Key Insight: Gateway MAC vs Destination IP

When sending to an IP outside your local network:
- **Link layer (MAC):** Goes to the default gateway (next hop)
- **Internet layer (IP):** Remains the final destination

The gateway strips the frame, reads the IP packet, and forwards it. This is how packets hop between networks.

## TCP 3-Way Handshake
Client → Server: [SYN] "Can we talk?"
Server → Client: [SYN-ACK] "Yes, I'm listening"
Client → Server: [ACK] "Connection established"


After the handshake, data flows with [P.] (PSH-ACK) flags.
Connection ends with [F.] (FIN-ACK) flags.

## Troubleshooting by Layer

| Symptom | Layer Failed | Check |
|---------|-------------|-------|
| Could not resolve host | Application (DNS) | `dig`, `nslookup` |
| Connection refused | Transport (no port listening) | `ss -tn` |
| Request timeout | Internet (routing/firewall) | `ip route`, `iptables` |
| Network unreachable | Link (interface down) | `ip link` |

## Commands I Learned

```bash
ip addr          # Show my IP and MAC addresses
ip route         # Show routing table (find default gateway)
ss -tn           # Show active TCP connections and their states
tcpdump          # Capture packets and see layers in action