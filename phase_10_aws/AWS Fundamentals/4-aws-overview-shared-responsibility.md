# Session 1d · Meet AWS & The Shared Responsibility Model

## AWS At A Glance

Launched in 2006 with a single service (S3). Today: 200+ services, 38 regions, 120+
availability zones, 600+ edge locations, spanning compute, storage, databases, ML, IoT,
and more.

## The Shared Responsibility Model

Security in the cloud is a partnership, split into two halves:

**AWS secures — "Security OF the Cloud"**
- Physical datacenters
- Hardware & network
- Virtualization infrastructure
- Managed service software

**You secure — "Security IN the Cloud"**
- Your data & its encryption
- IAM users, roles, passwords
- OS patches on your own servers
- Firewall rules & access control

## Worked Example — Launching an EC2 Server

| Layer | Who's responsible |
|---|---|
| The building | AWS |
| Physical hardware | AWS |
| Hypervisor / virtualization | AWS |
| OS on your instance | You |
| Patching that OS | You |
| The application you install | You |
| Your database password | You |

**The pattern:** the further "up the stack" you go, the more sits on you. This is also why
IaaS gives you the most control *and* the most responsibility, while SaaS gives the vendor
the most control and leaves the least on you — control and responsibility move together.

## Key Terms

- **Region** — a physical location containing multiple, isolated data centers
- **Availability Zone (AZ)** — one or more datacenters within a region
- **Edge location** — a smaller site used for content delivery (CDN), closer to end users


