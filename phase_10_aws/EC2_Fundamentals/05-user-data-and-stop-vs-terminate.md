# Session 4d · User Data & Stop vs Terminate

## User Data — Scripts That Run at Boot

Want software installed the moment an instance starts? Paste a script into User Data. It runs
**once**, automatically, at first boot — no SSH needed to set up a web server.

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
echo "Hello from Qiyas!" > /var/www/html/index.html
```

Worth knowing beyond today's script: `systemctl start httpd` starts the service right now, but
doesn't survive a reboot on its own — a separate `systemctl enable httpd` is what makes it
start automatically on every future boot. They're different verbs for a reason, and people
conflate them constantly. Today's lab script only needs `start`, since we're terminating the
instance anyway rather than rebooting it.

### Real-World Pattern

This is exactly what **Auto Scaling Groups** use to bring up identical servers automatically as
traffic grows — the fleet scales out, and every new instance boots already configured, with no
human involved. This is your first real building block toward Infrastructure as Code — later,
Terraform and CloudFormation will template this same idea instead of you typing it by hand.

## Stop vs Terminate: Know the Difference

| State | Billing | Data |
|---|---|---|
| **Running** | Fully billed for compute | Live, reachable |
| **Stopped** | Compute charge stops; you still pay a little for the EBS disk | Kept — can start again anytime |
| **Terminated** | Nothing | Gone forever — the instance and (by default) its root disk are deleted |

Terminate after every lab — the safest habit, since a terminated instance genuinely cannot bill
you.

### The Gotcha: "Delete on Termination"

Worth knowing beyond today's slides: the root EBS volume has a checkbox at launch, **Delete on
Termination**. If it's left unchecked and you terminate the instance, the volume survives —
orphaned, unattached, and still quietly billing every month. This is a real, common source of
AWS bill surprises at companies with sloppy cleanup habits: dozens of orphaned volumes nobody
remembers creating.

## Common Mistakes

- Assuming Stop is "fully free" — storage keeps billing even while stopped.
- Expecting User Data to rerun after every reboot — it only ever runs on the instance's *first*
  boot, never again.
- Terminating without checking Delete on Termination, then wondering where the extra EBS charge
  came from a month later.

## Key Terms

- **User Data** — a script that runs once, automatically, at an instance's first boot
- **Stop** — compute billing pauses, storage billing continues, data kept
- **Terminate** — instance and (by default) its root volume are deleted permanently
- **Delete on Termination** — the flag controlling whether the root EBS volume survives termination
