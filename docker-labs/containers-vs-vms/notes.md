# Containers vs VMs

## Core Concept

### Virtual Machines (VMs)
- Virtualizes **hardware** — creates an entire virtual computer
- Runs a **full guest operating system** with its own kernel on a hypervisor
- Each VM has its own CPU, memory, disk, and OS
- Heavy: gigabytes in size, minutes to boot
- Strong isolation: if one VM is compromised, others are safe

### Containers
- Virtualizes the **operating system** — not the hardware
- Shares the **host machine's kernel** — no separate OS needed
- Isolates only what's necessary: process, filesystem, network, users
- Lightweight: megabytes in size, start in milliseconds
- Weaker isolation: all containers share one kernel

### Why This Matters

| | VM | Container |
|---|---|---|
| Size | GB | MB |
| Boot time | Minutes | Milliseconds |
| Isolation | Strong (separate kernel) | Weaker (shared kernel) |
| Resource usage | High (full OS per VM) | Low (shared OS) |

---

## Image vs Container vs Registry

### The Coloring Book Analogy

- **Image** = The coloring book page (permanent, unchangeable outline drawing)
- **Container** = The page + your transparent plastic sheet on top (where you do the coloring)
- **Registry** = The library where master copy coloring book pages are stored

### Image
- A **read-only template** — it never runs on its own
- Built from a stack of read-only layers
- Stored on disk as folders under `/var/lib/docker/overlay2/`
- Identified by a hash (e.g., `sha256:92b11f67642b...`)
- Creating a new version means building a new image

### Container
- A **running instance** of an image
- Takes the image's read-only layers and adds a **thin writable layer** on top
- All changes (creating files, writing data, installing packages) go into the writable layer
- When the container is deleted, the writable layer is lost — the image stays untouched
- Physically: a normal Linux process (visible in `ps`) running in isolated namespaces

### Registry
- Where images are **stored and shared**
- Think of it as GitHub for container images
- A web server that speaks the Docker HTTP API
- Examples: Docker Hub, GitHub Container Registry (GHCR), Amazon ECR
- You `push` (upload) images to it, and `pull` (download) images from it

### The Workflow
```
Registry (Docker Hub)--> docker pull nginx -- >Image (read-only layers on my disk) --> docker run nginx --> Container (image + writable layer, running process) --> docker push my-app:v1 -->Registry (now others can pull it)

```

---

## What I Observed

### `docker run hello-world`

When I ran this command, the following happened step by step:

1. **Docker checked my local machine** for an image called `hello-world`. It wasn't there.

2. **Docker contacted the default registry** (Docker Hub) and said: "Give me the `hello-world` image." This is the `pull` step happening automatically — I didn't have to run `docker pull` separately.

3. **Docker downloaded the image layers** from the registry to my local machine. Each layer is a compressed folder containing files.

4. **Docker created a writable layer** on top of the downloaded image layers. This combination (image layers + writable layer) became the container.

5. **Docker started the container**, which ran a single executable inside it. That executable printed the hello message to my terminal.

6. **The executable finished and exited.** Because the container's main process (PID 1) exited, the container stopped. The container still exists on disk in a "stopped" state until I delete it.




Key observations from this output:
- `Unable to find image locally` — it wasn't on my machine
- `Pulling from library/hello-world` — it fetched from Docker Hub (the registry)
- `Pull complete` — each layer downloaded successfully
- `Downloaded newer image` — the image is now stored locally
- The hello message came from *inside* the container, which then exited

### `docker images`

This command lists all images stored locally on my machine.

What this tells me:
- **REPOSITORY**: The image name (`hello-world`)
- **TAG**: The version (`latest`)
- **IMAGE ID**: A unique hash identifying this exact image build
- **SIZE**: Only 13.3 kilobytes — proof that it doesn't contain a full OS. Just a tiny binary.
- This image will stay here until I run `docker rmi hello-world`

### `docker ps` and `docker ps -a`

`docker ps` lists only **running** containers. Since my `hello-world` container already exited, it showed nothing:




## Key Takeaways

1. **Images are immutable blueprints** — they're read-only templates stored on disk. They never change. They never run.

2. **Containers are running instances** — an image plus a writable layer, running as an isolated process. They come and go.

3. **Registries are image libraries** — remote servers that store and distribute images. Docker Hub is the default public registry.

4. **VMs virtualize hardware with separate kernels.** Containers virtualize the OS and share the host kernel. This is why containers are fast and small, but VMs are more isolated.

5. **The workflow is always: pull from registry → create container from image → run process → container exits.**
