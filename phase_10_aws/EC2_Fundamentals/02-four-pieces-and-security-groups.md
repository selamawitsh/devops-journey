# Session 4b · The Four Pieces & Security Groups

## Every Instance Needs Four Things

Think of it like assembling a computer rather than buying one pre-built:

| # | Piece | Role | Detail |
|---|---|---|---|
| 1 | **AMI** | The template | Amazon Machine Image — the OS and pre-installed software (Amazon Linux, Ubuntu, Windows). Your instance boots from this |
| 2 | **Instance type** | The size | How much CPU and memory — `t3.micro` for us. Decides speed and price |
| 3 | **Storage** | The disk | An EBS volume, a virtual hard drive that persists. The root volume holds the OS |
| 4 | **Network + security** | The doors | Which VPC and subnet it lives in, and a security group controlling who can reach it |

## Security Groups: The Instance Firewall

**A security group is a virtual firewall wrapped around your instance.** It decides what
traffic is allowed IN and OUT.

- **Allow rules only** — you list what's permitted. Anything not listed is blocked by
  default. There's no deny rule to write.
- **Common ports to open** — `22` for SSH (Linux login), `80` for HTTP, `443` for HTTPS.
  Open only what you actually use.
- **Source matters** — restrict SSH to *your* IP, not `0.0.0.0/0` (the whole internet).
  Open SSH to the world is how servers get attacked.
- **Stateful** — if you allow traffic IN, the reply is automatically allowed OUT. You don't
  write return rules.

Think of it as a bouncer with a guest list, not a bouncer with a blocklist — there's no
concept of explicitly kicking someone out, only who's on the list to begin with.

## Key Terms

- **AMI (Amazon Machine Image)** — the template an instance boots from
- **EBS (Elastic Block Store)** — the persistent virtual disk attached to an instance
- **Security group** — an allow-only virtual firewall attached to an instance
- **`0.0.0.0/0`** — CIDR notation meaning "the entire internet, no restriction"


