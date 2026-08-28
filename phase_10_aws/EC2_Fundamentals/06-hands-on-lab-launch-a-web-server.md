# Session 4e · Hands-On Lab — Launch a Web Server

You will launch a real server, turn it into a web page, log into it, then shut it down.

## Exercise 1: Launch a Server

Start a small free-tier Linux server. Make sure you are in your normal Region first.

- [ ] **Open EC2** — top search bar, type "EC2", open it, then click Launch instance.
- [ ] **Name and image** — give it a name, and pick Amazon Linux as the operating system image.
- [ ] **Size** — choose the `t3.micro` instance type (it's marked Free Tier eligible).
- [ ] **Key pair** — click Create new key pair, name it, download the `.pem` file, keep it safe.
- [ ] **Firewall** — under Network settings, tick Allow SSH from My IP and Allow HTTP from
  anywhere.
- [ ] **Launch** — click Launch instance, then wait for the state to become Running.

The `.pem` key downloads only once. Keep it safe.

## Exercise 2: Turn It Into a Web Page

The official steps just say "paste the script" — but you'd rather build it than receive it, so
fill in the blanks yourself first.

```bash
#!/bin/bash
______ update -y
______ install -y httpd
systemctl ______ httpd
echo "Hello from Qiyas!" > /var/www/html/index.html
```

Which command manages packages on Amazon Linux, and which `systemctl` subcommand starts a
service right now (not on every future boot — that's a different subcommand, see 4d)?

<details>
<summary>Check your answer here — only after you've tried it</summary>

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "Hello from Qiyas!" > /var/www/html/index.html
```

</details>

- [ ] **Find User Data** — during launch, open Advanced details, scroll to the User data box.
- [ ] **Paste your completed script.**
- [ ] **Copy the address** — on the instance page, copy the Public IPv4 address.
- [ ] **Open it** — paste that address into a new browser tab. You should see your page load.
- [ ] **Celebrate** — that page is being served by a computer you just started in a data
  center.

No page loading? Check the HTTP firewall rule, and that you used the PUBLIC address.

## Exercise 3: Connect with SSH

- [ ] **Open a terminal** — on your laptop, go to the folder holding your `.pem` key.
- [ ] **Protect the key** — `chmod 400 your-key.pem` so the system will accept it.
- [ ] **Connect** — `ssh -i your-key.pem ec2-user@ADDRESS`, using your Public IPv4 address.
- [ ] **Say yes** — the first time it asks to trust the server, type `yes` and press Enter.
- [ ] **Look around** — run `whoami` and `df -h`. You are now inside a server in a data center.

`ec2-user` is the login name for Amazon Linux.

## Exercise 4: Clean Up

A running server costs money. Shut it down properly before you leave. **This step is
required.**

- [ ] **Select it** — in EC2, go to Instances, tick the checkbox next to your instance.
- [ ] **Instance state** — open the Instance state menu at the top right.
- [ ] **Terminate** — click Terminate (delete) instance, then confirm in the pop-up.
- [ ] **Watch it go** — the state moves to Shutting-down, then Terminated. It is gone for good.
- [ ] **Confirm clean** — make sure you have no other Running instances left behind.

Stop keeps the disk. Terminate deletes it. Today, terminate.

## When SSH Won't Connect

The three usual suspects, in the order to check them:

| Error | Cause |
|---|---|
| **Connection times out** | Security group is not allowing SSH (port 22) from your IP. Fix the inbound rule. Also check the instance is Running and you used the PUBLIC IP. |
| **Permission denied (publickey)** | Wrong username (try `ec2-user` for Amazon Linux, `ubuntu` for Ubuntu), or wrong key file. |
| **Unprotected private key** | SSH refuses a world-readable key. Run `chmod 400 key.pem` and try again. |

## Lab Reference: Commands

```bash
chmod 400 qiyas-key.pem                                                          # protect your private key
ssh -i qiyas-key.pem ec2-user@<public-ip>                                        # connect to the instance
uname -a                                                                          # what OS and kernel am I on?
df -h                                                                             # how much disk space?
whoami                                                                            # which user am I?
aws ec2 describe-instances --query "Reservations[].Instances[].State.Name"       # list instance states
```

## Staying Inside Free Tier

- **Use `t3.micro` or `t2.micro`** — Free Tier includes 750 hours/month of a micro instance for
  the first 12 months. One instance running all month fits.
- **One instance at a time** — two micros running together burn 2x the hours. For labs, one is
  plenty.
- **Terminate after every lab** — the safest habit. A terminated instance cannot bill you.
- **Set a billing alert** — a budget alarm at a few dollars emails you before a mistake becomes
  expensive. We'll set one up formally later.

## Take-Home Assignment: A Self-Building Web Server

1. Launch a fresh `t3.micro`. In User Data, install a web server **and** write a page showing
   your name and the instance's Region.
2. **Do NOT SSH in to fix the page** — it must work from User Data alone. This is the real
   skill being tested: automation over manual setup.
3. Open the public IP in a browser and screenshot the working page.
4. Terminate the instance and screenshot the empty console. Both screenshots required.

**Submit** both screenshots via the Google Form or the Telegram group, before the next session.

Getting the Region into the page yourself (rather than hardcoding it) is worth sitting with —
it's the same instance metadata mechanism you'll lean on constantly once you reach Auto Scaling
and Terraform, so it's worth figuring out on your own before I hand you the exact command.

## Talk It Through

Five minutes with your peers, or with yourself before next session:

1. Your web app suddenly needs to handle 10x traffic for one day. What's the cloud advantage
   over owning a physical server?
2. Why is opening SSH to `0.0.0.0/0` dangerous? What should you use instead?
3. You stopped an instance to save money but the bill didn't drop to zero. Why?
4. A teammate lost their `.pem` file and can't log in. What are their options?

## Where EC2 Shows Up in Real Jobs

- **Hosting applications** — web servers, APIs, and backend services run on EC2 (or containers
  built on it). The bread and butter of cloud work.
- **Bastion / jump hosts** — a small hardened instance you SSH into first, then reach private
  servers behind it. A pattern you'll build later.
- **Batch and processing** — spin up compute-heavy instances for a job (video encoding, data
  crunching), then terminate. Pay only for the run.
- **Dev and test boxes** — a disposable Linux machine in the cloud whenever you need one. Break
  it, delete it, launch a fresh one.

## You Can Now...

- Launch a Linux server in the cloud in minutes
- Read instance type names and pick the right family
- Wrap an instance in a security group firewall
- Connect over SSH with a key pair, and debug when it fails
- Automate setup with User Data
- Control cost with stop vs terminate

## Screenshots to Capture

1. Working web page at the public IP (Exercise 2)
2. `systemctl status httpd` or equivalent proof of a running service (Exercise 3)
3. Take-home: working self-built page showing name + Region
4. Take-home: empty console after termination

## Coming Up: Session 5 — EC2 Pricing & Storage

On-Demand, Spot, and Reserved pricing, plus the disks that hold your data: EBS, snapshots, and
S3 basics. Bring your laptop, admin login, and the Session 4 take-home submitted.
