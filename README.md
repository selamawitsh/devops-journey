# DevOps Engineering Journey

Prepared for: **Selamawit**
A structured, hands-on path from Linux fundamentals to production-grade DevOps — Intern to Mid-Level, one topic at a time, every topic turned into a real project.

---

## Table of Contents

- [DevOps Engineering Journey](#devops-engineering-journey)
  - [Table of Contents](#table-of-contents)
  - [Why this repo exists](#why-this-repo-exists)
  - [How this roadmap works](#how-this-roadmap-works)
  - [Progress tracker](#progress-tracker)
  - [Repo structure](#repo-structure)
  - [Phase 1 — Linux Administration (`linux_adminstration/`)](#phase-1--linux-administration-linux_adminstration)
  - [Phase 2 — Networking (`networking/`)](#phase-2--networking-networking)
  - [Environment](#environment)
  - [Full 18-phase roadmap (reference)](#full-18-phase-roadmap-reference)

---

## Why this repo exists

This isn't a collection of tutorial notes. Every phase follows the same rule: **learn a topic, then build something with it that proves you understand it** — not a toy exercise, something closer to what actually breaks in production. Each folder documents the architecture, the exact commands run, screenshots, lessons learned, and what I'd improve next time.

**End goal:** Junior DevOps Engineer interview readiness, backed by a GitHub history that shows real, hands-on engineering — not just completed checkboxes.

---

## How this roadmap works

- **Work top to bottom.** A phase's project doesn't start until every topic's hands-on lab in that phase is done.
- **Commit per topic, not per project.** Small, real, incremental commits — not one giant "final commit" at the end. Aim for several meaningful commits per study session, each tied to one file or one concept.
- **Every topic folder gets:** a `README.md`, a `notes.md`, a `practice.md` with real captured command output, a `challenge.md` + worked `ChallengeAndAnswer.md`, and (where relevant) a `scripts/` folder for anything automated.
- **Documentation is the actual product.** A stack of scripts is not a portfolio. A stack of scripts with a clear README explaining *why* each decision was made is.
- **`resources.md`** at the repo root tracks reference links, articles, and docs used along the way — keep it updated as you go so it doubles as a citations list.

---

## Progress tracker

| # | Phase | Topic folder | Status |
|---|---|---|---|---|
| 01a | Linux — Fundamentals | `linux_adminstration/linux-fundamentals` | Not started |
| 01b | Linux — User & Group Management | `linux_adminstration/user-group-management` | Not started |
| 01c | Linux — Package Management | `linux_adminstration/package-management` | In progress |
| 01d | Linux — SSH & Remote Access | `linux_adminstration/ssh-remote-access` | Not started |
| 01e | Linux — Web Services (Apache/Nginx basics) | `linux_adminstration/web-services` | Not started |
| 01f | Linux — Final Practices (capstone) | `linux_adminstration/final_practices` | Not started |
| 02 | Networking — TCP/IP Fundamentals | `networking/01-tcp-ip-fundamentals` | In progress |
| 03 | Git | `git-mastery` | Not started |
| 04 | Bash | `bash-scripting` | Not started |
| 05 | Go (Automation & Scripting) | `go-automation` | Not started |
| 06 | Docker | `docker-labs` | Not started |
| 07 | Docker Compose | `docker-compose-projects` | Not started |
| 08 | CI/CD | `github-actions` | Not started |
| 09 | Nginx (reverse proxy deep dive) | `nginx-reverse-proxy` | Not started |
| 10 | AWS | `aws-projects` | Not started |
| 11 | Terraform | `terraform-zero-to-hero` | Not started |
| 12 | Ansible | `ansible-labs` | Not started |
| 13 | Kubernetes | `kubernetes-labs` | Not started |
| 14 | Helm | `kubernetes-labs` | Not started |
| 15 | Monitoring | `prometheus-grafana` | Not started |
| 16 | Logging | `prometheus-grafana` | Not started |
| 17 | Security | `production-projects` | Not started |
| 18 | Production DevOps (Capstone) | `production-projects` | Not started |

*Update the Status column as you go — this table is the first thing anyone browsing the repo actually reads, including a hiring manager.*

---

## Repo structure

```
devops-journey/
├── README.md                          # you are here
├── resources.md                       # reference links, docs, articles used throughout
│
├── linux_adminstration/               # Phase 1 — Linux
│   ├── linux-fundamentals/            # filesystem, processes, disk/storage, text processing, cron, boot
│   │   ├── README.md
│   │   ├── notes.md
│   │   ├── practice.md
│   │   ├── challenge.md
│   │   ├── ChallengeAndAnswer.md
│   │   └── scripts/
│   │
│   ├── user-group-management/         # UID/GID, permissions, sudoers, SUID/SGID/sticky bit
│   │   ├── README.md
│   │   ├── notes.md
│   │   ├── practice.md
│   │   ├── challenge.md
│   │   └── ChallengeAndAnswer.md
│   │
│   ├── package-management/            # dpkg/apt, dependency resolution, holds/pins, repos & GPG
│   │   ├── README.md
│   │   ├── notes.md
│   │   ├── practice.md
│   │   ├── challenge.md
│   │   ├── ChallengeAndAnswer.md
│   │   ├── scripts/
│   │   │   └── bootstrap.sh
│   │   └── screenshots/
│   │
│   ├── ssh-remote-access/             # SSH config, key auth, tunneling, bastion basics
│   │   ├── README.md
│   │   ├── notes.md
│   │   ├── practice.md
│   │   ├── challenge.md
│   │   └── ChallengeAndAnswer.md
│   │
│   ├── web-services/                  # Apache2 VirtualHosts, .htaccess, Nginx intro
│   │   ├── README.md
│   │   ├── notes.md
│   │   ├── practice.md
│   │   ├── challenge.md
│   │   └── ChallengeAndAnswer.md
│   │
│   └── final_practices/               # Phase 1 capstone — combines every topic above
│       ├── README.md
│       ├── notes.md
│       └── screenshots/
│
└── networking/                        # Phase 2 — Networking
    └── 01-tcp-ip-fundamentals/        # OSI vs TCP/IP model, encapsulation, layer diagnosis
        ├── README.md
        ├── notes.md
        ├── practice.md
        └── challenge.md
```

Every topic folder follows the same pattern:

| File | Purpose |
|---|---|
| `README.md` | What the topic covers, why it matters, the project deliverable |
| `notes.md` | Theory in my own words, with a "why this matters for DevOps" angle |
| `practice.md` | The exact hands-on commands run, with real captured output (not paraphrased) |
| `challenge.md` | A deliberate break-things exercise — the prompt only |
| `ChallengeAndAnswer.md` | The worked diagnosis, the fix, and the lesson learned |
| `scripts/` | Any script written as the topic's project deliverable |
| `screenshots/` | Terminal output / diagrams supporting the exercises above |

---

## Phase 1 — Linux Administration (`linux_adminstration/`)

*Every CI runner, Docker host, and Kubernetes node is Linux underneath — this phase is the foundation everything else stands on.*

| Topic folder | Covers | Status |
|---|---|---|
| `linux-fundamentals/` | Filesystem hierarchy, navigation, process management, disk & storage, text processing (grep/sed/awk), cron & scheduled tasks, boot process & troubleshooting | Not started |
| `user-group-management/` | UID/GID, `/etc/passwd` & `/etc/shadow`, `chmod`/`chown`, `sudo`/`sudoers`, SUID/SGID/sticky bit | Not started |
| `package-management/` | `dpkg` vs `apt`, dependency resolution, held/pinned packages, adding repos + GPG keys |  **In progress** |
| `ssh-remote-access/` | SSH key auth, config hardening, tunneling, port forwarding, bastion/jump-host basics | Not started |
| `web-services/` | Apache2 MPMs, VirtualHosts, `.htaccess`, `mod_rewrite`/`mod_ssl`, Nginx architecture intro | Not started |
| `final_practices/` | Capstone: combine filesystem, permissions, package management, SSH, and web services into one scenario-driven lab | Not started |

**Currently on:** `package-management` — `dpkg` vs `apt`, dependency resolution, holds vs pins, repos & GPG key verification.

## Phase 2 — Networking (`networking/`)

*You cannot debug what you cannot see moving across the wire.*

| Topic folder | Covers | Status |
|---|---|---|
| `01-tcp-ip-fundamentals/` | OSI vs TCP/IP model, encapsulation, layer-based failure diagnosis | ** In progress** |

**Currently on:** `01-tcp-ip-fundamentals` — OSI vs TCP/IP model, encapsulation, mapping real failures to the layer that broke.

---

## Environment

- **OS:** Ubuntu (VMware VM)
- **Skill level:** Beginner → Intermediate, working toward Junior DevOps Engineer readiness


---

## Full 18-phase roadmap (reference)

<details>
<summary>Click to expand the complete phase list</summary>

1. **Linux** 
2. **Networking** 
3. **Git** — `git-mastery` 
4. **Bash** — `bash-scripting` 
5. **Go (Automation & Scripting)** — `go-automation` 
6. **Docker** — `docker-labs` 
7. **Docker Compose** — `docker-compose-projects` 
8. **CI/CD** — `github-actions` 
9. **Nginx** — `nginx-reverse-proxy` 
10. **AWS** — `aws-projects`  to Mid
11. **Terraform** — `terraform-zero-to-hero` 
12. **Ansible** — `ansible-labs` 
13. **Kubernetes** — `kubernetes-labs` 
14. **Helm** — `kubernetes-labs` 
15. **Monitoring** — `prometheus-grafana` 
16. **Logging** — `prometheus-grafana` 
17. **Security** — `production-projects` 
18. **Production DevOps (Capstone)** — `production-projects` 

</details>

---
