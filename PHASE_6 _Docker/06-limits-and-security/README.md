# Lab 06: Resource Limits and Container Security

## Goal

Limit what a container can use (memory, CPU, processes) and what it can do
(user, filesystem, root powers), then combine everything on one container.

## Idea

```
 DEFAULT container                    HARDENED container
 ┌──────────────────────────┐        ┌──────────────────────────┐
 │ runs as root             │        │ runs as non-root         │
 │ can write anywhere       │        │ read-only filesystem     │
 │ ~14 root powers          │        │ no root powers           │
 │ can use ALL my RAM       │        │ 64 MB RAM, half a CPU    │
 └──────────────────────────┘        └──────────────────────────┘
```

Principle: **least privilege**. Give a program only what it needs, nothing extra.

## Experiments and results

| # | Test | Command (short) | Result |
|---|------|-----------------|--------|
| 1 | Under the memory limit | `--memory 100m`, use 20 MB | Finished normally |
| 2 | Over the memory limit | `--memory 100m`, use 200 MB | Killed, exit code `137` |
| 3 | Proof of the cause | `docker inspect ... --format '{{.State.OOMKilled}} {{.State.ExitCode}}'` | `true 137` |
| 4 | CPU limit | `--cpus 0.5` with an endless loop | CPU stayed at about 51% (throttled, not killed) |
| 5 | Default user | `docker run --rm alpine:3.22 id` | `uid=0(root)` |
| 6 | Non-root user | `--user 1000:1000` | `uid=1000`, writing to `/etc` gave `Permission denied` |
| 7 | Read-only filesystem | `--read-only` | `Read-only file system` |
| 8 | Read-only + scratch space | `--read-only --tmpfs /tmp` | Writing to `/tmp` worked |
| 9 | Drop capabilities | `--cap-drop ALL` | `CapEff` went to all zeros, `chown` gave `Operation not permitted` |
| 10 | Everything combined | see below | App still worked, 1.3 MB of 64 MB used |

## The hardened container

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

| Flag | Meaning |
|------|---------|
| `--memory 64m` | At most 64 MB of RAM (over it: killed) |
| `--cpus 0.5` | At most half a CPU core (over it: slowed down) |
| `--pids-limit 100` | At most 100 processes (stops a fork bomb) |
| `--read-only` | The container's filesystem cannot be written to |
| `--cap-drop ALL` | Remove every Linux capability (root power) |
| `--security-opt no-new-privileges` | The process can never gain more privileges |
| `--user` | Not needed here: the image already runs as user 65532 |

Verified with `docker inspect`:
`user=65532 readonly=true mem=67108864 capdrop=[ALL] secopt=[no-new-privileges]`.

## Memory limit vs CPU limit

```
 MEMORY is a space:  it cannot be shared out over time.
                     Over the limit, the only choice is to kill the container
                     (OOMKilled, exit code 137).

 CPU is time:        a busy process can wait its turn.
                     Over the limit, Docker slows it down (throttling) and it keeps running.
```

## Exit code 137

```
 137 = 128 + 9   → killed by signal 9 (SIGKILL)
 143 = 128 + 15  → asked to stop by signal 15 (SIGTERM), normal for docker stop
```

`137` alone does not prove an out-of-memory kill. `OOMKilled` in `docker inspect`
does. Do not use `--rm` when testing, or the evidence is deleted with the container.

## Permission errors: two different messages

| Message | Meaning |
|---------|---------|
| `Permission denied` | A normal user hit a file-permission rule |
| `Operation not permitted` | Even root lacks the capability needed |

## What I learned

- Containers run as root by default, and with no `--memory` a container can use all
  of the machine's RAM (my laptop showed a 15.37 GiB "limit").
- Root is split into about 40 capabilities. Docker gives a container around 14 by
  default, and `--cap-drop ALL` removes them all.
- `--read-only` blocks writes everywhere. `--tmpfs /tmp` opens one small scratch
  folder in RAM.
- Measure real usage with `docker stats` before choosing a limit.
- Distroless plus non-root plus read-only plus no capabilities means there is almost
  nothing for an attacker to use, but also no shell for me to debug with (Lab 07).

## Mistakes and fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| `exit code 137` without a reason | I ran with `--rm`, so the container and its OOM evidence were deleted | Run without `--rm`, then `docker inspect` |
| `docker exec -it hardened sh` failed | Distroless images contain no shell | Debug with logs, `docker inspect` or a separate debug container (Lab 07) |

## Future improvements

- Add a `HEALTHCHECK` to the image.
- Use a custom seccomp profile.
- Set limits in Docker Compose (`deploy.resources`) in Phase 7.
- Scan the image with Trivy (Security phase).
