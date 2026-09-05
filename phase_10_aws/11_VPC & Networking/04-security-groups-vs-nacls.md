# Two Firewalls: Security Groups vs Network ACLs

## Visual: Where Each One Sits

```
+------------------------- VPC -------------------------+
|                                                        |
|   +----------- SUBNET ------------+                    |
|   |  <--- Network ACL wraps HERE --->                  |
|   |                                |                   |
|   |   +---------+   +---------+   |                    |
|   |   | Instance|   | Instance|   |                    |
|   |   | <-SG->  |   | <-SG->  |   |                    |
|   |   +---------+   +---------+   |                    |
|   +--------------------------------+                   |
|                                                        |
+---------------------------------------------------------+
```

A **Security Group** wraps a single instance (or ENI). A **Network ACL**
wraps the whole subnet, one layer further out. Traffic entering a subnet
passes the NACL first, then the security group of the specific instance
it's headed to.

---

## Side-by-Side Comparison

| | Security Group | Network ACL |
|---|---|---|
| Wraps | One instance (or ENI) | An entire subnet |
| State | **Stateful** — reply traffic is automatically allowed | **Stateless** — you must allow both directions yourself |
| Rule types | Allow rules only | Allow AND deny rules |
| How often used day-to-day | Constantly — this is your main firewall | Rarely — coarse, subnet-wide |
| Example rule | Allow HTTP 80 from anywhere | Block one bad IP range from an entire subnet |

---

## Why "Stateful" vs "Stateless" Actually Matters

**Security Group (stateful):** if you allow inbound port 443, the reply
traffic going back out is automatically permitted — you never write an
outbound rule for it.

**Network ACL (stateless):** if you allow inbound port 443, you must *also*
write an outbound rule allowing the ephemeral return ports (typically
1024–65535), or replies get silently dropped. This is the single most common
NACL mistake in real environments.

---

## Why NACLs Still Exist When SGs Cover 95% of Daily Work

A security group can only ever *allow* traffic — it has no way to actively
*block* a specific source. If a known-bad IP range needs to be shut out
immediately across an entire subnet (say, during an active attack), a NACL
deny rule stops that traffic before it even reaches any instance's security
group. That's a second, independent layer — the idea of "defense in depth,"
where one misconfigured security group doesn't equal a full breach.

---

## Interview Questions

1. What does "stateful" mean in the context of a security group, and why
   does it matter practically?
2. Why can't a security group block a specific IP address?
3. When would you reach for a NACL instead of just tightening a security
   group?
4. What's the classic NACL mistake involving ephemeral ports?

---

## Common Mistakes

- Writing a NACL inbound allow rule and forgetting the matching outbound rule
  for return traffic.
- Trying to use a security group to explicitly *deny* an IP — it can't; you
  can only choose not to allow it.
- Locking down a NACL so tightly during a security response that it
  accidentally blocks legitimate traffic for the whole subnet, not just the
  bad actor.
