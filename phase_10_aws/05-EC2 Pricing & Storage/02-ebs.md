# EBS — Disks That Survive (If You Configure Them To)

*Session 05 (2/5) — Linux/DevOps Curriculum*

EBS gets described as "persistent storage" as if that's a fixed property. It isn't — persistence is a *configuration*, and the default configuration on the volume people care about most (the root volume) is the one that doesn't persist.

---

## Table of Contents

1. [A network disk, not a local one](#1-a-network-disk-not-a-local-one)
2. [Volume types, precisely](#2-volume-types-precisely)
3. [The gotcha: "persists" is conditional, not automatic](#3-the-gotcha-persists-is-conditional-not-automatic)
4. [Interview line](#4-interview-line)
5. [Self-check](#5-self-check)
6. [If you only remember 7 things](#6-if-you-only-remember-7-things)

---

## 1. A network disk, not a local one

EBS is attached **over the network**, within the same Availability Zone — the bytes are never physically inside the instance itself:

```
              AWS Storage System
                     |
                     |
                  Network
                     |
                     v
                 +-------+
                 |  EBS  |
                 |Volume |
                 +-------+
                     |
                     |
                  Network
                     |
                     v
                 +-------+
                 |  EC2  |
                 +-------+
```

**EBS is a network disk that communicates over AWS's internal network.**

This one fact explains two things at once:

- **Why a volume can detach from one instance and attach to another** — there's nothing physically local to move, it's just a network connection being pointed at a different instance.
- **Why EBS has slightly more latency than a truly local disk** — that network hop is real, not a footnote. It's the actual reason **instance store** exists as a separate option (see the EBS vs Instance Store vs S3 doc) — for workloads where that latency matters more than persistence does.

---

## 2. Volume types, precisely

```
                        EBS
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
      gp3           io2          HDD
       |             |          /     \
       |             |         /       \
 General purpose  High IOPS   st1      sc1
                              |         |
                         Throughput    Cold
```

### gp3 — the default

**Decouples IOPS and throughput from volume size.** Every gp3 volume gets a **3,000 IOPS / 125 MB/s baseline regardless of size**, with more of either provisionable independently as needed.

This replaced **gp2**, where getting more performance meant buying a bigger, mostly-empty disk just to unlock it — performance and capacity were tied together whether you wanted that or not.

### io2 / io2 Block Express — for latency-sensitive databases

**Provisioned IOPS** storage, built for workloads where consistent, high IOPS matters more than anything else.

**io2 Block Express** adds **multi-attach** — the same volume mounted to multiple instances at once, which is what clustered applications (needing shared, simultaneous access to the same block storage) actually require.

### st1 — throughput-optimized HDD

For big **sequential** workloads — log processing, big data pipelines — where raw IOPS don't matter but sustained throughput does.

### sc1 — cold HDD

The cheapest option per GB, meant for data that's rarely touched at all.

---

## 3. The gotcha: "persists" is conditional, not automatic

Every instance's **root volume** has a `DeleteOnTermination` flag — and it **defaults to `true`.**

```
                EC2
               |
           Root EBS
               |
     DeleteOnTermination
               |
        +------+------+
        |             |
      true          false
        |             |
        v             v
 Terminate EC2    Terminate EC2
        |             |
        v             v
 EBS deleted      EBS survives
```

Terminate the instance, and the root EBS volume — the one people assume survives *because* "EBS persists" — goes with it.

**This is a real, common incident:** a test instance gets terminated, and a supposedly-persistent disk is simply gone — because nobody unchecked one box.

### Why this catches people off guard specifically

**Non-root volumes** — ones explicitly attached separately from the root — default to **not** auto-deleting on termination. So the behavior actually *differs* between the root volume and everything else attached to the same instance. The assumption "EBS persists" is true for extra attached volumes by default, and false for the root volume by default — which is exactly backwards from what most people expect.

---

## 4. Interview line

> *"EBS is network-attached block storage within a single AZ — that's what makes it detachable and reattachable, at the cost of a little more latency than local disk. gp3 is the default for most workloads because IOPS and throughput scale independently of size. Persistence past termination depends on the DeleteOnTermination flag, which defaults to true on the root volume — a common real source of 'my persistent disk vanished' incidents."*

---

## 5. Self-check

1. Why can an EBS volume detach from one instance and attach to another, but an instance store volume can't?
2. Why did gp3 replace gp2 as the default volume type?
3. You terminate an EC2 instance expecting its EBS root volume to survive, and it doesn't. What setting almost certainly caused that?

---

## 6. If you only remember 7 things

1. EBS = network-attached block storage.
2. EBS is tied to an Availability Zone, not permanently to one EC2 instance.
3. EBS can be detached and reattached to another compatible EC2 in the same AZ.
4. gp3 = general-purpose SSD and separates storage size from provisioned IOPS/throughput.
5. io2 = high-performance/provisioned IOPS storage.
6. st1 = throughput-heavy sequential workloads; sc1 = cold/infrequent access.
7. EBS persistence is conditional. Check `DeleteOnTermination`, especially for the root volume.

---

## Quick recap

| Concept | What it actually is |
|---|---|
| **EBS = network disk** | Attached over AWS's internal network within one AZ — not physically inside the instance |
| **Detach/reattach** | Possible precisely because nothing local needs to move |
| **Latency trade-off** | The network hop costs a little latency versus true local disk — the reason instance store exists |
| **gp3** | Default SSD — IOPS/throughput scale independently of volume size |
| **io2 / io2 Block Express** | Provisioned IOPS for latency-sensitive DBs; Block Express adds multi-attach for clusters |
| **st1** | Throughput-optimized HDD for big sequential workloads |
| **sc1** | Cheapest per GB, for rarely-touched cold data |
| **DeleteOnTermination** | Defaults to `true` on the root volume (deleted on terminate), `false` on other attached volumes (survives) |
