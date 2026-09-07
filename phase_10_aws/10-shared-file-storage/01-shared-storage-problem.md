# Session 10 (1/5): The Shared Storage Problem

## Visual: The problem in one picture

```
                     Users
                       |
                       v
                Load Balancer
                       |
          +------------+------------+
          v            v            v
        EC2-A        EC2-B        EC2-C
          |            |            |
          v            v            v
        EBS-A        EBS-B        EBS-C
```

A user uploads `profile.jpg`. The load balancer happens to route the request
to EC2-A, which saves it to EBS-A:

```
EC2-A -> EBS-A -> profile.jpg
```

The same user's next request lands on EC2-B instead:

```
EC2-B -> EBS-B -> ??? profile.jpg not here ???
```

It's not there, because `EBS-A ≠ EBS-B` — two completely separate disks. That
gap between "the request can land on any server" and "the data lives on only
one server's disk" is the entire shared storage problem, and it's the reason
EFS exists.

## Visual: Block vs File vs Object, side by side

```
EBS (block)                EFS (file)                 S3 (object)

  EBS-A                        EFS                     Bucket
    |                           |                         |
    v                  +--------+--------+       PUT/GET/DELETE via API
  EC2-A                v        v        v                |
                     EC2-A    EC2-B    EC2-C        any server, anywhere
  one server,        all three see the
  one disk           exact same files
```

## Why EBS categorically can't be a shared drive

EBS speaks a raw block protocol — no concept of multiple concurrent writers
coordinating access, no locking, no shared state, nothing above "here are
some blocks." At the lowest level it looks like this:

```
EBS
+---------+---------+---------+---------+-----+
| Block 1 | Block 2 | Block 3 | Block 4 | ... |
+---------+---------+---------+---------+-----+
```

Your OS turns those raw blocks into a filesystem after you format and mount
the volume — but that filesystem-level bookkeeping lives on the one instance
that mounted it. An Auto Scaling fleet where each instance has its own EBS
volume means a file uploaded to server A is simply invisible to server B —
different disk, full stop.

EFS speaks **NFS (Network File System)** instead — a protocol specifically
designed for many clients to read and write the same filesystem
concurrently, with real POSIX file locking semantics:

```
                       EFS
                        |
          +-------------+-------------+
          v             v             v
        EC2-A         EC2-B         EC2-C
          |             |             |
          +-------------+-------------+
                        |
                same files, shared
```

That's the actual mechanism behind "EFS can be shared and EBS can't" — not
just a marketing distinction.

## The io2 Multi-Attach exception

**Narrow exception worth knowing:** `io2 Block Express` supports
**multi-attach**, letting one EBS volume mount to multiple instances:

```
                    io2 EBS volume
                        |
          +-------------+-------------+
          v             v             v
        EC2-A         EC2-B         EC2-C

           shared BLOCK DEVICE, not a shared filesystem
```

Compare that to the EFS diagram above: EFS hands every instance a shared
*filesystem* with locking built in. Multi-Attach just hands multiple
instances the same raw blocks — it's on the cluster-aware application (a
specific clustered database, for example) to coordinate who writes what.
Knowing this exception exists, and knowing it doesn't turn EBS into a general
substitute for a shared file system, is what separates a real answer from a
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

## Visual: The one diagram to memorize

```
                        STORAGE
                           |
           "How does my application need
                to access the data?"
                           |
        +------------------+------------------+
        v                  v                  v
   ONE SERVER         MANY SERVERS        ANYWHERE / API
        |                  |                  |
        v                  v                  v
      EBS                EFS                 S3
        |                  |                  |
        v                  v                  v
   BLOCK STORAGE      FILE STORAGE       OBJECT STORAGE
   (disk-like)      (shared folder)      (PUT/GET objects)
```

**Interview line:** *"The distinguishing question for any storage choice
isn't speed or capacity — it's how many servers need it and how they access
it. One server with a mounted disk is EBS. Many servers sharing files as a
folder is EFS. Anything, anywhere, accessed by API is S3. EBS can't be
shared because its protocol has no concept of concurrent writers; EFS
solves that with NFS specifically."*
