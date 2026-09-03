# Session 09 (5/5): Hands-On Lab — Publish a Website from S3

Store files in S3, undo a mistake with versioning, publish a real website,
then lock a bucket down. Screenshots go in `screenshots/` in this repo
(folder already created) — name them as noted at the end of each exercise.

---

## Exercise 1: A Safety Net

Prove versioning can undo an overwrite.

1. In S3, Create bucket, give it a globally unique name like
   `qiyas-yourname-lab`.
2. Open the bucket, Properties, Bucket Versioning, click Edit,
   `_______`, Save.
3. Make a small `notes.txt` that says "version one", upload it.
4. Edit the file to say "version two", upload it again with the same name.
5. In the Objects list, toggle `_______`. You now see both copies.
6. Restore: delete the newer version (or download the older one).

<details>
<summary>Answer</summary>

- Step 2: **Enable**
- Step 5: toggle **Show versions** — this is what reveals the safety net;
  without it, the console only shows you the current version and it looks
  like the old one is simply gone.

</details>

**Screenshot:** `screenshots/01-versions-visible.png` — the Objects list
with Show versions on, both copies visible.

---

## Exercise 2: Save on Old Files

Add a lifecycle rule that ages objects into cheaper storage automatically.

1. In your bucket, click the `_______` tab, then Create lifecycle rule.
2. Name it `archive-old`, choose Apply to all objects, tick the
   acknowledgement.
3. Add a transition: tick "Move current versions between storage classes."
4. Pick `_______` after 30 days since object creation.
5. Also tick "Expire current versions" after `_______` days.
6. Click Create rule.

<details>
<summary>Answer</summary>

- Tab: **Management**
- Storage class: **Standard-IA**
- Expiry: **365** days
- Nothing changes on screen today — the rule runs on AWS's daily schedule,
  not immediately.

</details>

**Screenshot:** `screenshots/02-lifecycle-rule.png` — the created rule
summary showing the transition and expiration.

---

## Exercise 3: Publish a Website

Host a real page straight from a bucket — deliberately, the one time this
whole course makes something public.

1. Create a second bucket: `qiyas-yourname-site`, in your Region.
2. Permissions tab, Block Public Access, Edit, untick `_______`, confirm.
3. Properties, Static website hosting, Enable, set index document to
   `_______`.
4. Write an `index.html` with your name in an `<h1>`, upload it.
5. Add a bucket policy allowing `_______` on this bucket to everyone.
6. Copy the `_______` URL from Properties (not the object URL) and open it.

<details>
<summary>Answer</summary>

- Step 2: untick **Block all public access**
- Step 3: `index.html`
- Step 5: action **s3:GetObject**
- Step 6: the **website endpoint** — the plain object URL will not serve it
  as a website; it has to be the specific static-hosting endpoint.

Bucket policy shape:
```json
{
  "Effect": "Allow",
  "Principal": "*",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::qiyas-yourname-site/*"
}
```

</details>

**Screenshot:** `screenshots/03-website-live.png` — your page open in a
browser via the website endpoint URL.

---

## Exercise 4: Lock Down, Then Clean Up

Confirm the safe default protects a normal bucket, then remove everything.

1. Open your first bucket (the lab one), Permissions tab. Confirm
   `_______` is still ON — the default that kept it private this whole
   time.
2. In the website bucket, click Empty, type the confirm phrase.
3. In the versioned bucket, toggle Show versions and delete `_______` —
   this is required before the bucket itself can be deleted.
4. Delete both buckets. Confirm nothing you made is left behind.

<details>
<summary>Answer</summary>

- Step 1: **Block all public access**
- Step 3: **every version** (and any delete markers) — a versioned bucket
  won't delete until every version is gone, not just the current one.

</details>

**Screenshot:** `screenshots/04-both-buckets-deleted.png` — the bucket list
confirming both are gone.

---

## Take-Home Assignment

1. Build a simple one-page website about yourself (name, skills, this
   course) and host it on S3 as a static site.
2. Enable versioning, update the page, confirm you can restore the previous
   version.
3. Add a lifecycle rule of your choice — screenshot the rule summary as
   `screenshots/takehome-lifecycle.png`.
4. Screenshot the live website in a browser as
   `screenshots/takehome-live.png`, and the version history as
   `screenshots/takehome-versions.png`. Then decide: keep the site up (it's
   nearly free) or tear it down.
5. Submit your screenshots (and the live URL if you keep it) per the
   course's usual submission channel.
