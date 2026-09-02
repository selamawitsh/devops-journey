# Session 05 (2/5): EBS — Disks That Survive (If You Configure Them To)

## A network disk, not a local one

EBS is attached over the network within the same AZ — the bytes are never
physically inside the instance. This is exactly why a volume can detach from
one instance and attach to another (nothing local to move), and it's also
why EBS has slightly more latency than a truly local disk. That trade-off is
real, not a footnote — it's the reason instance store exists as a separate
option (see the EBS vs Instance Store vs S3 doc).

## Volume types, precisely

- **gp3** — the default. Decouples IOPS and throughput from volume size: a
  3,000 IOPS / 125 MB/s baseline regardless of size, with more provisionable
  independently. This replaced gp2, where getting more performance meant
  buying a bigger, mostly-empty disk just to unlock it.
- **io2 / io2 Block Express** — provisioned IOPS for latency-sensitive
  databases. Block Express supports **multi-attach** — the same volume
  mounted to multiple instances at once, for clustered applications.
- **st1 (throughput-optimized HDD)** — big sequential workloads (log
  processing, big data) where raw IOPS don't matter but throughput does.
- **sc1 (cold HDD)** — cheapest per GB, for data rarely touched.

## The gotcha: "persists" is conditional, not automatic

Every instance's root volume has a `DeleteOnTermination` flag, and it
**defaults to true**. Terminate the instance, and the root EBS volume —
the one people assume survives because "EBS persists" — goes with it. This
is a real, common incident: a test instance gets terminated, and a
supposedly-persistent disk is simply gone, because nobody unchecked one box.

Non-root volumes explicitly attached default to *not* auto-deleting, which
is part of why this catches people off guard — the behavior differs between
the root volume and everything else.

**Interview line:** *"EBS is network-attached block storage within a single
AZ — that's what makes it detachable and reattachable, at the cost of a
little more latency than local disk. gp3 is the default for most workloads
because IOPS and throughput scale independently of size. Persistence past
termination depends on the DeleteOnTermination flag, which defaults to true
on the root volume — a common real source of 'my persistent disk vanished'
incidents."*

## Self-check before moving on

1. Why can an EBS volume detach from one instance and attach to another, but
   an instance store volume can't?
2. Why did gp3 replace gp2 as the default volume type?
3. You terminate an EC2 instance expecting its EBS root volume to survive,
   and it doesn't. What setting almost certainly caused that?
