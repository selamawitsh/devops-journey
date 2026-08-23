# 09 — DNS

## Learning Objectives
By the end of this module you should be able to:
- Explain the DNS resolution hierarchy (root → TLD → authoritative)
- Describe the difference between recursive and iterative queries
- Know the common record types and what each is for
- Configure a DNS service and A records on a server
- Test name resolution from a client and diagnose a broken lookup

## Why This Matters
"It's always DNS" is a real phrase for a reason. Every service discovery system in Kubernetes, every ALB, every microservice-to-microservice call eventually resolves a name to an IP. When something is "unreachable," DNS is one of the first three things to rule out (the others being routing and firewalls — which you now know from Modules 08 and 10).

## Core Concepts

### What DNS solves
Computers route packets using IP addresses, but humans (and applications) work with names like `api.example.com`. DNS is the distributed, hierarchical system that maps names to IPs (and other data).

### The hierarchy
```
                    "." (root)
                   /    |    \
                .com  .org  .net   ← Top-Level Domains (TLDs)
                 |
             example.com            ← Authoritative zone
                 |
          api.example.com           ← A record lives here
```
- **Root servers** know where to find TLD servers.
- **TLD servers** (`.com`, `.org`, etc.) know where to find authoritative servers for each domain.
- **Authoritative servers** hold the actual records for a specific domain (this is the DNS server you configure in the lab below).

### Recursive vs. iterative resolution
- Your laptop asks a **recursive resolver** (often your router, ISP, or something like `8.8.8.8`) for `api.example.com`.
- The recursive resolver does the legwork: it asks root → gets referred to `.com` TLD → asks TLD → gets referred to `example.com`'s authoritative server → asks it → gets the answer.
- The resolver then returns *one final answer* to your laptop, and caches it for next time.
- Your laptop's query was "recursive" (give me the final answer). The resolver's queries to root/TLD/authoritative were "iterative" (each server just says "I don't know, but ask them").

### Common record types
| Record | Purpose |
|---|---|
| `A` | Maps a name to an IPv4 address |
| `AAAA` | Maps a name to an IPv6 address |
| `CNAME` | Alias — points one name to another name |
| `MX` | Mail server for a domain |
| `TXT` | Arbitrary text — commonly used for domain verification, SPF/DKIM |
| `NS` | Delegates a zone to specific nameservers |
| `SOA` | Zone metadata: primary nameserver, admin contact, TTLs, serial number |
| `PTR` | Reverse lookup — IP address back to a name |

### Caching and TTL
Every DNS record has a **TTL (Time To Live)**, in seconds. Resolvers cache the answer for that long before asking again. Short TTLs = faster updates propagate, but more query load. This is exactly why DNS changes can take a while to "take effect" everywhere.

## Key Commands Cheat Sheet
```bash
dig api.example.com
dig api.example.com +short
nslookup api.example.com
ping www.labs.local
```

---

## Lab Exercise (Packet Tracer — `lab.pkt`)

Packet Tracer's Server device has a real, working DNS Services tab — this lab is fully doable natively, no substitutions needed.

### Topology
```
[PC1]---[Switch]---[Server]  (DNS + HTTP services, same subnet)
[PC2]---/
```
- 1 Switch, 2 PCs, 1 Server — all on `192.168.1.0/24`

### Steps
1. **Place and cable** a Switch, two PCs, and a Server; connect each with a copper straight-through cable.
2. **Assign static IPs**: PC1 `192.168.1.10`, PC2 `192.168.1.11`, Server `192.168.1.20`, all with mask `255.255.255.0` (same subnet, no gateway needed yet).
3. **Enable DNS on the Server**: open the Server → **Services** tab → **DNS** → turn it **On**. Add an A record:
   - Name: `www.labs.local`
   - Type: `A Record`
   - Address: `192.168.1.20` (the server's own IP)
4. **Enable HTTP on the Server**: Services tab → **HTTP** → turn it **On** (the default page is fine, or edit it under the HTTP files).
5. **Point PC1 at the DNS server**: PC1 → Desktop → **IP Configuration** → set the **DNS Server** field to `192.168.1.20`.
6. **Test resolution**: PC1 → Desktop → **Command Prompt** → `ping www.labs.local`. You should see the name resolve to `192.168.1.20` before the ping replies start.
7. **Test end-to-end via HTTP**: PC1 → Desktop → **Web Browser** → enter `http://www.labs.local` → confirm the page loads. This proves DNS resolution *and* the HTTP request both worked.
8. **Break it on purpose**: on PC2, set the DNS Server field to an unused address (e.g. `192.168.1.99`) and run `ping www.labs.local` — note the resolution failure, and how it differs from a normal "Request timed out" (this fails to resolve a name at all, before any packet is even sent).
9. **Save your topology** as `lab.pkt` in this folder.

### Checkpoint Questions
1. What was different about the `ping` output when PC1 (correct DNS server) ran it versus PC2 (wrong DNS server)?
2. Where exactly did you define the mapping between `www.labs.local` and an IP address?
3. Why did testing through the Web Browser prove more than testing with `ping` alone?
4. If you added a second A record for the same name pointing at a different IP, what would you expect to happen — and is that something you could reliably observe in Packet Tracer? (Keep this question in mind for Module 13.)
