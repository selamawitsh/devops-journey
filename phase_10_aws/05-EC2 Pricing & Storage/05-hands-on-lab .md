# Session 05 (5/5): Hands-On Lab — Break It, Then Recover It

Create data, back it up, destroy it, then bring it back from the backup.
Screenshots go in `screenshots/` in this repo (folder already created) —
name them as noted at the end of each exercise.

---

## Exercise 1: Create Some Data

Launch a server and save a file onto its disk. This is the data you'll
protect.

1. In EC2, launch a small free-tier Linux server, wait for **Running**.
2. Connect: `ssh -i your-key.pem ec2-user@_______` (using its Public IPv4).
3. Write a file: `echo "my important data" > _______`
4. Check it: `cat notes.txt` and confirm you see your text.

<details>
<summary>Answer</summary>

- Connect using the instance's **Public IPv4 address**.
- `echo "my important data" > notes.txt`
- `notes.txt` is the file you'll destroy and then rescue — it only exists on
  this instance's root EBS volume right now.

</details>

**Screenshot:** `screenshots/01-notes-created.png` — terminal showing
`cat notes.txt` output.

---

## Exercise 2: Back It Up

A snapshot is a point-in-time copy of a disk.

1. In EC2, open **Volumes**. Find the EBS volume attached to your instance.
2. Tick it, Actions, `_______`.
3. Add a short description, click Create snapshot.
4. Open **Snapshots**, wait for status `_______`. Note the snapshot ID.

<details>
<summary>Answer</summary>

- Action: **Create snapshot**
- Status to wait for: **Completed** — relying on a snapshot before it's
  Completed means relying on a backup that isn't actually finished yet.

</details>

**Screenshot:** `screenshots/02-snapshot-completed.png` — the snapshot
showing status Completed.

---

## Exercise 3: Break It, Then Recover

The real test. Destroy the server, rebuild your file from the snapshot.

1. In Instances, select your server, Instance state, `_______`. Your
   `notes.txt` is now gone — why, specifically? (Hint: check what you learned
   about the root volume's default flag.)
   `_______________________________________________`
2. Open Snapshots, select yours, Actions, `_______`.
3. Launch a fresh server, then in Volumes attach the new volume to it (as
   `/dev/sdf`).
4. SSH in, find the real device name with `_______`, then mount it:
   `sudo mkdir /data && sudo mount /dev/_______ /data`
5. Prove recovery: `cat /data/notes.txt`.

<details>
<summary>Answer</summary>

1. **Terminate**. `notes.txt` is gone because the root volume's
   `DeleteOnTermination` flag defaults to true — the disk was destroyed along
   with the instance.
2. **Create volume from snapshot**.
3. (Console step, no blank.)
4. Find the device name with **lsblk** — the actual attached name (often
   `xvdf`) can differ from what you requested; trust `lsblk`, not the name you
   typed when attaching.
5. (No blank — this is the proof step.)

</details>

**Screenshot:** `screenshots/03-recovery-proof.png` — terminal showing
`cat /data/notes.txt` with your original text restored.

---

## Exercise 4: Pricing and Cleanup

See how much Spot could save, then remove everything so nothing keeps
billing.

1. In EC2, open Spot Requests, then Pricing history. Pick your small instance
   type. Note the Spot price vs the On-Demand price — roughly what
   percentage discount is that?
   `_______________________________________________`
2. In Instances, terminate every server you launched today. Confirm none
   stay Running.
3. In Volumes, delete any leftover volumes created from the snapshot — why
   does this step matter even though the instance using them is already
   gone?
   `_______________________________________________`
4. Decide on the snapshot: keep it if you want the backup, or delete it to
   save space.

<details>
<summary>Answer</summary>

1. Answer will vary by instance type and moment — the point is seeing the
   real discount, often 60-90% for small general-purpose types.
2. (Console step, no blank.)
3. **A detached volume still costs money.** It's billed independently of
   whether anything is using it — terminating the instance doesn't
   automatically remove volumes you created separately from a snapshot.
4. (Your choice — no single correct answer.)

</details>

---

## Take-Home Assignment

1. Launch an instance, create a file with a unique message, and take a
   snapshot of its volume.
2. Terminate the instance, then restore your file onto a **new** instance
   from the snapshot. Prove the message survived — screenshot as
   `screenshots/takehome-restore.png`.
3. Write a short cost comparison in `reflection.md` in this folder: for a
   `t3.micro` running 24/7 for a year, roughly what would On-Demand cost vs a
   1-year Reserved commitment? (Use the AWS Pricing Calculator.)
4. Submit your restore screenshot and `reflection.md` per the course's usual
   submission channel.
