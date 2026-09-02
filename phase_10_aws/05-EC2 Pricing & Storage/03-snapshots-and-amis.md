# Session 05 (3/5): Snapshots & AMIs

## Incremental, precisely

The first snapshot copies every block. Every snapshot after that only saves
blocks changed since the *previous* snapshot. AWS manages the chain
intelligently: deleting an intermediate snapshot doesn't lose data a later
snapshot still needs — AWS's internal reference counting preserves those
blocks automatically. Keeping every snapshot forever isn't required to keep
the chain valid.

## Crash-consistent vs application-consistent

A snapshot taken while an instance is running captures whatever was
physically on disk at that instant — equivalent to pulling the power cord.
Fine for a lot of data. For a database, a write might be half-flushed to
disk at the exact moment the snapshot fires, and recovering from it is
functionally identical to recovering from a hard crash — the database's own
crash-recovery mechanism (WAL replay in Postgres, journal replay in MongoDB)
has to sort it out on next startup. It usually does, but it isn't
guaranteed clean.

**Application-consistent** backups coordinate with the database first —
flush and pause writes, snapshot, then resume — so the backup reflects a
genuinely clean state. Tools like AWS Backup do this automatically for
supported databases. Worth knowing this distinction exists at the "just take
a snapshot" level: it's the difference between having used snapshots and
understanding what a snapshot actually guarantees.

## Cross-AZ and cross-Region copying

A volume lives in exactly one AZ. Its snapshot can be copied anywhere —
another AZ, another Region — then used to create a fresh volume there. This
is the actual mechanism for moving or duplicating a disk.

## AMI = snapshot(s) + boot metadata

An AMI isn't a separate mechanism from a snapshot — it's a snapshot (or
snapshots, for multi-volume setups) plus metadata describing how to actually
boot from it: kernel, architecture, root device mapping. A "golden image" is
just an AMI made from a properly configured instance, snapshotted once, then
referenced by every future launch — this is the direct foundation of the
versioned launch templates from Session 06.

**Interview line:** *"Snapshots are incremental block-level backups stored
in S3 behind the scenes, with AWS managing the chain so deleting an old one
doesn't break newer ones. A snapshot taken from a live instance is
crash-consistent, not application-consistent — a database needs coordinated
flushing for a guaranteed-clean backup. An AMI is just a snapshot plus boot
metadata, which is why golden images are the foundation of Auto Scaling."*

## Self-check before moving on

1. If you delete an older snapshot in a chain, why doesn't that break a newer
   snapshot that depends on some of the same blocks?
2. Why might a snapshot taken from a running Postgres instance not be a
   perfectly clean backup, even though the snapshot itself completed fine?
3. What two things does an AMI actually consist of?


