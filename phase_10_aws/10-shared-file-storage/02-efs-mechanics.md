# Session 10 (2/5): EFS Mechanics

## The one diagram to memorize first

Every other concept in this file is just a detail hanging off this one path:

```
   EC2
    |
    | network connection
    v
Mount Target  (has its own ENI + private IP, one per AZ)
    |
    | TCP, destination port 2049
    v
   NFS
    |
    v
   EFS
    |
    +--------+--------+
    v        v        v
 file.txt photo.jpg report.pdf
```

If you can redraw that from memory, the rest of this file is just filling in
why each link exists.

## Mount targets are real network resources

```
                         VPC
        +-------------------+-------------------+
        |                   |                   |
       AZ-1                AZ-2                AZ-3
        |                   |                   |
      EC2-A               EC2-B               EC2-C
        |                   |                   |
   Mount Target        Mount Target        Mount Target
   ENI: 10.0.1.100     ENI: 10.0.2.100     ENI: 10.0.3.100
        |                   |                   |
        +-------------------+-------------------+
                            |
                            v
                           EFS
```

EFS creates one mount target **per AZ**, and each mount target gets its own
**ENI with a real IP inside your VPC subnet** — same as any EC2 instance.
This is exactly why the security group rule matters, and why a missing NFS
(port 2049) rule makes the mount hang forever:

```
EC2-A ---- TCP 2049 ----> [ Security Group: 2049 NOT allowed ]  --X-->  EFS
                                                                      (blocked,
                                                                    mount hangs)
```

You're making a normal network connection to a normal-looking network
endpoint that happens to be EFS, not connecting through some opaque
managed-service channel. Same security-group reasoning from Session 4,
pointed at a different kind of resource.

## No capacity to plan

Unlike EBS, there's no size to choose. EFS grows as files are added and
shrinks as they're deleted — you pay for what's actually stored, with
nothing to pre-provision or resize.

```
Day 1:    EFS [##--------------------] 10 GB used
Day 30:   EFS [##########------------] 150 GB used
Day 100:  EFS [######################] 2 TB used

                    vs. EBS, where you pick
                    a fixed size up front:

EBS [####################] 100 GB  <- chosen at creation, resized manually
```

## Performance modes

```
                EFS
                 |
        +--------+--------+
        v                 v
  General Purpose       Max I/O
        |                 |
  low per-operation   huge concurrency
  latency (the        (thousands of
  default choice)      clients at once)
```

- **General Purpose** — lowest per-operation latency. The right default for
  almost everything.
- **Max I/O** — higher aggregate throughput at very high levels of
  concurrency (thousands of instances hitting the file system at once), at
  the cost of slightly higher per-operation latency.

Don't read this as "Max I/O = faster" — it trades latency for scale, it
doesn't just win on both.

## Throughput modes

```
                 EFS
                  |
      +-----------+-----------+
      v           v           v
  Bursting   Provisioned    Elastic
      |           |           |
  scales with  fixed rate  auto-scales
  stored size, independent  with actual
  burst credits of size     demand
```

```
Bursting (credit battery):        Elastic (follows demand):

  baseline throughput          High  |        /\
       ^                             |       /  \
  spike|_/\_                   Low   |______/    \____
       (spend credits)                    time ->
```

- **Bursting** — throughput scales with how much data is stored, backed by
  a burst-credit system. Fine for spiky, moderate workloads.
- **Provisioned** — pay for a fixed throughput independent of stored size —
  for a small dataset that still needs high throughput.
- **Elastic** — auto-scales throughput up and down with actual demand. The
  simplest choice when traffic is unpredictable.

**Keep performance mode and throughput mode in separate mental buckets:**

```
Performance mode  -> how individual operations behave (latency/concurrency)
Throughput mode   -> how much data the filesystem can move per second
```

```
PERFORMANCE
├── General Purpose → low latency/default
└── Max I/O         → massive concurrency

THROUGHPUT
├── Bursting        → storage-based + burst
├── Provisioned     → choose fixed throughput
└── Elastic         → automatically adapts
```

## Storage classes — the same idea as S3, one layer down

```
        DATA
          |
  +-------+-------+
  v               v
 HOT             COLD
  |               |
frequently     rarely
accessed       accessed
  |               |
  v               v
Standard          IA
              (moved here automatically
               after no access for a while,
               via lifecycle rules)
```

EFS Standard vs **EFS-IA (Infrequent Access)**, with lifecycle management
that can automatically move files to the cheaper IA tier after a period of
no access. Directly the same cost-optimization pattern as S3 lifecycle
rules (Session 09) — just applied to a mounted file system instead of
objects.

## Why EFS is Linux-only

```
Linux/Unix  --->  NFS  --->  EFS

Windows     --->  SMB  --->  FSx for Windows File Server
```

NFS is the protocol EFS speaks, and it's a Linux/Unix-native protocol.
Windows doesn't natively speak NFS the way it speaks SMB — which is exactly
why FSx for Windows exists as a separate product using SMB instead, rather
than EFS simply supporting Windows too.

**Interview line:** *"EFS mount targets are real ENIs in your VPC, gated by
security groups like any other resource — that's why NFS/2049 has to be
explicitly allowed. It has no capacity to plan, since it grows and shrinks
automatically. Performance and throughput modes exist because 'shared file
system' covers workloads from a few instances to thousands, and one
configuration doesn't fit all of them. Its storage classes mirror S3's
hot/cold cost pattern, and it's Linux-only because it's built on NFS, not
SMB."*

