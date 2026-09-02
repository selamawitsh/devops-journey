# Session 06 (5/5): Hands-On Lab — Build a Self-Healing App

Build an app that survives a server dying: a launch template, a load
balancer, and a self-healing group — then kill a server on purpose and watch
it come back. Screenshots go in `screenshots/` in this repo (folder already
created) — name them as noted at the end of each exercise.

---

## Exercise 1: Make the Blueprint

A launch template is the recipe every server is built from. Nothing runs yet
— that's the group's job later.

1. In EC2, left menu, **Launch templates**, then **Create launch template**.
2. Name it: `_______`
3. Image: `_______` — Instance type: `_______`
4. Choose your key pair, and a security group that allows `_______` from
   anywhere.
5. Under Advanced details, paste the User Data script that installs a web
   server and shows the instance's own ID — why does the script specifically
   need to print the instance ID, and not just "hello world"?
   `_______________________________________________`
6. Click Create.

<details>
<summary>Answer</summary>

- Name: `web-blueprint`
- Image: **Amazon Linux** — Instance type: `t3.micro`
- Security group: allow **HTTP** from anywhere
- Why the instance ID matters: without it, every server would show an
  identical page, so refreshing against the load balancer later would give no
  visible proof that traffic is actually rotating between different servers.

</details>

**Screenshot:** `screenshots/01-launch-template.png` — the created launch
template.

---

## Exercise 2: Add a Load Balancer

An ALB spreads visitors across servers and only sends them to healthy ones.
The target group will sit empty after this exercise — that's expected, the
group fills it next.

1. In EC2, **Load Balancers**, Create, choose `_______`.
2. Name it: `_______` — scheme: `_______` — select `_______` Availability
   Zones.
3. Create a target group named `_______`, health check path: `_______`.
4. Back on the ALB, select that target group as the listener target, on port
   `_______`.
5. Create, wait for state **Active**, copy the `_______`.

<details>
<summary>Answer</summary>

- Type: **Application Load Balancer**
- Name: `web-alb` — scheme: **Internet-facing** — select **two** AZs
- Target group name: `web-targets` — health check path: `/`
- Listener port: `80`
- Copy the **DNS name** — this is the single stable address every visitor
  will use.

</details>

**Screenshot:** `screenshots/02-alb-active.png` — the load balancer showing
state Active.

---

## Exercise 3: Build the Group

The ASG keeps the right number of servers running and rotates traffic across
them.

1. In EC2, **Auto Scaling Groups**, Create, name it `_______`.
2. Choose the `_______` launch template.
3. Select the same `_______` as your load balancer.
4. Attach to an existing load balancer, tick `_______`, turn on its health
   checks.
5. Set Desired `_______`, Minimum `_______`, Maximum `_______`.
6. Open the ALB DNS name and refresh a few times — what should you see
   change on the page, and what does that prove?
   `_______________________________________________`

<details>
<summary>Answer</summary>

- Name: `web-asg`
- Launch template: `web-blueprint`
- Same **two Availability Zones** as the load balancer
- Target group: `web-targets`
- Desired `2`, Minimum `2`, Maximum `4`
- The **instance ID on the page changes** between refreshes — proof the load
  balancer is actually spreading traffic across two different real servers,
  not just showing you the same one every time.

</details>

**Screenshot:** `screenshots/03-instance-rotation.png` — two separate
screenshots (or one composite) of the page showing two different instance
IDs from refreshing the same ALB DNS name.

---

## Exercise 4: Break It, Watch It Heal

Kill a server on purpose. The group should notice and replace it while the
site stays up.

1. In Instances, note the two running servers and their IDs.
2. Select one, Instance state, `_______`. You just caused an outage on
   purpose.
3. Keep refreshing the ALB DNS name — what do you expect to happen to the
   site while one server is down?
   `_______________________________________________`
4. In Auto Scaling Groups, watch `_______` launch a replacement.
5. Confirm you're back to `_______` healthy servers within a couple of
   minutes.

<details>
<summary>Answer</summary>

- Action: **Terminate**
- The site **stays up**, served entirely by the surviving instance — this is
  the exact opposite of a single-server setup, where terminating the only
  server means the site is just gone.
- `web-asg` launches a replacement automatically.
- Back to **2** healthy servers.

</details>

**Screenshot:** `screenshots/04-asg-activity-history.png` — the ASG's
Activity tab showing the terminate event and the new instance launching to
replace it.

---

## Cleanup: Order Matters

If you terminate instances while the ASG is still active, it just launches
replacements — you cannot win that fight by deleting instances first.

1. Delete the `_______` first (this terminates its instances for good).
2. Delete the `_______` and its target group.
3. Delete the `_______`.
4. Confirm the EC2 console is empty — no lingering instances.

<details>
<summary>Answer</summary>

1. **Auto Scaling Group** — deleting this is what actually stops replacements
   from happening.
2. **Load Balancer**
3. **Launch template**

</details>

---

## Take-Home Assignment

1. Rebuild the load-balanced Auto Scaling setup: launch template + ALB + ASG,
   min 2 / max 4.
2. Confirm the load balancer rotates between instances — screenshot two
   different instance IDs from the same LB address, save as
   `screenshots/takehome-rotation.png`.
3. Terminate one instance and capture the ASG launching a replacement —
   screenshot the Activity history as `screenshots/takehome-heal.png`.
4. Write 3 sentences in `reflection.md` in this folder: what would happen to
   your app if a whole Availability Zone went down? Then tear everything
   down in the correct order.
5. Submit your screenshots and `reflection.md` per the course's usual
   submission channel.
