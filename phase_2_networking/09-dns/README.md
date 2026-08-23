# 09 — DNS

## Learning Objectives
By the end of this module you should be able to:
- Explain the DNS resolution hierarchy (root → TLD → authoritative)
- Describe the difference between recursive and iterative queries
- Know the common record types and what each is for
- Run and configure a basic authoritative DNS server
- Use `dig`/`nslookup` to debug DNS issues

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

### `/etc/hosts` — the local override
Before any network query happens, most systems check a local hosts file (`/etc/hosts` on Linux/Mac). Any entry there wins over DNS entirely — a classic tool for local testing, and a classic gotcha when someone forgets an old entry is still in there.

## Key Commands Cheat Sheet
```bash
dig api.example.com
dig api.example.com +short
dig api.example.com +norecurse
dig -x 93.184.216.34          # reverse lookup (PTR)
nslookup api.example.com
host api.example.com
cat /etc/hosts
```

---

## Lab Exercise (`configs/`)

This lab runs on Linux (a VM, or a Docker container) rather than Packet Tracer, since we need a real resolver and zone files.

### Prerequisites
- A Linux environment (native, VM, or Docker) where you can install packages
- `bind9` (the DNS server software) and `dnsutils` (`dig`/`nslookup`)

### Steps

1. **Install BIND9**:
   ```bash
   sudo apt update && sudo apt install -y bind9 dnsutils
   ```

2. **Create a zone file** for a fake domain, e.g. `labs.local`, at `configs/db.labs.local`:
   ```
   $TTL    604800
   @       IN      SOA     ns1.labs.local. admin.labs.local. (
                           2         ; serial
                           604800    ; refresh
                           86400     ; retry
                           2419200   ; expire
                           604800 )  ; negative cache TTL
   @       IN      NS      ns1.labs.local.
   ns1     IN      A       192.168.1.10
   web     IN      A       192.168.1.20
   api     IN      CNAME   web
   @       IN      MX      10 mail.labs.local.
   mail    IN      A       192.168.1.30
   ```

3. **Register the zone** in `/etc/bind/named.conf.local`:
   ```
   zone "labs.local" {
       type master;
       file "/etc/bind/configs/db.labs.local";
   };
   ```

4. **Restart BIND** and check for config errors:
   ```bash
   sudo named-checkzone labs.local /etc/bind/configs/db.labs.local
   sudo systemctl restart bind9
   ```

5. **Query your own server directly**:
   ```bash
   dig @127.0.0.1 web.labs.local
   dig @127.0.0.1 api.labs.local     # should resolve via the CNAME to web's IP
   dig @127.0.0.1 labs.local MX
   ```

6. **Read the output sections** in a `dig` response — identify the `ANSWER`, `AUTHORITY`, and `ADDITIONAL` sections and note what's in each.

7. **Test caching/TTL**: query twice in a row and note the `TTL` value counting down in the second query if you're querying through a caching resolver rather than directly.

8. **Break something on purpose**: comment out the `ns1` A record, restart BIND, and observe what error `dig` gives you when nothing can resolve the nameserver.

### Checkpoint Questions
1. What's the difference between what your laptop asks a resolver, versus what the resolver asks the root/TLD/authoritative servers?
2. Why did `api.labs.local` resolve to the same IP as `web.labs.local`?
3. What does the SOA record's serial number control, and why does forgetting to increment it after an edit cause problems?
4. If a record's TTL is 604800 seconds, roughly how many days is that, and what does it mean practically for how fast a DNS change propagates?
