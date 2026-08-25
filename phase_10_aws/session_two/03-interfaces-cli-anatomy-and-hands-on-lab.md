# Session 2c · Interfaces, CLI Anatomy & Hands-On Lab

## Three Ways to Talk to AWS

Same AWS underneath — three different doors in.

| Interface | What it is | Best for |
|---|---|---|
| **Console** | Point-and-click web UI | Learning & exploring |
| **CLI** | Type commands | Daily ops & scripts |
| **SDK** | Write code (Python, JS, Java, etc.) | Apps & automation |

## The Console: Two Habits, One Trap

- **Habit 1 — search everything.** `Alt+S` or the search bar. Typing "EC2" beats hunting
  through 200+ services in menus.
- **Habit 2 — check your Region, always.** The Region selector lives top-right. Every
  regional resource you create lands in whatever Region is selected there.


## Anatomy of a CLI Command

```
aws ec2 describe-instances --region us-east-2
 │    │        │                  │
 │    │        │                  └─ options
 │    │        └─ operation
 │    └─ service
 └─ program
```

| Flag | Purpose |
|---|---|
| `--region` | Run this one command against another Region |
| `--profile` | Use a different set of credentials |
| `--output` | Format results as `json`, `table`, or `text` |

## Taming the Output: `--query`

CLI responses are walls of JSON. `--query` (using a language called **JMESPath**) extracts
exactly what you need — you don't need to master JMESPath, just recognize the pattern and
adapt examples:

```bash
aws ec2 describe-regions
# hundreds of lines of JSON...

aws ec2 describe-regions --query "Regions[].RegionName"
# just the region names

aws ec2 describe-regions --query "Regions[?contains(RegionName,'eu')]"
# only the European regions
```

## CloudShell — A Terminal In Your Browser

Free, built into the Console, CLI pre-installed and already authenticated as whoever's
signed in. Zero setup, works from any machine that can open the Console. Great for quick
checks; your local CLI still wins for long scripts, your own tools, and offline work.

---

## Key Terms

- **JMESPath** — the query language behind AWS CLI's `--query` flag
- **CloudShell** — a browser-based terminal built into the AWS Console, pre-authenticated

