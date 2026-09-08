# Session 10 (4/5): EBS vs EFS vs S3 vs FSx — The Master Decision

## The one question that actually matters

Not "how much storage do I need" — instead:

```
        How does my application
           access the data?
                  |
     +------------+------------+
     v            v            v
 One server   Many servers   API/object
     |            |            |
     v            v            v
    EBS          EFS           S3
     |
     | unless there's a special
     | requirement (Windows/SMB,
     | HPC, migrating an existing
     | enterprise filesystem)
     v
    FSx
```

## Five scenarios, one rule each

| Scenario | Answer | Why |
|---|---|---|
| A single server's OS disk, or a database's data disk | **EBS** | One server needs its own fast, low-latency disk nothing else competes for |
| Shared uploads across an auto-scaling fleet | **EFS** | Every server must see the same files, regardless of which one handled the request |
| User photos, backups, static website files | **S3** | Unlimited scale, accessed by API, not something you mount |
| A fast scratch disk for one instance's temp data | **EBS or instance store** | Single-instance, high-speed, doesn't need to survive anything |
| A Windows team's shared drive, or an ML team reading a huge dataset at extreme speed | **FSx** | The two cases EFS structurally cannot cover — SMB and HPC throughput |

## The real stories behind each

### EBS — a payments database

```
EC2-DB
  |
  v
 EBS
  |
  +-- users
  +-- payments
  +-- transactions

  ONE server, needs a low-latency
  disk nothing else touches
```

Runs on one server and needs the fastest possible disk that only it
touches. This is exactly why you don't reach for EFS here — the database
doesn't need 50 servers sharing its data files, it needs one server with a
fast dedicated disk.

### EFS — a photo-sharing site on an auto-scaling fleet

```
                 Load Balancer
                      |
        +-------------+-------------+
        v             v             v
      EC2-A         EC2-B         EC2-C
        |             |             |
        +-------------+-------------+
                      |
                      v
                     EFS
                      |
                 /uploads/cat.jpg
```

A photo uploaded to any server must appear on all of them. Without EFS:

```
EC2-A saves to EBS-A -> cat.jpg
EC2-B looks in EBS-B -> not there
```

With EFS, one Linux file system every server mounts at once — new servers
added by the Auto Scaling Group see the same files instantly, no copying
required.

### S3 — the photo storage that doesn't need mounting at all

```
Application
     |
     | PUT / GET / DELETE (API, not a mount)
     v
    S3
```

Ten million photos doesn't mean ten thousand EC2 disks — it means an object
store designed for exactly this scale, reached through an API instead of a
filesystem path.

### FSx — a Windows team's shared drive, or an ML team's massive dataset

```
Windows PCs                          Huge ML dataset
     |                                     |
    SMB                                    v
     |                                     S3
     v                                     |
FSx for Windows                            v
                                   FSx for Lustre
                                            |
                                            v
                                     ML training job
```

FSx for Windows gives native SMB shares with Active Directory permissions.
FSx for Lustre gives HPC-grade throughput, often backed directly by S3.
EFS structurally cannot do either — wrong protocol for Windows, wrong
performance tier for HPC.

## The critical correction: "how many servers" isn't the whole rule

```
Many servers
     |
     v
Do they need a real filesystem (open/read/write/seek)?
     |
   YES  ------------------------->  EFS / FSx
     |
    NO
     |
     v
Do they just need objects through an API (PUT/GET)?
     |
   YES  ------------------------->  S3
```

Number of servers plus **access pattern** together decide this — not
server count alone. Many servers wanting simple object access still means
S3, not EFS.

## The full picture in one diagram

```
                    STORAGE DECISION
                           |
             +-------------+-------------+
             v             v             v
          BLOCK          FILE          OBJECT
             |             |             |
             v             v             v
            EBS        EFS / FSx         S3
             |             |             |
       One server     Shared files      API,
       low latency    many servers      huge scale
             |             |
       +-----+-----+  +----+----------------+
       v           v  v                     v
   Database    OS disk  Linux/simple    Specialized
                        shared FS       (Windows/SMB,
                                        HPC, migration)
```

## Where this shows up in real work

**WordPress on a multi-server fleet** is the textbook EFS use case —
uploads and themes shared across every web server via one file system. A
large share of **lift-and-shift migrations** (moving an existing on-prem
app to AWS unchanged) lean on EFS or FSx specifically because the legacy
application code expects a real mounted file system and was never written
to call an object storage API:

```
Legacy app (written in 2015):
  open("/uploads/photo.jpg")   <- expects a real filesystem path

              |
              v

  Point it at EFS: /uploads -> EFS     <- works, no code changes
  Point it at S3 directly              <- requires rewriting the app
                                           to call PUT/GET instead
```

The app can't simply be pointed at S3 without a rewrite, but pointing it
at a mounted EFS folder often needs no code changes at all.

## The full e-commerce example, end to end

```
Internet
   |
Load Balancer
   |
EC2-A  EC2-B  EC2-C  --- shared uploads --->  EFS
   |
EC2-DB  --- own low-latency disk --->  EBS (PostgreSQL data)

New photo uploads  --- API calls --->  S3

Windows employees  --- SMB --->  FSx for Windows

ML team:  S3 (dataset)  --->  FSx for Lustre (training)  --->  results back to S3
```

Five services, five different jobs, one architecture — this is what
thinking like an architect rather than memorizing service names looks
like.

**Interview line:** *"The decision isn't about which service can technically
hold files — it's how many servers need concurrent access and whether the
application expects a mounted filesystem or an API. One server wanting
speed is EBS. Many servers sharing files is EFS. Unlimited scale via API is
S3. A Windows or HPC requirement EFS can't meet is FSx. Legacy apps that
already assume a mounted drive are exactly why EFS and FSx matter for
lift-and-shift migrations, even in an API-first world."*

## Self-check before moving on

1. Why is "how many servers need access" a better first question than "how
   much data" or "how fast"?
2. Why might a legacy application be migrated onto EFS instead of being
   rewritten to use S3, even though S3 is cheaper and more scalable?
3. A team needs unlimited-scale storage for files accessed only through
   application code, never mounted as a drive. Which service, and why do
   EFS and FSx not fit?
