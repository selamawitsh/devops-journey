# Session 10 (2/5): EFS Mechanics

## Mount targets are real network resources

EFS creates one mount target **per AZ**, and each mount target gets its own
**ENI with a real IP inside your VPC subnet** — same as any EC2 instance.
This is exactly why the security group rule matters, and why a missing NFS
(port 2049) rule makes the mount hang forever: you're making a normal
network connection to a normal-looking network endpoint that happens to be
EFS, not connecting through some opaque managed-service channel. Same
security-group reasoning from Session 4, pointed at a different kind of
resource.

## No capacity to plan

Unlike EBS, there's no size to choose. EFS grows as files are added and
shrinks as they're deleted — you pay for what's actually stored, with
nothing to pre-provision or resize.

## Performance modes

- **General Purpose** — lowest per-operation latency. The right default for
  almost everything.
- **Max I/O** — higher aggregate throughput at very high levels of
  concurrency (thousands of instances hitting the file system at once), at
  the cost of slightly higher per-operation latency.

## Throughput modes

- **Bursting** — throughput scales with how much data is stored, backed by
  a burst-credit system. Fine for spiky, moderate workloads.
- **Provisioned** — pay for a fixed throughput independent of stored size —
  for a small dataset that still needs high throughput.
- **Elastic** — auto-scales throughput up and down with actual demand. The
  simplest choice when traffic is unpredictable.

## Storage classes — the same idea as S3, one layer down

EFS Standard vs **EFS-IA (Infrequent Access)**, with lifecycle management
that can automatically move files to the cheaper IA tier after a period of
no access. Directly the same cost-optimization pattern as S3 lifecycle
rules (Session 09) — just applied to a mounted file system instead of
objects.

## Why EFS is Linux-only

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

## Self-check before moving on

1. Why does a missing NFS security group rule cause the mount command to
   hang instead of immediately failing?
2. When would Max I/O performance mode actually matter over General
   Purpose?
3. Why can't EFS simply add Windows support instead of AWS building a
   separate FSx for Windows product?
