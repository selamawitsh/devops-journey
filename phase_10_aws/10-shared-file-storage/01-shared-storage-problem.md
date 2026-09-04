# Session 10 (1/5): The Shared Storage Problem

## Why EBS categorically can't be a shared drive

EBS speaks a raw block protocol — no concept of multiple concurrent writers
coordinating access, no locking, no shared state, nothing above "here are
some blocks." An Auto Scaling fleet where each instance has its own EBS
volume means a file uploaded to server A is simply invisible to server B —
different disk, full stop.

EFS speaks **NFS (Network File System)** instead — a protocol specifically
designed for many clients to read and write the same filesystem
concurrently, with real POSIX file locking semantics. That's the actual
mechanism behind "EFS can be shared and EBS can't," not just a marketing
distinction.

**Narrow exception worth knowing:** `io2 Block Express` supports
**multi-attach**, letting one EBS volume mount to multiple instances. This
is for cluster-aware applications that manage their own coordination (a
specific clustered database, for example) — not a general substitute for a
shared file system. Knowing this exception exists, and knowing it doesn't
change the general rule, is what separates a real answer from a
half-remembered one.

## The storage trio, by the question that actually distinguishes them

Not speed, not size — **how many servers, and how do you access it:**

| | Block (EBS) | File (EFS/FSx) | Object (S3) |
|---|---|---|---|
| How many servers | One | Many, simultaneously | Anything, anywhere |
| How you access it | Format and mount, like a local disk | Mount as a folder, many instances at once | HTTP API — PUT/GET, not mountable |
| What it's for | A server's own fast disk | A folder every instance in a fleet shares | Files, backups, static content, unlimited scale |

The gap S3 and EBS both leave: S3 isn't mountable like a drive (it's
accessed by API, covered in Session 09), and EBS attaches to exactly one
instance. EFS is the missing middle — a real shared folder, many machines,
same files, simultaneously.

**Interview line:** *"The distinguishing question for any storage choice
isn't speed or capacity — it's how many servers need it and how they access
it. One server with a mounted disk is EBS. Many servers sharing files as a
folder is EFS. Anything, anywhere, accessed by API is S3. EBS can't be
shared because its protocol has no concept of concurrent writers; EFS
solves that with NFS specifically."*

## Self-check before moving on

1. Why is "EBS can't be shared" a protocol limitation, not just an AWS
   product decision?
2. What does `io2` multi-attach actually allow, and why isn't it a general
   substitute for EFS?
3. An app needs to access files exclusively through an HTTP API, from
   anywhere, at unlimited scale — no mounting required. Which of the three
   storage types fits, and why do the other two not?
