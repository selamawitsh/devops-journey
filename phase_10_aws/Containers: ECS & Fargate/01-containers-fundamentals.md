# Session 07 (1/5): Containers Fundamentals

## The problem, precisely

"Works on my machine" is the symptom, not the cause. The actual cause: a running
process needs three things — an OS, its dependencies, and isolation from other
processes on the same machine. Historically all three came from either a
dedicated physical server or a full VM.

## VM vs container — what's actually different

A **VM** virtualizes hardware. A hypervisor presents virtual disks, virtual NICs,
virtual CPUs, and a full guest OS boots on top of them — its own kernel, its own
init system, its own filesystem. That's why a VM is gigabytes and takes minutes
to boot: you are booting an entire operating system.

A **container** does not virtualize anything. It is a normal process on the host,
made to believe it's alone on the machine using two Linux kernel features:

- **Namespaces** — give the process its own view of PIDs, network interfaces,
  mount points, and hostname. Container A's `PID 1` and container B's `PID 1`
  are different real host processes, but each container only sees its own.
- **cgroups (control groups)** — cap how much CPU, memory, and IO that process
  is allowed to consume, so one container can't starve the others.

No hypervisor, no second kernel, same host kernel shared by every container.
That's why a container starts in milliseconds: there is nothing to boot, just a
process being started with kernel-level fencing around it.


## Image vs running container — precisely

An **image** is a stack of read-only layers, one per Dockerfile instruction,
stitched together with a union filesystem (OverlayFS on Linux) so it looks like
one filesystem.

A **container** = that same image, plus one thin writable layer on top, plus a
running process.

Run the same image 5 times and all 5 containers share the exact same read-only
image layers on disk — Docker does not duplicate them. They only differ in
their own small writable layer. This is why:

- Spinning up many replicas of the same service is cheap on disk.
- If you write a file inside a container and don't mount a volume, that file
  disappears the moment the container is removed — it only ever existed in the
  writable layer that died with the container. This is a real production
  surprise: "I wrote a file inside my container and it vanished on redeploy."

## Dockerfile and layer caching

```
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 80
CMD ["python", "app.py"]
```

Docker builds top to bottom and **caches each layer**. The moment one layer's
input changes, that layer and every layer after it rebuild — everything above
stays cached.

Notice the order: `requirements.txt` is copied and installed *before* the rest
of the app code is copied in. Change a line in `app.py` and:

- `FROM`, `WORKDIR`, `COPY requirements.txt`, `RUN pip install` — inputs
  unchanged, all reused from cache, `pip install` does not rerun.
- `COPY . .` and everything after — inputs changed, rebuilt.

If you instead `COPY . .` before `RUN pip install` (a very common mistake),
every code change invalidates the dependency-install layer too, and every build
reinstalls all dependencies from scratch. Fixing this ordering is a classic
"show me you understand Docker" interview task, and a real cost lever in CI —
company build pipelines that get this wrong burn minutes per commit that
correctly-ordered Dockerfiles don't.

## How this shows up at a company

- **CI/CD**: build the image once, run the identical image in test and
  production. No "it passed QA but broke in prod because of a library version
  mismatch."
- **Debugging a running container**: `docker logs <container>` for stdout/stderr,
  `docker exec -it <container> sh` to get a shell inside it and poke around —
  same muscle memory whether it's running locally or on ECS.
- **Image size and security**: smaller images build faster, deploy faster, and
  have a smaller attack surface — companies scan images (see ECR next) and
  often fail a pipeline if a base image has known CVEs.

