# Session 2a · Regions & How to Choose One

## Why Location Isn't Just Trivia

The speed of light is a real engineering constraint. A user in Addis Ababa hitting a server
in Virginia sends a request ~11,000 km each way — undersea cables, routers, handoffs — and
that round trip stacks up on every single page load. Server far away = sluggish clicks.
Server nearby = a snappy app. This is why "pick the right Region" is an engineering
decision, not a formality.

## What Is a Region?

A **Region** is a physical location where AWS clusters data centers. Each Region is
completely independent from every other Region.

**Anatomy of a Region code — `us-east-1`:**

| Part | Meaning |
|---|---|
| `us` | Country/area |
| `east` | Location within it |
| `1` | Sequence number |

### Regions worth knowing right now

| Code | Location | Note |
|---|---|---|
| `us-east-1` | N. Virginia | Course default, AWS's very first Region |
| `af-south-1` | Cape Town | Closest Region to Ethiopia |
| `eu-west-1` | Ireland | Europe's workhorse |

## How To Choose a Region — Four Questions, In Order

1. **Compliance** — does the law require data to stay in a specific country? If yes, this
   decides everything else. Banking and health data often legally cannot leave.
2. **Latency** — where are your actual users? Pick the Region closest to them; milliseconds
   are user experience.
3. **Service availability** — new AWS services don't launch everywhere at once. Confirm the
   service you need actually exists in your candidate Region.
4. **Cost** — the same instance costs different amounts in different Regions. `us-east-1`
   is usually cheapest; São Paulo is among the priciest.

**The order matters** — compliance overrides everything below it. Latency only gets to be
the deciding factor once legal constraints are satisfied.

## Key Terms

- **Region** — an independent, isolated geographic area AWS operates in
- **Latency** — the delay between a request being sent and a response arriving
