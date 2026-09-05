# Gateways and Route Tables

## The Three Moving Parts

| Piece | Compound analogy | Job |
|---|---|---|
| Internet Gateway (IGW) | The front gate | The only door between the VPC and the public internet. One per VPC. |
| Route Table | The signpost list | Tells traffic where to go: internet-bound → IGW, local traffic → stays inside |
| NAT Gateway | A one-way door | Lets a private subnet reach OUT to the internet without being reachable FROM it |

---

## Visual: How Traffic Actually Flows

```
                         INTERNET
                             |
                            IGW   <-- attached once, to the VPC
                             |
      Public Route Table:  0.0.0.0/0 -> IGW
                             |
                     PUBLIC SUBNET
                (Load Balancer, Web Servers)
                             |
      Private Route Table:  local only  (no IGW line at all)
                             |
                    PRIVATE SUBNET
                       (Database)
                             |
                  ---- outbound only ---->
                             |
                       NAT GATEWAY  (lives in the public subnet)
                             |
                            IGW  ----> INTERNET
```

Notice the private subnet's outbound path to the internet (through the NAT
Gateway) is a **one-way door**: the database can call out to fetch a security
patch, but nothing on the internet can ever initiate a connection back in.

---

## Internet Gateway (IGW)

- Attach exactly **one** IGW per VPC.
- By itself, an IGW does nothing — it's a door standing open in a wall until
  a route table actually points traffic through it.

## Route Table

- A subnet is public *because* its route table has a line: `0.0.0.0/0 -> igw`.
- A subnet is private *because* its route table has no such line — only
  `local` traffic within the VPC's own CIDR range.
- This is the exact mechanism from file 02's "one real rule."

## NAT Gateway

- Optional, and it **costs money** — an hourly charge plus a per-GB data
  processing charge.
- Lets private-subnet resources reach out (OS updates, calling a third-party
  API) without exposing them to inbound connections.
- **Real-world cost trade-off:** companies often run one NAT Gateway per
  Availability Zone (not one per subnet) to balance cost against
  high-availability — losing one AZ's NAT Gateway shouldn't take down every
  private subnet in the VPC.

---

## Real-World Grounding

- "Why can't my private EC2 instance download updates?" is one of the most
  common early-career tickets, and the answer is almost always: there's no
  NAT Gateway, or the private subnet's route table doesn't point to it.
- "Why is my public-facing app unreachable?" is almost always: the route
  table's `0.0.0.0/0` line is missing or pointing at the wrong target.

---

## Interview Questions

1. What's the difference between an Internet Gateway and a NAT Gateway?
2. Why would a private subnet still need internet access at all?
3. Why do companies often deploy one NAT Gateway per AZ instead of a single
   one for the whole VPC?
4. What exact line in a route table turns a subnet into a public subnet?

---

## Common Mistakes

- Attaching an IGW to the VPC but forgetting to add the route table entry —
  the gate exists, but nothing is told to walk through it.
- Assuming a NAT Gateway lets outside traffic reach the private subnet — it
  only ever allows outbound-initiated traffic.
- Forgetting NAT Gateways cost money and leaving one running in a
  torn-down/test environment.
