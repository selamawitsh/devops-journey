# Session 10 (4/5): EBS vs EFS vs S3 vs FSx — The Master Decision

## Five scenarios, one rule each

| Scenario | Answer | Why |
|---|---|---|
| A single server's OS disk, or a database's data disk | **EBS** | One server needs its own fast, low-latency disk nothing else competes for |
| Shared uploads across an auto-scaling fleet | **EFS** | Every server must see the same files, regardless of which one handled the request |
| User photos, backups, static website files | **S3** | Unlimited scale, accessed by API, not something you mount |
| A fast scratch disk for one instance's temp data | **EBS or instance store** | Single-instance, high-speed, doesn't need to survive anything |
| A Windows team's shared drive, or an ML team reading a huge dataset at extreme speed | **FSx** | The two cases EFS structurally cannot cover — SMB and HPC throughput |

## The real stories behind each

- **EBS — a payments database.** Runs on one server and needs the fastest
  possible disk that only it touches. Attaches to a single instance with
  low latency — perfect for a boot volume or a database's data disk.
- **EFS — a photo-sharing site on an auto-scaling fleet.** A photo uploaded
  to any server must appear on all of them. EFS is one Linux file system
  many servers mount at once — new servers see the same files instantly,
  no copying required.
- **FSx — a Windows design team's shared drive, or an ML team's massive
  dataset.** FSx for Windows gives native SMB shares; FSx for Lustre gives
  HPC-grade throughput. EFS can do neither.

## The underlying pattern

Ask, in order: **how many servers need it, and does it need to survive the
instance?**

- One server, needs speed → EBS
- Many servers, need the same files → EFS
- Anywhere, via API, unlimited scale → S3
- A specific protocol or performance requirement EFS can't meet → FSx

## Where this shows up in real work

**WordPress on a multi-server fleet** is the textbook EFS use case —
uploads and themes shared across every web server via one file system. A
large share of **lift-and-shift migrations** (moving an existing on-prem
app to AWS unchanged) lean on EFS or FSx specifically because the legacy
application code expects a real mounted file system and was never written
to call an object storage API — the app can't simply be pointed at S3
without a rewrite, but pointing it at a mounted EFS folder often needs no
code changes at all.

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
