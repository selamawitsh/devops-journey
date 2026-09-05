# Hands-On Lab: Build Your Own Network

Goal: build a VPC from scratch, give it a public and a private subnet, wire
the front gate, launch a reachable server, then prove the private subnet is
closed and clean everything up.

Screenshots for each step go in `screenshots/` next to this file.

Fill in each blank yourself before checking the hidden answer. Don't peek
first — the point is to build it, not copy it.

---

## Exercise 1: Create a VPC

1. Open the VPC service, click **Create VPC**.
2. Choose **______** (not the wizard), so you build each piece yourself.
3. Name it `______`.
4. Set the IPv4 CIDR to `______` — about 65,000 private addresses.
5. Click Create VPC.

<details>
<summary>Check your answers</summary>

- Step 2: VPC only
- Step 3: qiyas-vpc
- Step 4: 10.0.0.0/16

</details>

---

## Exercise 2: Add Two Subnets

1. In the VPC console, click **Subnets**, then **Create subnet**.
2. Pick VPC: `______`.
3. Public subnet: name it `______`, pick an AZ, CIDR `______`.
4. Add another subnet: name it `______`, same AZ, CIDR `______`.
5. Click Create subnet. At this point, are both subnets public, private, or
   something else? ______
6. Select the public subnet → Actions → Edit subnet settings → tick
   **______** → Save.

<details>
<summary>Check your answers</summary>

- Step 2: qiyas-vpc
- Step 3: qiyas-public, 10.0.1.0/24
- Step 4: qiyas-private, 10.0.2.0/24
- Step 5: Both are still effectively private — naming does nothing until the
  route table is wired.
- Step 6: Enable auto-assign public IPv4

</details>

---

## Exercise 3: Wire the Front Gate

1. Left menu → **______** → Create → name it `______` → Create.
2. Select it → Actions → **______** → choose your VPC.
3. Left menu → **Route tables**. Find (or create) the table for the public
   subnet.
4. Edit routes → Add route: Destination `______`, Target: your internet
   gateway.
5. On **Subnet associations**, associate `______` with this route table.
6. What's different about qiyas-private now compared to qiyas-public?
   ______

<details>
<summary>Check your answers</summary>

- Step 1: Internet gateways, qiyas-igw
- Step 2: Attach to VPC
- Step 4: 0.0.0.0/0
- Step 5: qiyas-public
- Step 6: qiyas-private has no route to the IGW, so it cannot reach or be
  reached by the internet — that route table difference is the entire
  public/private distinction.

</details>

---

## Exercise 4: Launch, Test, Clean Up

1. Launch a small Amazon Linux instance. Set Network to `______` and subnet
   to `______`.
2. Security group: allow **______** port **______** from anywhere. Add User
   Data that installs a web server.
3. Open the instance's public IP in a browser. What should happen? ______
4. If you launched an instance into qiyas-private instead, what would you
   expect? ______
5. Clean-up order: terminate the instance, then ______, then delete
   subnets, then ______.

<details>
<summary>Check your answers</summary>

- Step 1: qiyas-vpc, qiyas-public
- Step 2: HTTP, port 80
- Step 3: The web page loads — the instance is reachable from the internet.
- Step 4: No public IP would be assigned, and it would be unreachable from
  outside the VPC.
- Step 5: detach and delete the internet gateway → delete the VPC

</details>

---

## Troubleshooting Checklist — "It Can't Connect"

Fill in the cause for each symptom, in the order you'd actually check them:

| Order | Symptom | Cause |
|---|---|---|
| 1 | Nothing in the subnet reaches the internet at all | ______ |
| 2 | Instance is in the right subnet but browser can't reach its IP | ______ |
| 3 | Route table and public IP both look correct, still unreachable | ______ |
| 4 | Instance is completely unreachable, even though everything else looks right | ______ |

<details>
<summary>Check your answers</summary>

1. No route to the IGW — the subnet is really private regardless of its name.
2. No public IP — auto-assign public IPv4 was off.
3. Security group closed — the required port isn't open from your source.
   (This is called out as the #1 cause across the whole course.)
4. Wrong subnet — the instance was launched into the private subnet by
   mistake.

</details>

---

## Take-Home Assignment: Add a Second Availability Zone

1. Reuse `qiyas-vpc` and add a **second public subnet** in a **different AZ**
   (e.g. `10.0.3.0/24`).
2. Associate the new subnet with the existing public route table so it also
   reaches the internet gateway.
3. In two sentences, explain why two public subnets in two AZs matter for a
   load balancer (callback to the Auto Scaling & Load Balancing session).
4. Screenshot the route table showing both public subnets associated.

Submit the route-table screenshot per the course's usual submission channel
before the next session.

<details>
<summary>Check your reasoning for step 3</summary>

A load balancer spread across two AZs keeps the app reachable even if one
entire data center (AZ) has an outage — traffic simply shifts to the
healthy AZ. A load balancer with only one public subnet has a single point
of failure at the AZ level, no matter how well the rest of the architecture
is built.

</details>
