# Session 4b · The Four Building Blocks

Every instance needs these four things. Think of it like assembling a computer, not buying one
pre-built.

## 1. AMI — The Template

**Amazon Machine Image**: the OS and pre-installed software. Amazon Linux, Ubuntu, Windows.
Your instance boots from this.

## 2. Instance Type — The Size

Covered in 4a. How much CPU and memory — decides speed and price. `t3.micro` for our lab.

## 3. Storage — The Disk

An **EBS volume**: a virtual hard drive that persists. The root volume holds the OS.

Worth knowing beyond today's slides: EBS is distinct from **instance store**, storage
physically attached to the host that is wiped the moment the instance stops. EBS survives
stop/start and can be resized live; instance store cannot. Default to EBS unless you have a
specific reason to want ephemeral, high-speed scratch space.

## 4. Network + Security — The Doors

Which VPC and subnet it lives in, and a **security group** controlling who can reach it (full
detail in Session 4c).

## Real-World Pattern: Golden AMIs

Companies don't install software by hand on every server. They bake a "golden AMI" — an image
with the OS, security patches, monitoring agents, and base software already installed — then
launch every new instance from that one image. New servers come up identical and fast, with
zero manual setup. This is your first glimpse of **immutable infrastructure**: instead of
patching a running server, you build a new image and replace the instance. You'll meet this
idea properly once you reach Packer and Terraform.

## Common Mistakes

- Forgetting instance store data disappears on stop, then panicking when "my files are gone."
- Not resizing an EBS volume proactively — waiting until the disk is full during an incident is
  the wrong time to learn you can do this live.
- Launching into the wrong subnet and then wondering why the instance has no internet access —
  network placement is a building block, not an afterthought.

## Key Terms

- **AMI (Amazon Machine Image)** — the OS + software template an instance boots from
- **EBS (Elastic Block Store)** — a persistent virtual disk, independent of instance lifecycle
- **Instance store** — ephemeral, host-attached storage, wiped on stop
- **VPC / Subnet** — the network the instance lives inside
