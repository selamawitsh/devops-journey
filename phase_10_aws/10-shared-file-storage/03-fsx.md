# Session 10 (3/5): FSx — When EFS Isn't the Right Fit

## Why FSx exists at all

The trap is thinking "FSx is a fancier EFS." It isn't. EFS is the simple
default; FSx exists only because some workloads need a specific protocol,
filesystem technology, or performance profile that EFS was never designed
to provide.

```
                  Shared File Storage
                          |
             +------------+------------+
             v                         v
            EFS                       FSx
             |                         |
   simple shared Linux         specialized needs
      filesystem                      |
                          +-----------+-----------+-----------+
                          v           v           v           v
                       Windows     Lustre    NetApp ONTAP   OpenZFS
```

Don't think "FSx is better than EFS." Think: **"FSx is for specific
requirements that EFS isn't designed to satisfy."**

## FSx for Windows

Windows has its own native file-sharing protocol, and it isn't the one EFS
speaks:

```
Linux world:                       Windows world:

Linux application                  Windows application
       |                                  |
       | NFS                              | SMB
       v                                  v
      EFS                          FSx for Windows

  \\fileserver\shared  (a normal Windows network share, same idea)
```

That protocol difference is the surface reason this product exists. The
**deeper** value is Active Directory integration — existing Windows
permissions carry straight over instead of being redesigned:

```
Active Directory
       |
   +---+---+---+
   v   v   v
 Alice Bob John

Finance folder permissions (already defined in AD):
  Alice -> Read/Write
  Bob   -> Read
  John  -> No access

           |
           v
  FSx for Windows respects these same permissions
  after migrating from an on-prem Windows file server
```

**The real interview answer:** *"FSx for Windows lets an organization
preserve its existing Windows file-sharing and identity/permission model
when moving to AWS — not just 'it supports Windows.'"*

## FSx for Lustre — the elegant trick for ML/HPC

```
Normal shared storage:                HPC / ML workload:

  EC2 -------- EFS                  EC2  EC2  EC2  EC2  EC2
                |                     |    |    |    |    |
             shared files             +----+----+----+----+
                                                |
                                                v
                                      FSx for Lustre
                                      (very high performance,
                                       POSIX filesystem)
```

Lustre exists for one word: **performance**. It's built for workloads
needing extremely fast, high-concurrency access to large datasets —
machine learning training, scientific simulation, big-data analytics.

### The genuinely useful production pattern: Lustre + S3

```
              S3
      (cheap, durable, long-term)
      dataset/image1 ... image1,000,000
              |
              | linked as backing store
              v
       FSx for Lustre
     (fast, temporary working filesystem)
              |
              v
        ML training job
              |
              v
       results written back to S3
```

**Lazy loading**, step by step:

```
ML job:  "I need image500"
             |
             v
     FSx for Lustre: "not cached locally yet"
             |
             v
            S3  ---->  fetches image500
             |
             v
     FSx for Lustre now serves it
             |
             v
          ML job
```

### Why this saves real money

```
Bad pattern:                          Good pattern:

High-performance Lustre               Data lives cheaply in S3
running 24/7/365                      year-round
        |                                     |
      $$$$$$                          Spin up Lustre only
   (mostly idle,                      for the training window
    training only runs                        |
    10 hrs/week)                       Run training job
                                               |
                                       Write results to S3
                                               |
                                       Tear Lustre down
                                               |
                                       Pay only for the
                                       hours actually used
```

**Mental model:** S3 is the warehouse. Lustre is the high-speed workbench
you wheel out only while you're actually working.

### Why not just use S3 directly?

```
S3                                    FSx for Lustre
-> object storage                     -> high-performance filesystem
-> HTTP API: PUT / GET / DELETE       -> POSIX-style file access
-> durable, cheap repository          -> built for HPC/ML compute
```

They complement each other rather than compete — S3 for where the data
lives long-term, Lustre for the filesystem interface a compute job
actually needs while it's running.

## NetApp ONTAP and OpenZFS — migration, not new builds

```
On-premises today:                  After migrating to AWS:

    NetApp                           FSx for NetApp ONTAP
      |                                      |
  snapshots                              same snapshots,
  clones                                 clones, and
  existing permissions        --->       permission model,
      |                                  now running in AWS
  years of built-up
  infrastructure/process
```

Same logic for OpenZFS — an organization with an existing ZFS-based
filesystem gets a managed, AWS-hosted equivalent rather than being forced
to redesign around EFS.

**Why these are never the default starting point:** if you're building a
brand-new application from scratch and just need shared storage for Linux
web servers, there's no existing NetApp or ZFS environment to preserve —
so EFS is simpler. These two exist specifically for the migration case,
not as "the newest/best storage options."

## The decision fork

| Choose EFS when | Choose FSx when |
|---|---|
| Linux workloads (the common case) | Windows apps needing an SMB share |
| Simple shared storage for a fleet | High-performance computing (Lustre) |
| Want elastic sizing, no capacity planning | Migrating a specific enterprise file system |
| Web servers, content, shared app data | Special performance or protocol needs |

The same fork, walked step by step:

```
       I need shared file storage
                  |
                  v
        Simple Linux shared FS?
                  |
          YES ----+---- NO
           |             |
          EFS            v
                 Need Windows + SMB?
                          |
                  YES ----+---- NO
                   |             |
            FSx for Windows      v
                          HPC / ML / analytics?
                                  |
                          YES ----+---- NO
                           |             |
                    FSx for Lustre       v
                                 Existing NetApp or
                                 ZFS environment to migrate?
                                          |
                                  YES ----+---- NO
                                   |             |
                            ONTAP / OpenZFS   re-evaluate —
                                              EFS is probably
                                              still the answer
```

## The three questions that actually decide this

```
1. What operating environment/protocol do I need?
       Linux/NFS   -> EFS
       Windows/SMB -> FSx for Windows

2. Do I need specialized performance?
       HPC/ML -> FSx for Lustre

3. Am I migrating an existing specialized filesystem?
       NetApp -> FSx for NetApp ONTAP
       ZFS    -> FSx for OpenZFS
```

**Interview line:** *"EFS is the Linux default — reach for FSx only when a
specific requirement forces it. FSx for Windows when SMB/Active Directory
compatibility is needed. FSx for Lustre when a workload needs HPC-grade
throughput, especially when it can link straight to S3 as its backing store
for a training job's lifetime. NetApp ONTAP and OpenZFS exist specifically
for lifting an existing enterprise file system into AWS, not for new
builds."*

## Self-check before moving on

1. Why would a team choose FSx for Windows over EFS even though both are
   "shared file storage"?
2. How does linking FSx for Lustre to an S3 bucket save money on a
   short-lived ML training job compared to keeping a Lustre file system
   running permanently?
3. When would NetApp ONTAP or OpenZFS actually be the right choice, and why
   is that different from a typical new build?
