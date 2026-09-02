# Session 05 (1/5): The Four Pricing Models

## On-Demand — the baseline

Pay per second (60-second minimum) on Linux; Windows and some other OS
billing is still hourly. This is why short-lived Linux experiments are
cheaper than people assume, and why On-Demand is the right default for
anything unpredictable or short.

## Spot — not an auction anymore

Older material describes Spot as literal bidding against other customers.
That model is gone. Spot price now tracks long-term supply and demand for
spare capacity in a given AZ/instance-type pool, and you're charged that
current market price, capped at a ceiling you set (usually the On-Demand
price). There's no real-time bidding war.

What hasn't changed: AWS can reclaim the instance with a **2-minute
warning**, delivered as a CloudWatch event and available from the instance's
own metadata endpoint. A real workload needs a handler that catches that
warning and checkpoints or drains gracefully.

**The real production pattern is diversification, not a single Spot
instance.** An ASG with a mixed-instances policy spread across many instance
types and multiple AZs means a reclaim in one pool doesn't correlate with a
reclaim in another — the fleet survives even as individual pieces get
interrupted. This is what makes Spot viable for real production batch work,
not just a risky discount.

## Reserved Instances vs Savings Plans — genuinely different tools

- **Reserved Instance** — commitment tied to a specific instance type and
  region. Standard RIs can't change type at all; Convertible RIs can, for a
  smaller discount than Standard.
- **Savings Plan** — a commitment to a dollar-per-hour spend, period. AWS
  automatically applies it to whatever instance type or family is actually
  running, even across EC2, Fargate, and some Lambda usage.

AWS itself now steers most customers toward Savings Plans over RIs
specifically because of that flexibility. Know which one an interviewer
means when they say "Reserved" — they're not interchangeable.

## Dedicated Hosts vs Dedicated Instances

A **Dedicated Instance** just guarantees no other AWS customer's workload
shares your physical hardware. A **Dedicated Host** goes further — you get
visibility into the actual physical server (sockets, cores), which matters
specifically because some software licenses (Windows Server, Oracle) are
priced per-socket or per-core and require that visibility to stay compliant.
Compliance and licensing are two different reasons to land here, not the
same reason phrased two ways.

**Interview line:** *"On-Demand is the flexible baseline. Spot tracks
supply/demand for spare capacity with a 2-minute reclaim warning — real
production use means diversifying across instance types and AZs, not a
single Spot instance. Reserved Instances commit to a specific instance
family; Savings Plans commit to a spend level and apply automatically to
whatever's running, which is why AWS recommends them for most cases now.
Dedicated Hosts add physical visibility for per-socket licensing, which
Dedicated Instances don't provide."*

