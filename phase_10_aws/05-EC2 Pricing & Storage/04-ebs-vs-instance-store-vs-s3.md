# Session 05 (4/5): EBS vs Instance Store vs S3

## Instance store — fast because it's physically local, temporary for the same reason

Instance store lives on the same physical host as the instance — real NVMe
hardware, no network hop, none of the latency EBS has as a network disk.
That's exactly why it can't survive: the data lives on that specific
physical machine, so stopping or terminating the instance (or AWS moving the
instance to different underlying hardware) wipes it. Right tool for scratch
space, caches, or temporary processing buffers — never for anything worth
being upset to lose.

## S3's actual consistency model

S3 now provides **strong read-after-write consistency** for all operations —
this changed in December 2020. Write an object, and an immediate read is
guaranteed to return the new version. Older material describing S3 as
"eventually consistent" is out of date; giving that answer in an interview
is a real red flag, not a safe simplification.

## Storage classes — a retrieval-time vs cost trade-off

- **S3 Standard** — frequently accessed data.
- **Standard-IA / One Zone-IA** — infrequent access, lower storage cost, a
  retrieval fee applies; One Zone trades away multi-AZ redundancy for a
  further discount.
- **Intelligent-Tiering** — AWS automatically moves objects between tiers
  based on actual observed access patterns.
- **Glacier family** — archives, cheapest to store, slowest to retrieve:
  Instant Retrieval, Flexible Retrieval (minutes to hours), Deep Archive (up
  to about 12 hours). Each tier is cheaper than the last and slower to get
  data back out of.

## The decision framework

| | EBS | Instance store | S3 |
|---|---|---|---|
| Attached to | One instance, network | One instance, physical | Nothing — accessed via API |
| Survives instance stop/terminate | If DeleteOnTermination is off | Never | Always |
| Speed | Fast (network disk) | Fastest (local) | Not a disk at all |
| Use for | Server/database disks | Scratch, cache, temp buffers | Files, media, backups, static content |

## Where this shows up in a real platform

Binary content — satellite imagery, voucher QR codes, uploaded receipts, KYC
document scans — has no business being stored as a blob inside Postgres or
MongoDB. The standard pattern: store the *file* in S3, store the *reference*
(a URL or key) in the database. This keeps the database small and fast, and
keeps large binary content in a system actually built to serve it at scale.

**Interview line:** *"EBS is a network-attached disk for server storage that
needs to persist. Instance store is physically local, fastest possible, and
wiped on stop — scratch data only. S3 is object storage, not a disk at all,
accessed via API, with strong read-after-write consistency and storage
classes that trade retrieval speed for cost. Binary files belong in S3 with
a reference stored in the database, not as blobs in the database itself."*

## Self-check before moving on

1. Why is instance store faster than EBS, and why is that same property what
   makes it unsuitable for anything important?
2. Is S3 eventually consistent or strongly consistent today, and since when?
3. Why store a satellite image in S3 with a reference in Postgres, instead of
   storing the image directly in the database?
