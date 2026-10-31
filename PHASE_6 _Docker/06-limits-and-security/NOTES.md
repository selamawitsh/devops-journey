# Resource Limits and Container Security: My Notes

Written from zero. Read top to bottom the first time.

## Contents

1. The problem
2. Two kinds of protection
3. How limits work (cgroups)
4. Memory limits
5. Exit code 137 and OOMKilled
6. CPU limits
7. Memory vs CPU
8. Process limit
9. Watching usage: docker stats
10. Who am I inside the container? (root vs non-root)
11. Read-only filesystem and tmpfs
12. Capabilities
13. no-new-privileges
14. Things I must never do
15. The hardened container (everything combined)
16. Checklist
17. Self-test

---

## 1. The problem

By default a container is **not limited** and it **runs as root**.

```
 DEFAULT container                      what can go wrong
┌─────────────────────────────┐
│ no memory limit             │  ──►  one greedy container eats ALL my RAM,
│ no CPU limit                │       and my databases and services suffer
│ no process limit            │  ──►  a "fork bomb" can freeze the machine
│ runs as root                │
│ can write anywhere          │  ──►  an attacker who breaks in has lots of power
│ ~14 root powers             │
└─────────────────────────────┘
```

My laptop proved it: a container with no `--memory` showed a "limit" of
`15.37GiB`, which is **all the RAM in the machine**.

---

## 2. Two kinds of protection

```
 ┌───────────────────────────────┐   ┌───────────────────────────────┐
 │ RESOURCE LIMITS               │   │ SECURITY HARDENING            │
 │ "how MUCH can it use?"        │   │ "what can it DO?"             │
 │                               │   │                               │
 │  --memory   RAM               │   │  --user        who am I       │
 │  --cpus     CPU time          │   │  --read-only   what I can edit│
 │  --pids-limit  processes      │   │  --cap-drop    root's powers  │
 │                               │   │  no-new-privileges            │
 └───────────────────────────────┘   └───────────────────────────────┘
        protects my MACHINE                 protects against ATTACKERS
```

One principle covers both: **least privilege**. Give a program only what it needs,
and nothing extra.

---

## 3. How limits work (cgroups)

From Lesson 1: a container is a normal Linux process in a locked room.

```
 namespaces  →  control what it can SEE
 cgroups     →  control what it can USE      ← limits live here
```

`docker run --memory 100m` simply tells Linux: "put this process in a cgroup with a
100 MB ceiling." Linux enforces it. Docker only passes the setting along.

---

## 4. Memory limits

```
docker run --rm --memory 100m --memory-swap 100m python:3.12-alpine python -c "..."
              │       │              │                 │                │
              │       │              │                 │                └ the program to run
              │       │              │                 └ the image
              │       │              └ memory + swap allowed in total
              │       └ --memory 100m = at most 100 MB of RAM
              └ delete the container when it finishes
```

- **Swap** is disk space used as slow extra memory. Setting `--memory-swap` equal to
  `--memory` means "no swap", so the container cannot cheat by using the disk.
- Units: `b`, `k`, `m`, `g` (`512m`, `2g`).

My experiment:

```
 limit 100 MB
 ├── used  20 MB  →  "used 20 MB, fine"          finished normally
 └── used 200 MB  →  (no message at all)         killed instantly, exit code 137
```

The kill is **silent**. There is no "out of memory" message in the terminal.

---

## 5. Exit code 137 and OOMKilled

Exit codes above 128 mean "killed by a signal":

```
 137 = 128 + 9    signal 9  = SIGKILL   forcibly killed, no warning
 143 = 128 + 15   signal 15 = SIGTERM   asked politely to stop (docker stop)
```

But `137` alone does **not** prove memory was the cause. `docker kill` also gives 137.
To prove it, ask Docker for the `OOMKilled` flag (OOM = Out Of Memory):

```
docker inspect oom-test --format '{{.State.OOMKilled}} {{.State.ExitCode}}'
       │          │         │          │                   │
       │          │         │          │                   └ the exit code
       │          │         │          └ was it killed for using too much memory?
       │          │         └ print only these fields, not the whole JSON
       │          └ the container to look at
       └ show details
```

My result: `true 137`.

```
 Exited (137)
      │
      ▼
 docker inspect NAME --format '{{.State.OOMKilled}}'
      │
      ├── true  ──► out of memory: raise the limit, or fix a memory leak in the app
      └── false ──► killed by something else (docker kill, a crash, the system)
```

> Do **not** use `--rm` when testing a crash. `--rm` deletes the container, and the
> evidence (`OOMKilled`) goes with it.

---

## 6. CPU limits

```
docker run -d --name cpu-hog --cpus 0.5 alpine:3.22 sh -c "while true; do :; done"
                                  │                  │       │
                                  │                  │       └ an endless loop doing nothing
                                  │                  │         (: is a command that does nothing)
                                  │                  └ run this shell command
                                  └ at most half of one CPU core
```

- `--cpus 1` is one full core, `--cpus 0.5` is half, `--cpus 2` is two cores.
- The loop wants 100% of a core. My `docker stats` showed about **51%**.
- The container was **not killed**. It was throttled: Docker made it wait its turn.

---

## 7. Memory vs CPU

```
 MEMORY is a SPACE:   100 MB of RAM cannot be "shared out over time".
                      If the program needs more and there is none, the only
                      choice is to kill something  →  OOMKilled, exit 137.

 CPU is TIME:         a busy process can simply wait.
                      Docker slows it down (throttling) and it keeps running.
```

| Limit | When the container goes over | Visible as |
|-------|------------------------------|------------|
| Memory | **Killed** | `Exited (137)`, `OOMKilled=true` |
| CPU | **Slowed down** | High latency, `CPU %` stuck at the cap |

> Space runs out. Time can be stretched.

---

## 8. Process limit

```
 --pids-limit 100       at most 100 processes inside the container
```

A **fork bomb** is a program that creates copies of itself until the machine freezes.
A process limit stops it at 100.

---

## 9. Watching usage: docker stats

```
docker stats --no-stream limited
   │      │      │          │
   │      │      │          └ the container
   │      │      └ print ONE snapshot and stop (without it, it updates live forever)
   │      └ stats = live CPU and memory use
   └ docker
```

Reading my output:

```
 CONTAINER ID  NAME     CPU %   MEM USAGE / LIMIT    MEM %   PIDS
 2be4acc28f29  limited  0.00%   7.766MiB / 128MiB    6.07%   9
```

| Column | Meaning |
|--------|---------|
| `MEM USAGE / LIMIT` | What it uses now, and the cap I set |
| `MEM %` | Usage as a share of the limit |
| `CPU %` | 100% = one full core, so 50% under `--cpus 0.5` means at the cap |
| `PIDS` | How many processes it has |

### How to choose a limit

```
 1. Run the app normally.
 2. Measure it with docker stats under real load.
 3. Set the limit with headroom above the measured peak.
```

- Too low: a healthy app is killed.
- Too high (or none): the limit protects nothing.

My Go app used 1.3 MB, so a 64 MB limit was very generous.

---

## 10. Who am I inside the container? (root vs non-root)

A container runs as **root (uid 0)** unless told otherwise.

```
docker run --rm alpine:3.22 id
                              │
                              └ id = print which user I am
```

```
 default:           uid=0(root)  groups: root, bin, daemon, sys, disk, adm, ...
 --user 1000:1000:  uid=1000     groups: 1000
```

```
 docker run --rm --user 1000:1000 alpine:3.22 id
                    │      │    │
                    │      │    └ group ID
                    │      └ user ID 1000 (an ordinary user)
                    └ run as this user instead of root
```

| Action | root | uid 1000 |
|--------|------|----------|
| Write to `/etc` | `written` | `Permission denied` |

### Why it matters

```
 attacker breaks into the app
        │
        ├── app runs as ROOT      ──►  attacker is root inside the container:
        │                              can change any file, install tools,
        │                              more ways to try to escape
        │
        └── app runs as NON-ROOT  ──►  attacker is a powerless user
```

### Two ways to run non-root

**1. At run time:** `docker run --user 1000:1000 ...`

**2. In the Dockerfile (better, it travels with the image):**

```dockerfile
FROM alpine:3.22
RUN adduser -D -u 1000 app        # create a normal user called "app"
USER app                          # everything after this runs as "app"
CMD ["./server"]
```

Or use a base image that is already non-root, like I did:

```dockerfile
FROM gcr.io/distroless/static-debian12:nonroot     # runs as user 65532
```

I checked my image with:

```
docker image inspect ghcr.io/selamawitsh/go-hello:1.0.0 --format '{{.Config.User}}'
```

Result: `65532` (not root).

---

## 11. Read-only filesystem and tmpfs

```
docker run --rm --read-only alpine:3.22 sh -c "echo test > /tmp/a.txt && echo written"
                 │
                 └ the container's whole filesystem becomes read-only
```

Result: `Read-only file system`. An attacker cannot drop a harmful file into it.

Many programs need **one** place to write temporary files. A **tmpfs** is a small
scratch folder kept in RAM and erased when the container stops:

```
docker run --rm --read-only --tmpfs /tmp alpine:3.22 sh -c "echo test > /tmp/a.txt && cat /tmp/a.txt"
                 │             │
                 │             └ a writable scratch folder at /tmp, in RAM
                 └ everything else stays read-only
```

Result: `test`.

```
 ┌──────────────────────────────────────┐
 │ container filesystem   READ-ONLY  🔒 │
 │   ┌────────────────────────────┐     │
 │   │ /tmp  (tmpfs, in RAM)  ✏   │     │   only this part can be written
 │   └────────────────────────────┘     │
 └──────────────────────────────────────┘
```

If the app must keep data, give it a **named volume** (Lab 04) for that one path.
Everything else stays read-only.

---

## 12. Capabilities

Root is not one giant power. Linux splits it into about **40 separate powers** called
**capabilities**, like keys on a key ring.

```
 root's key ring
 ┌──────────────────────────────────────────────────────────────┐
 │ 🔑 CHOWN             change who owns a file                  │
 │ 🔑 NET_BIND_SERVICE  use ports below 1024 (like 80)          │
 │ 🔑 NET_RAW           craft raw network packets               │
 │ 🔑 SETUID / SETGID   switch to another user or group         │
 │ 🔑 KILL              send signals to other processes         │
 │ 🔑 SYS_ADMIN         a huge "do almost anything" key  ⚠      │
 │ ... about 40 keys                                            │
 └──────────────────────────────────────────────────────────────┘

 Docker default:   gives a container about 14 of these keys
 --cap-drop ALL:   takes the whole key ring away
 --cap-add NAME:   gives back only the key the app really needs
```

### See it

```
docker run --rm alpine:3.22 grep CapEff /proc/self/status
                             │    │      │
                             │    │      └ a file where Linux describes the current process
                             │    └ CapEff = the powers this process has right now (hex)
                             └ search for that word
```

```
 default:          CapEff: 00000000a80425fb     some keys
 --cap-drop ALL:   CapEff: 0000000000000000     no keys
```

### Use it

```
 default:          chown 1000 /tmp   →  chown worked
 --cap-drop ALL:   chown 1000 /tmp   →  chown: /tmp: Operation not permitted
```

It is the **same user, still root**, but the key is gone.

### Two error messages that look alike

| Message | Meaning |
|---------|---------|
| `Permission denied` | A normal user hit a file-permission rule |
| `Operation not permitted` | Even root lacks the capability needed |

### Add back only what is needed

```
 docker run --cap-drop ALL --cap-add NET_BIND_SERVICE ...
                │                   │
                │                   └ give back ONE key (here: bind to port 80)
                └ start from nothing
```

Pattern: **drop ALL, then add only what the app proves it needs.**

---

## 13. no-new-privileges

```
 --security-opt no-new-privileges
```

A process can sometimes gain **more** power by running a special program (a "setuid"
binary). This flag says: **never**. Whatever power the process starts with is the
most it can ever have.

---

## 14. Things I must never do

| Never do this | Why |
|---------------|-----|
| `--privileged` | Gives the container almost all powers and access to the host's devices. It removes the walls. |
| `-v /var/run/docker.sock:/var/run/docker.sock` | The container can control Docker itself, which is the same as owning the whole machine. |
| Run as root "because it is easier" | Easier for attackers too. |
| Put secrets in the image or in a Dockerfile | Anyone who can pull the image can read them. |
| Use `latest` in production | The image can change without warning. |
| Leave a container with no limits on a shared machine | One bad container can hurt all the others. |

---

## 15. The hardened container (everything combined)

```bash
docker run -d --name hardened -p 8400:3000 \
  --memory 64m \
  --cpus 0.5 \
  --pids-limit 100 \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  ghcr.io/selamawitsh/go-hello:1.0.0
```

The `\` at the end of a line means "the command continues on the next line".

```
 -p 8400:3000                      laptop port 8400 → container port 3000
 --memory 64m                      at most 64 MB of RAM (over: killed)
 --cpus 0.5                        at most half a CPU core (over: slowed)
 --pids-limit 100                  at most 100 processes (stops a fork bomb)
 --read-only                       the filesystem cannot be written to
 --cap-drop ALL                    no root powers
 --security-opt no-new-privileges  can never gain more power
 the image                         already non-root (user 65532) and distroless
```

```
          ┌──────────────── hardened container ────────────────┐
          │  non-root user        ✓   (image)                  │
          │  read-only files      ✓   --read-only              │
          │  no root powers       ✓   --cap-drop ALL           │
          │  no new privileges    ✓   no-new-privileges        │
          │  64 MB RAM            ✓   --memory                 │
          │  half a CPU           ✓   --cpus                   │
          │  100 processes        ✓   --pids-limit             │
          │  no shell inside      ✓   distroless               │
          └────────────────────────────────────────────────────┘
```

I verified it with:

```
docker inspect hardened --format 'user={{.Config.User}} readonly={{.HostConfig.ReadonlyRootfs}} mem={{.HostConfig.Memory}} capdrop={{.HostConfig.CapDrop}} secopt={{.HostConfig.SecurityOpt}}'
```

Result: `user=65532 readonly=true mem=67108864 capdrop=[ALL] secopt=[no-new-privileges]`.
(`67108864` bytes = 64 × 1024 × 1024 = 64 MB.)

The app still answered `Hello from a Go app in Docker!`, and it used only about
1.3 MB of its 64 MB. Locking it down cost nothing, because it needed nothing extra.

### The price of hardening

`docker exec -it hardened sh` failed: `executable file not found`. A distroless image
has **no shell**, so an attacker cannot open one, and neither can I. Debugging
such a container needs other tools (Lab 07): logs, `docker inspect`, `docker stats`,
and a separate debug container.

### Where this goes next

| Later | Same idea |
|-------|-----------|
| Docker Compose (Phase 7) | `deploy.resources.limits` for memory and CPU |
| Kubernetes (Phase 13) | `resources.requests` and `resources.limits`, `securityContext` |
| Security phase (Phase 17) | Trivy scanning, least privilege, RBAC |

In Kubernetes, a pod killed for memory shows `OOMKilled` too, and CPU is throttled,
exactly like here.

---

## 16. Checklist

```
 Before I run a container in production:

  [ ] A memory limit set (measured first with docker stats)
  [ ] A CPU limit set
  [ ] A process limit set
  [ ] Runs as a non-root user (USER in the Dockerfile)
  [ ] Read-only filesystem, with --tmpfs or a volume only where it must write
  [ ] --cap-drop ALL, then add back only what is needed
  [ ] no-new-privileges
  [ ] A small base image (alpine or distroless), version pinned
  [ ] No secrets in the image
  [ ] Not --privileged, and no docker.sock mounted
```

### If a container keeps dying

```
 Exited (137)?
        ▼
 docker inspect NAME --format '{{.State.OOMKilled}}'
        │
        ├── true  → raise the memory limit or fix the leak
        └── false → check docker logs, then who/what sent SIGKILL

 Permission denied?          → the user lacks file permission   (check --user, volumes)
 Operation not permitted?    → a capability is missing          (--cap-add the one needed)
 Read-only file system?      → the app writes somewhere         (--tmpfs or a volume)
 Can't bind to port 80?      → needs NET_BIND_SERVICE, or use a port above 1024
```

| Mistake | What happens | Fix |
|---------|--------------|-----|
| Testing a crash with `--rm` | The `OOMKilled` evidence is deleted | Run without `--rm` |
| `-it sh` on a distroless image | `executable file not found` | Debug with logs and inspect |
| Limit too low | A healthy app is killed | Measure, then add headroom |
| Read-only with no tmpfs | The app crashes when it writes temp files | Add `--tmpfs /tmp` |

---

## 17. Self-test

1. Why are limits needed? What happens to a container with no `--memory`?
2. What is a cgroup?
3. A container shows `Exited (137)`. How do I prove it was out of memory?
4. Why is going over the memory limit deadly, but going over the CPU limit not?
5. What does `--cpus 0.5` mean?
6. What does `--memory-swap` equal to `--memory` do?
7. Why run as non-root, even inside a container?
8. `Permission denied` vs `Operation not permitted`: what is the difference?
9. What is a capability? What does `--cap-drop ALL` do?
10. Why is `--read-only` useful? Why do we add `--tmpfs /tmp`?
11. Why is `--privileged` dangerous?
12. Why could I not `docker exec -it hardened sh`? Is that good or bad?
13. How do I choose a memory limit?

### Answers

1. One greedy container can take all of the machine's RAM and starve the others.
   With no `--memory`, the container may use everything.
2. A Linux feature that limits what a process can use (memory, CPU, processes).
3. `docker inspect NAME --format '{{.State.OOMKilled}}'` shows `true`. Run without
   `--rm`, or the evidence is deleted.
4. Memory is a space and cannot be shared over time, so the container is killed.
   CPU is time, so the process just waits its turn.
5. At most half of one CPU core.
6. It allows no swap, so the container cannot use disk as extra memory.
7. If an attacker gets in, a non-root user has far less power to change files or escape.
8. `Permission denied` is a file-permission rule for a normal user.
   `Operation not permitted` means even root lacks the capability.
9. A capability is one separate piece of root's power. `--cap-drop ALL` removes all of
   them, so root can no longer do privileged things.
10. Nothing can be written, so an attacker cannot drop files. Many apps need one place
    for temporary files, so `--tmpfs` gives a small writable folder in RAM.
11. It removes the walls: nearly all capabilities and access to the host's devices.
12. The distroless image has no shell. It is good for security (an attacker cannot
    open a shell) but makes debugging harder.
13. Measure real usage with `docker stats`, then set the limit with headroom above the peak.
