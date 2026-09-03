# EBS vs Instance Store vs S3

*Session 05 (4/5) — Linux/DevOps Curriculum*

This session is really about one question: **where should my application actually store its data?** Three options exist because they're built for three different jobs — a persistent server disk, a fast temporary disk, and object storage that isn't a disk at all.

---

## Table of Contents

1. [The big picture](#1-the-big-picture)
2. [Instance store — fast because it's physically local](#2-instance-store--fast-because-its-physically-local)
3. [Why instance store is so fast](#3-why-instance-store-is-so-fast)
4. [The catch: temporary for the same reason it's fast](#4-the-catch-temporary-for-the-same-reason-its-fast)
5. [EBS, revisited alongside the other two](#5-ebs-revisited-alongside-the-other-two)
6. [S3 — object storage, not a disk](#6-s3--object-storage-not-a-disk)
7. [The decision table](#7-the-decision-table)
8. [S3's actual consistency model](#8-s3s-actual-consistency-model)
9. [S3 storage classes — a retrieval-time vs cost trade-off](#9-s3-storage-classes--a-retrieval-time-vs-cost-trade-off)
10. [The moving-house analogy](#10-the-moving-house-analogy)
11. [The three questions to ask](#11-the-three-questions-to-ask)
12. [Applying this to a real platform](#12-applying-this-to-a-real-platform)
13. [Interview line](#13-interview-line)
14. [Self-check](#14-self-check)

---

## 1. The big picture

Picture an EC2 server as a **restaurant kitchen**. There are three different places to keep things, and they're built for very different purposes:

- 🗄️ **EBS** — a storage room connected to the kitchen
- ⚡ **Instance Store** — a drawer physically inside the kitchen
- 📦 **S3** — a huge external warehouse, accessed through an API

```
                    AWS
                     │
          ┌──────────┼──────────┐
          │          │          │
         EBS    Instance Store   S3
          │          │           │
     Network disk   Local disk   Object storage
          │          │           │
      Persistent   Temporary     Highly durable
```

The single most important thing to hold onto: **EBS and Instance Store are disks. S3 is not a disk.**

---

## 2. Instance store — fast because it's physically local

**Instance store** lives on the **same physical host** as the instance — real NVMe hardware, no network hop, none of the latency EBS has as a network disk.

```
Physical AWS Server
┌─────────────────────────────┐
│                             │
│       EC2 Instance          │
│                             │
│   CPU + RAM                 │
│                             │
│   ┌─────────────────────┐   │
│   │ Instance Store      │   │
│   │ Local NVMe          │   │
│   └─────────────────────┘   │
│                             │
└─────────────────────────────┘
```

There is essentially **no network trip** to a separate storage system — the drive is physically part of the same box the instance is running on.

---

## 3. Why instance store is so fast

Compare the actual path data has to travel for each option.

**EBS:**

```
EC2
 │
 │ Network
 ↓
EBS
```

The EC2 instance has to communicate with a **separate storage system** over the network.

**Instance store:**

```
EC2
 │
 ↓
Local NVMe
```

The storage is **physically on the host** — no separate system to talk to at all.

**Instance store = local storage → very low latency → very fast.**

---

## 4. The catch: temporary for the same reason it's fast

The exact thing that makes instance store fast is also what makes it dangerous for anything important: the data is physically tied to *that specific host*.

```
EC2
 │
 └── Instance Store
        │
        └── 💀 gone
```

Stop or terminate the instance — or have AWS move it to different underlying hardware — and the data on that drive is simply gone. There's no detach-and-reattach option, because there's no network connection to redirect; it's bolted to that one physical machine.

**Wrong instinct:** *"I'll put my database there because it's faster."* ❌

**Good uses instead:** temporary files, caches, scratch space, temporary processing buffers, intermediate files — anything that can be recreated if it disappears.

```
Upload video
      ↓
EC2 Instance
      ↓
Instance Store
      ↓
Process video
      ↓
Upload final result to S3
      ↓
Delete temporary file
```

If that temporary file vanishes mid-process, it's not a disaster — you reprocess it. The final result already lives somewhere durable (S3).

**The mental model to keep:** *fast enough to use, temporary enough to lose.* Never put something there that would make you upset to lose.

---

## 5. EBS, revisited alongside the other two

EBS is a **network-attached block storage volume** used as a disk for EC2 — it isn't physically sitting inside the instance the way instance store is:

```
        EC2
     ┌───────┐
     │       │
     │Server │
     └───┬───┘
         │
       Network
         │
         ↓
     ┌───────┐
     │  EBS  │
     │Volume │
     └───────┘
```

### Why that network attachment is actually useful

Because it can be **detached and reattached elsewhere:**

```
EC2-A
  │
  └──── EBS

        ↓ detach

EC2-A

        ↓ attach

EC2-B
  │
  └──── EBS
```

If a server crashes, the disk itself can potentially move to a replacement:

```
Old EC2 💀
     ↓
Detach EBS
     ↓
New EC2
     ↓
Attach EBS
     ↓
Continue
```

The one limitation carried over from the EBS session: **an EBS volume exists in exactly one Availability Zone.** Moving it to another AZ means going through a snapshot to create a new volume there, not a direct attach.

---

## 6. S3 — object storage, not a disk

**S3 (Simple Storage Service)** shouldn't be pictured as a hard drive at all. Think of it instead as **massive object storage accessed through APIs.**

### What "object storage" actually means

S3 doesn't behave like a normal filesystem path:

```
/home/selamawit/photos/nahom.jpg     ← NOT how S3 works
```

Instead, everything lives in a flat bucket as an **object**:

```
Bucket
   │
   ├── nahom.jpg
   ├── receipt-001.pdf
   ├── satellite-image-001.tif
   └── video.mp4
```

You interact with it via API calls or CLI tools, not by mounting it like a drive:

```bash
aws s3 cp image.jpg s3://my-bucket/
```

There's no host to attach it to, no filesystem to mount by default — just a key, and an object stored under that key.

---

## 7. The decision table

| | EBS | Instance store | S3 |
|---|---|---|---|
| **Type** | Block storage | Local block storage | Object storage |
| **Connection** | Network | Physical/local | API |
| **Attached to** | One instance, over the network | One instance, physically | Nothing — accessed via API |
| **Speed** | Fast (network disk) | Fastest (local, no network hop) | Not comparable as a disk |
| **Survives stop/terminate** | If `DeleteOnTermination` is off | Never | Always |
| **Good for** | OS/database disks | Scratch, cache, temp buffers | Files, media, backups, static content |
| **Example** | PostgreSQL disk | Cache, video-processing scratch | Images, videos, backups |

---

## 8. S3's actual consistency model

This is a real interview trap. Older material describes S3 as **"eventually consistent"** — that description is **out of date**, and repeating it today is a genuine red flag, not a safe simplification.

Since **December 2020**, S3 provides **strong read-after-write consistency** for all operations:

```
PUT object
   ↓
Immediately GET object
   ↓
You get the newly written object
```

Write an object, and an immediate read is **guaranteed** to return the new version — there's no window where you might get stale or missing data back.

**The correct interview answer today:** *"S3 provides strong read-after-write consistency for object operations, introduced in December 2020."*

---

## 9. S3 storage classes — a retrieval-time vs cost trade-off

Think of this like storing clothes: what you wear constantly stays in the closet; what you rarely touch goes further and further into storage, cheaper each step but slower to get back.

### S3 Standard

For frequently accessed data — website images, application content, anything hit regularly.

```
Frequently accessed
       ↓
S3 Standard
```

### Standard-IA / One Zone-IA

**IA = Infrequent Access.** Lower storage cost, but a **retrieval fee** applies when you actually pull the data back.

```
Rarely accessed
      ↓
Standard-IA
```

**One Zone-IA** goes a step further — it trades away multi-AZ redundancy (data lives in just one AZ) for an even bigger discount. Cheaper, but with real added risk if that one AZ has a problem.

### Intelligent-Tiering

For when access patterns are genuinely unpredictable — you tell AWS "figure it out," and it monitors actual access and moves objects between tiers automatically.

```
Object
  ↓
Intelligent-Tiering
  ↓
AWS observes access
  ↓
Automatically moves between tiers
```

### The Glacier family — for archives

For data you probably won't need, but absolutely don't want to delete: old backups, historical records, compliance archives, old logs.

```
Glacier Instant Retrieval    → very fast retrieval
Glacier Flexible Retrieval   → minutes to hours
Glacier Deep Archive         → up to ~12 hours, cheapest to store
```

**The trade-off across every tier, without exception: cheaper storage means slower or more constrained retrieval.** Each tier is cheaper than the last and slower to get data back out of.

---

## 10. The moving-house analogy

A simple way to hold all three at once:

**EBS = a storage room.** It's connected to your house, but it's a separate space — and if you move houses, you can potentially bring its contents with you (detach and reattach elsewhere).

**Instance Store = a drawer inside the house.** Extremely convenient and fast to reach into. But if the house itself is destroyed — 💀 — the drawer's contents go with it.

**S3 = a warehouse company.** You send your boxes to a huge external warehouse. You don't care which physical machine stores your box, or where it physically sits. You just say *"give me `farm-123/photo.jpg`"* and the warehouse handles the rest.

---

## 11. The three questions to ask

Whenever a new piece of data needs somewhere to live, three questions in order:

**1. Do I need a disk attached to a server?** → **EBS**

**2. Do I need extremely fast, temporary, local storage?** → **Instance Store**

**3. Am I storing files/objects that don't need to behave like a disk?** → **S3**

---

## 12. Applying this to a real platform

Take a platform where farmers upload farm photos, satellite imagery, KYC documents, receipts, and voucher QR images.

### The beginner mistake

```
PostgreSQL
│
├── farmer
├── farm
├── investment
└── satellite_image = HUGE_BINARY_DATA
```

Storing large binary content directly as a blob inside Postgres or MongoDB is usually the wrong call — it has no business living there.

### The standard pattern instead

Store the **file** in S3, store the **reference** (a URL or key) in the database:

```
                 Platform
                     │
          ┌──────────┴──────────┐
          │                     │
      PostgreSQL                S3
          │                     │
     Metadata/reference      Actual file
          │                     │
          │                 satellite.jpg
          │                 receipt.pdf
          │                 kyc.png
          │
          └─────── reference ──┘
```

For example, the database row might just contain:

```
farm_id: 123
name: "Green Valley Farm"
satellite_image_key: "farms/123/satellite.jpg"
```

The **database stores information about the file**. **S3 stores the actual file.**

### Why this matters at scale

A single satellite image at 50 MB, multiplied across 100,000 farms, would make a database storing the images directly balloon:

```
PostgreSQL
████████████████████████████████
████████████████████████████████
████████████████████████████████
████████████████████████████████
```

Keeping only references instead keeps the database small, fast, and focused on what it's actually good at — structured queries — while the large binary content lives in a system built to serve it at scale:

```
PostgreSQL
├── farm_id
├── farmer_id
├── location
└── image_key

S3
├── image 1
├── image 2
├── image 3
├── image 4
└── ...
```

### A four-way decision, applied

Given four real pieces of data, the same three questions resolve all of them:

| Data | Choice | Why |
|---|---|---|
| PostgreSQL database files | **EBS** | A disk the database server needs attached and persistent |
| Temporary video-processing files | **Instance Store** | Fast, local, fine to lose and regenerate |
| Farmer profile photos | **S3** | Files/objects served independently of any one server |
| Application server root filesystem | **EBS** | The OS/application disk the instance boots and runs from |

---

## 13. Interview line

> *"EBS is a network-attached disk for server storage that needs to persist. Instance store is physically local, fastest possible, and wiped on stop — scratch data only. S3 is object storage, not a disk at all, accessed via API, with strong read-after-write consistency and storage classes that trade retrieval speed for cost. Binary files belong in S3 with a reference stored in the database, not as blobs in the database itself."*

---

## 14. Self-check

1. Why is instance store faster than EBS, and why is that same property what makes it unsuitable for anything important?
2. Is S3 eventually consistent or strongly consistent today, and since when?
3. Why store a satellite image in S3 with a reference in Postgres, instead of storing the image directly in the database?
4. **Bonus:** for each of these, choose EBS, Instance Store, or S3, and explain why — PostgreSQL database files; temporary video-processing files; farmer profile photos; application server root filesystem.

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **EBS** | Network-attached block storage — persistent (if `DeleteOnTermination` is off), detachable/reattachable, tied to one AZ |
| **Instance Store** | Physically local NVMe storage — fastest possible, wiped on stop/terminate, scratch use only |
| **S3** | Object storage, not a disk at all — accessed via API, strongly consistent since Dec 2020 |
| **S3 storage classes** | Standard (frequent) → IA (infrequent, retrieval fee) → Intelligent-Tiering (auto-managed) → Glacier family (archive, cheapest, slowest) |
| **Binary content pattern** | File goes in S3, reference/key goes in the database — keeps the DB small and fast |
| **Three questions** | Need it attached to a server? → EBS. Need it fast and temporary? → Instance Store. Just files/objects? → S3 |
