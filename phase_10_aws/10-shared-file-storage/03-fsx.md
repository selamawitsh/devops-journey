# Session 10 (3/5): FSx — When EFS Isn't the Right Fit

## FSx for Windows

Uses **SMB**, the Windows-native file sharing protocol, and can integrate
directly with **Active Directory** — existing Windows file permissions and
domain-joined access control carry over. Real value for an enterprise team
migrating a Windows fileshare to AWS without redesigning their permission
model from scratch.

## FSx for Lustre — the elegant trick for ML/HPC

Ultra-fast file system for high-performance computing: machine learning
training, big-data analytics, simulations.

**The genuinely useful production pattern:** FSx for Lustre can link
directly to an S3 bucket as its backing data repository. Point it at a
bucket, and it lazy-loads objects from S3 as files on first access, and can
write results back to S3.

This enables a real cost/performance trade: training data lives cheaply in
S3 long-term. When a training job needs to run, spin up FSx for Lustre
linked to that bucket, get POSIX filesystem performance for the duration of
the job, then tear the file system down. High-performance storage costs are
only paid during the actual compute-intensive window, not continuously.

## NetApp ONTAP and OpenZFS — migration, not new builds

These exist for one specific reason: lifting an existing on-prem NetApp or
ZFS-based file system into AWS with matching snapshot, cloning, and
multi-protocol behavior, rather than redesigning around EFS's simpler
model. If there's no existing system being migrated, this almost never the
starting point.

## The decision fork

| Choose EFS when | Choose FSx when |
|---|---|
| Linux workloads (the common case) | Windows apps needing an SMB share |
| Simple shared storage for a fleet | High-performance computing (Lustre) |
| Want elastic sizing, no capacity planning | Migrating a specific enterprise file system |
| Web servers, content, shared app data | Special performance or protocol needs |

**Interview line:** *"EFS is the Linux default — reach for FSx only when a
specific requirement forces it. FSx for Windows when SMB/Active Directory
compatibility is needed. FSx for Lustre when a workload needs
HPC-grade throughput, especially when it can link straight to S3 as its
backing store for a training job's lifetime. NetApp ONTAP and OpenZFS exist
specifically for lifting an existing enterprise file system into AWS, not
for new builds."*

## Self-check before moving on

1. Why would a team choose FSx for Windows over EFS even though both are
   "shared file storage"?
2. How does linking FSx for Lustre to an S3 bucket save money on a
   short-lived ML training job compared to keeping a Lustre file system
   running permanently?
3. When would NetApp ONTAP or OpenZFS actually be the right choice, and why
   is that different from a typical new build?
