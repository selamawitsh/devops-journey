# Session 07 (5/5): Hands-On Lab — Run a Container on Fargate

Run a container on Fargate with no server to manage, put it behind a load
balancer, then scale it. 

---

## Exercise 1: Make a Cluster

A cluster is just a named home for your containers — on Fargate, one with zero
servers to manage.

1. Open ECS in the console, click **Clusters**, click **Create cluster**.
2. Name the cluster: `_______`
3. Under Infrastructure, tick: `_______` (leave EC2 unticked)
4. Notice what's missing from this screen compared to an EC2-backed cluster —
   write one sentence on why that blank space is the entire point of Fargate:
   `_______________________________________________`
5. Click Create.

<details>
<summary>Answer</summary>

- Cluster name: `qiyas-cluster`
- Infrastructure: **AWS Fargate (serverless)**
- What's missing: no server size, no instance count, nothing to launch —
  because Fargate provisions the capacity per task on demand, there is no
  capacity decision for you to make up front.

</details>

**Screenshot:** `screenshots/01-cluster-created.png` — the cluster detail page
right after creation.

---

## Exercise 2: Write the Task Definition

The blueprint: which image, how much CPU/memory, which port.

1. In ECS, left menu, click **Task definitions**, then **Create new task
   definition**.
2. Name: `_______`
3. Launch type: `_______`
4. CPU: `_______` vCPU — Memory: `_______` GB (small is fine for a demo)
5. Container name: `_______` — Image: `_______` (a ready-made public web
   server)
6. Container port: `_______`
7. Click Create.

<details>
<summary>Answer</summary>

- Name: `web-task`
- Launch type: **AWS Fargate**
- CPU: `0.25 vCPU` — Memory: `0.5 GB`
- Container name: `web` — Image: `nginx`
- Container port: `80`

</details>

**Screenshot:** `screenshots/02-task-definition.png` — the created task
definition showing image and port.

---

## Exercise 3: Run a Service

A service keeps the right number of copies running — the ECS equivalent of an
Auto Scaling Group, but for containers.

1. Open your cluster, **Services** tab, click **Create**.
2. Launch type: `_______` — Task definition: `_______`
3. Service name: `_______` — Desired tasks: `_______`
4. Under Load balancing, create an **Application Load Balancer**, target
   port: `_______`
5. Click Create, wait until both tasks show **Running** and targets are
   healthy.
6. Open the load balancer's DNS name in a browser, refresh a few times.

<details>
<summary>Answer</summary>

- Launch type: **Fargate** — Task definition: `web-task`
- Service name: `web` — Desired tasks: `2`
- Target port: `80`
- Refreshing hits different tasks behind the same ALB — that's the load
  balancer rotating across your 2 running containers.

</details>

**Screenshot:** `screenshots/03-service-running.png` — both tasks Running,
targets healthy, plus a screenshot of the working page served through the
load balancer DNS name.

---

## Exercise 4: Scale, Then Clean Up

Feel the container speed advantage, then tear down in the correct order.

1. Open the `web` service, click Update, change Desired tasks from 2 to
   `_______`, Update.
2. New tasks reach Running in `_______` (seconds/minutes) — compare that to
   how long an EC2 instance takes to boot.
3. Update the service again, set Desired tasks to `_______`. This is the
   **safe first teardown step** — write one sentence on why this has to happen
   before deleting the service:
   `_______________________________________________`
4. Once no tasks are running, delete the `_______`.
5. Delete `_______` and its load balancer. Confirm nothing is left running.

<details>
<summary>Answer</summary>

1. Scale to `4`.
2. Seconds — no OS boot, just process start.
3. Set desired count to `0` first. If you delete the service while tasks are
   still desired, the service just relaunches them out from under the
   deletion — same failure mode as an ASG relaunching instances during a
   teardown, just for containers instead of EC2s.
4. Delete the **web service**.
5. Delete **qiyas-cluster** and its load balancer.

</details>

**Screenshot:** `screenshots/04-scaled-to-4.png` — the tasks list showing 4
Running tasks, timestamped close together to show how fast they started.

CLI reference for steps 1 and 3, if you'd rather script it than click through
the console:

```
aws ecs update-service --cluster _______ --service _______ --desired-count 4
aws ecs update-service --cluster _______ --service _______ --desired-count 0
```

<details>
<summary>Answer</summary>

```
aws ecs update-service --cluster qiyas-cluster --service web --desired-count 4
aws ecs update-service --cluster qiyas-cluster --service web --desired-count 0
```

</details>

---

## Take-Home Assignment

1. Rebuild the Fargate service from scratch: cluster + task definition +
   service, 2 tasks behind a load balancer.
2. Confirm the load balancer serves your container — screenshot the working
   page as `screenshots/takehome-lb-working.png`.
3. Scale the service to 4 tasks, screenshot the tasks list as
   `screenshots/takehome-scaled-4.png`.
4. Write 3 sentences in `reflection.md` in this folder: what did Fargate
   handle for you that you had to do yourself with plain EC2 in the last
   pillar? Then tear everything down (desired count to 0, delete service,
   delete cluster).
5. Submit your screenshots and `reflection.md` per the course's usual
   submission channel.
