# Session 2b · Availability Zones & The Global Footprint

## Availability Zones — Isolated Twins

An **Availability Zone (AZ)** is one or more data centers with independent power, cooling,
and networking, inside a Region.

- **Physically separate** — kilometers apart; a fire, flood, or power cut in one AZ cannot
  touch another.
- **Privately connected** — linked by AWS's own high-speed fiber; data moves between AZs in
  about a millisecond.
- **Named by letters** — Region code plus a letter: `us-east-1a`, `us-east-1b`, `us-east-1c`.

### The resilience recipe

Run your app in at least 2 AZs. One fails, the other keeps serving. **This single idea is
the core of high availability** — not something more exotic.

## How It Nests Together

```
REGION · us-east-1
├── AVAILABILITY ZONE · us-east-1a
│   ├── Data center
│   └── Data center
└── AVAILABILITY ZONE · us-east-1b
    ├── Data center
    └── Data center
```

Region contains AZs. AZs contain data centers. My job as the builder: spread workloads
across AZs, not just trust one.

## Closer Still: The Edge

Regions are far apart. AWS also runs smaller sites much closer to users:

| Site type | Purpose | Example use |
|---|---|---|
| **Edge Locations** | Content delivery — 600+ sites caching content (images, video, files) near users | Powers CloudFront (AWS's CDN); a user in Addis gets content from a nearby cache instead of Virginia |
| **Local Zones** | Ultra-low latency — mini extensions of a Region inside big cities | Gaming, live video, real-time trading |
| **Wavelength Zones** | 5G mobile — AWS compute embedded inside telecom 5G networks | Mobile traffic never leaves the carrier network |

## The Global Footprint (current scale)

| Regions | Availability Zones | Edge Locations | Services |
|---|---|---|---|
| 38 | 120+ | 600+ | 200+ |

These numbers only grow — worth re-checking on AWS's site rather than memorizing exactly,
since the direction is always up.

## Key Terms

- **Availability Zone (AZ)** — one or more isolated data centers within a Region
- **High availability** — designing a system to keep serving traffic even if part of it fails
- **CDN (Content Delivery Network)** — a network of caches that serve content from a location near the user
