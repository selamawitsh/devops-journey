# Session 4c · Security Groups & Key Pairs

## Security Groups — The Instance Firewall

A security group is a virtual firewall wrapped around your instance. It decides what traffic is
allowed IN and OUT.

- **Allow rules only** — you list what is permitted. Anything not listed is blocked by default.
  There is no deny rule to write.
- **Common ports to open** — 22 for SSH (Linux login), 80 for HTTP, 443 for HTTPS. Open only
  what you actually use.
- **Source matters** — restrict SSH to *your* IP, not `0.0.0.0/0` (the whole internet). Open
  SSH to the world is how servers get attacked.
- **Stateful** — if you allow traffic IN, the reply is automatically allowed OUT. You do not
  write return rules.

### Real-World Pattern: SG-to-SG References

Instead of writing IP ranges everywhere, companies reference *other security groups* as the
source — e.g. "allow port 5432 from `web-sg`" instead of "allow from `10.0.1.0/24`". This means
your database's firewall rule stays correct automatically as web servers scale up and down,
with no IP list to maintain. This pattern is everywhere in production AWS.

## Key Pairs — How You Log In

A key pair proves who you are. AWS keeps the **public key** on the instance; you keep the
**private key** (`.pem` file) safe on your laptop.

- **Download once** — AWS gives you the `.pem` file exactly once, at creation. Lose it and you
  cannot log in with it again.
- **Protect it** — `chmod 400 key.pem` so only you can read it. SSH refuses to use a key others
  can read.
- **Connect** — `ssh -i key.pem ec2-user@<public-ip>`. The username depends on the AMI
  (`ec2-user` for Amazon Linux, `ubuntu` for Ubuntu).

There is no "forgot password" recovery for a lost `.pem` — your only real options are launching
a new instance, or the more advanced trick of detaching the root volume and reattaching it to a
rescue instance. Guard it like the crypto-mining story from Session 3: this is the same
category of mistake.

## Key Terms

- **Security group** — an allow-only, stateful virtual firewall attached to an instance
- **Stateful** — a return reply is automatically permitted without a matching rule
- **Key pair** — a public/private cryptographic pair used to prove identity instead of a password
- **.pem file** — the private half of a key pair, downloaded once, never recoverable if lost
