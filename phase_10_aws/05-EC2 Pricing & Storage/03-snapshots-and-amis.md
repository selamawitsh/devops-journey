# Snapshots & AMIs

*Session 05 (3/5) — Linux/DevOps Curriculum*

This session connects directly to the previous one: **EBS → Snapshots → AMIs → Launch Templates → Auto Scaling.** Once that chain clicks, a lot of AWS architecture stops feeling like separate topics and starts looking like one idea applied at different layers.

The core question this session answers: *how do I back up an EBS disk, move it somewhere else, or use one properly configured server as the template for many new servers?*

---

## Table of Contents

1. [What is an EBS snapshot?](#1-what-is-an-ebs-snapshot)
2. [Snapshots are incremental, precisely](#2-snapshots-are-incremental-precisely)
3. [Crash-consistent vs application-consistent](#3-crash-consistent-vs-application-consistent)
4. [Cross-AZ and cross-Region copying](#4-cross-az-and-cross-region-copying)
5. [AMI = snapshot(s) + boot metadata](#5-ami--snapshots--boot-metadata)
6. [Golden images and why this matters for Auto Scaling](#6-golden-images-and-why-this-matters-for-auto-scaling)
7. [The three concepts, not confused](#7-the-three-concepts-not-confused)
8. [Applying this to a real platform](#8-applying-this-to-a-real-platform)
9. [Interview line](#9-interview-line)
10. [Self-check](#10-self-check)

---

## 1. What is an EBS snapshot?

Start with an EC2 instance and its attached disk:

```
EC2
 |
 +── EBS 100 GB
       |
       +── application files
       +── configuration
       +── data
```

An **EBS snapshot** is a point-in-time backup of the blocks on that volume:

```
EBS Volume
    |
    | create snapshot
    v
Snapshot #1
```

---

## 2. Snapshots are incremental, precisely

The first snapshot copies **every block**. Every snapshot after that only saves the blocks **changed since the previous snapshot** — not a fresh full copy each time.

Say a disk has five blocks: `A B C D E`.

```
Snapshot #1 → A B C D E        (full copy — first snapshot always is)
Snapshot #2 → B' D'            (only what changed since #1)
Snapshot #3 → C'               (only what changed since #2)
```

### The part that trips people up: deleting an old snapshot

It's tempting to picture this as a fragile dependency chain — Snapshot #3 depends on #2, which depends on #1, so deleting #1 should break #3. **That's not what happens.**

AWS manages the underlying block references with internal reference counting:

```
Delete Snapshot #1
        ↓
AWS determines which blocks are still needed
        ↓
Those blocks remain
        ↓
Snapshot #3 remains fully usable
```

You don't need to keep every old snapshot forever just to keep the chain valid — AWS is tracking which physical blocks are still referenced by *something*, independent of which snapshot originally captured them.

---

## 3. Crash-consistent vs application-consistent

This is the most important distinction in the session, and it's easy to miss at the "just take a snapshot" level.

### What a live snapshot actually captures

A snapshot taken while an instance is running captures **whatever was physically on disk at that instant** — nothing more, nothing coordinated with the application. Conceptually:

```
🏃 Database running
        ↓
📸 SNAPSHOT!
```

That's **crash-consistent**: equivalent to pulling the power cord at that exact moment. The snapshot doesn't ask the database "are you finished writing?" — it just captures storage state, whatever that state happens to be.

For a database, a write might be **half-flushed to disk** at the exact instant the snapshot fires:

```
Write A → completed
Write B → partially flushed
Write C → waiting
```

Recovering from that snapshot is functionally identical to recovering from a hard crash — the database's own crash-recovery mechanism has to sort it out on next startup (WAL replay in PostgreSQL, journal replay in MongoDB). **It usually works.** It isn't guaranteed clean.

The important part: **"Snapshot completed successfully" does not mean "I now have a perfectly clean database backup."** The snapshot operation itself can succeed completely while the captured database state is only crash-consistent.

### The alternative: application-consistent

**Application-consistent** backups coordinate with the database *before* the snapshot fires:

```
Database
   ↓
"Prepare for backup"
   ↓
Flush pending writes
   ↓
Pause/coordinate writes
   ↓
📸 Snapshot
   ↓
Resume writes
```

Now the backup reflects a genuinely clean state, not a moment frozen mid-write. Tools like **AWS Backup** do this coordination automatically for supported databases.

Knowing this distinction exists is the difference between having *used* snapshots and actually *understanding what a snapshot guarantees* — worth being precise about, especially for anything running a database.

---

## 4. Cross-AZ and cross-Region copying

An EBS volume lives in exactly **one** Availability Zone — you can't attach a volume from `us-east-1a` directly to an instance in `us-east-1b`. Snapshots are the actual mechanism for moving a disk anywhere else.

### Moving to another AZ

```
AZ-1                         AZ-2

EBS
 |
Snapshot
 |
 | copy/restore
 +--------------------------> New EBS
                                  |
                                  v
                                EC2
```

### The same pattern works across Regions

```
EBS
 ↓
Snapshot
 ↓
Copy snapshot to another Region
 ↓
Create EBS volume
 ↓
Attach to EC2
```

This is the underlying mechanism behind disaster recovery, migration, regional copies, and testing against a production-like disk elsewhere.

---

## 5. AMI = snapshot(s) + boot metadata

**AMI (Amazon Machine Image)** isn't a separate mechanism from a snapshot — it's built directly on top of one.

An AMI consists of two things:

```
              AMI
               |
       +-------+-------+
       |               |
       v               v
    Snapshot(s)    Boot metadata
       |               |
       +-------+-------+
               |
               v
        Launch EC2
```

1. **Disk snapshot information** — what should be on the instance's volumes, potentially multiple snapshots for multi-volume setups.
2. **Boot metadata** — how the instance should actually boot: architecture, root device mapping, kernel-related boot information.

The snapshot alone doesn't know how to *boot* anything — it's just data. The AMI adds the metadata that turns "a backup of some blocks" into "a template you can launch a working machine from."

---

## 6. Golden images and why this matters for Auto Scaling

A **golden image** is just an AMI made from a properly configured instance — installed, patched, secured, tested — snapshotted once, then referenced by every future launch instead of manually configuring each new instance by hand.

```
Perfect EC2
    ↓
Create AMI
    ↓
Golden Image
```

This is the **direct foundation of the versioned launch templates** covered in Session 06:

```
ASG
 |
Launch Template
 |
AMI
 |
EC2
```

### The versioning chain this creates

```
Application v1        Application v2
     ↓                      ↓
   AMI v1                 AMI v2
     ↓                      ↓
Launch Template v1    Launch Template v2
     ↓                      ↓
    ASG                    ASG
     ↓                      ↓
    EC2                  New EC2
```

If v2 has a problem, rolling back means pointing the ASG at **Launch Template v1** — which still references **AMI v1** — not reconstructing what changed. This is the same immutable-revision pattern that shows up at every layer of this curriculum: task definitions, launch templates, and now AMIs are all versions of the same underlying idea.

---

## 7. The three concepts, not confused

These three terms get used loosely enough that it's worth pinning down exactly what each one is:

| Term | What it actually is |
|---|---|
| **EBS** | The actual virtual disk attached to an EC2 instance — `EC2 ←→ EBS` |
| **Snapshot** | A point-in-time backup/copy of EBS data — `EBS → Snapshot` |
| **AMI** | A bootable EC2 template containing snapshot(s) + boot metadata — `AMI → Launch EC2` |

The practical difference in intent:

- With a **snapshot**, the question is *"I want the data from this EBS volume."*
- With an **AMI**, the question is *"I want to launch a new EC2 configured like this machine."*

Same underlying block data, entirely different purpose.

---

## 8. Applying this to a real platform

Take a production backend built the way a real multi-service platform would be: a carefully configured server running the OS, container runtime, monitoring agent, security configuration, the application itself, and its dependencies.

That configured instance becomes **AMI v1**, which becomes **Launch Template v1**, which the ASG uses to launch a fleet:

```
Configured EC2
      ↓
     AMI v1
      ↓
Launch Template v1
      ↓
     ASG
      ↓
  EC2 #1, #2, #3
```

When a new version of the application ships, the same instance gets rebuilt, re-verified, and snapshotted again as **AMI v2**, feeding a new **Launch Template v2**. An **instance refresh** then gradually replaces the fleet — `EC2 #1 → v2`, `EC2 #2 → v2`, `EC2 #3 → v2` — one batch at a time, with health checks protecting the rollout the entire way (see the Auto Scaling Group and Scaling Policies docs for exactly how that mechanism works).

The full chain, end to end:

```
        Application
             ↓
          AMI v2
             ↓
    Launch Template v2
             ↓
            ASG
             ↓
        EC2 instances
             ↓
            ALB
             ↓
           Users
```

That's the full picture this curriculum has been building toward — EBS, snapshots, AMIs, launch templates, ASGs, and load balancers aren't separate topics. They're one continuous chain, each layer versioned and immutable for the same reason: certainty about what's running, and a clean way back if it's wrong.

---

## 9. Interview line

> *"Snapshots are incremental block-level backups stored in S3 behind the scenes, with AWS managing the chain so deleting an old one doesn't break newer ones. A snapshot taken from a live instance is crash-consistent, not application-consistent — a database needs coordinated flushing for a guaranteed-clean backup. An AMI is just a snapshot plus boot metadata, which is why golden images are the foundation of Auto Scaling."*

---

## 10. Self-check

1. If you delete an older snapshot in a chain, why doesn't that break a newer snapshot that depends on some of the same blocks?
2. Why might a snapshot taken from a running PostgreSQL instance not be a perfectly clean backup, even though the snapshot itself completed fine?
3. What two things does an AMI actually consist of?
4. Walk through, in your own words: `Configured EC2 → AMI → Launch Template → ASG → New EC2 instances` — what is each step actually doing, and why does it exist?

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **Snapshot** | Point-in-time, incremental block-level backup of an EBS volume |
| **Incremental chain** | Each snapshot after the first stores only changed blocks; AWS's reference counting means deleting an old snapshot never breaks a newer one |
| **Crash-consistent** | What a live-instance snapshot gives you by default — equivalent to pulling the power cord, recovery relies on the app's own crash-recovery mechanism |
| **Application-consistent** | Backup coordinated with the app first (flush, pause, snapshot, resume) — genuinely clean state |
| **Cross-AZ / cross-Region copy** | A volume lives in one AZ, but its snapshot can be copied anywhere and used to create a new volume there |
| **AMI** | Snapshot(s) + boot metadata (architecture, root device mapping) — a bootable template, not just a backup |
| **Golden image** | An AMI built from a properly configured instance, used as the standard starting point for future launches |
| **Full chain** | Application → AMI → Launch Template → ASG → EC2 → ALB → Users, versioned and immutable at every layer |
