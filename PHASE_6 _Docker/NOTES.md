# Docker Revision Notes

My own notes, with pictures. Read top to bottom the first time.
Later, jump to the section you need.

## Contents

1. The big picture
2. Why Docker exists
3. Image, container, registry
4. Container lifecycle
5. Everyday commands
6. Ports
7. Debugging routine
8. Images and layers
9. Dockerfile
10. Multi-stage builds
11. Volumes
12. Networking
13. My common mistakes
14. Self-test
15. One-page cheat sheet

---

## 1. The big picture

Everything in Docker is one journey. Keep this picture in your head.

```
  I WRITE          DOCKER BUILDS        I SHIP             THE SERVER RUNS
┌────────────┐     ┌──────────┐      ┌──────────┐        ┌─────────────┐
│ Dockerfile │build│  IMAGE   │ push │ REGISTRY │  pull  │ CONTAINER   │
│  (recipe)  │────►│ (sealed  │─────►│(warehouse│───────►│ (running    │
│            │     │   box)   │      │of images)│        │   app)      │
└────────────┘     └──────────┘      └──────────┘        └──────┬──────┘
                                                                │
                           ┌────────────────────────────────────┼────────────┐
                           ▼                                    ▼            ▼
                       NETWORK                               VOLUME        PORTS
                  (containers talk                      (data that      (let the outside
                   to each other)                        survives)       world in)
```

One sentence to remember:

> A Dockerfile builds an image, an image runs as a container, and a container
> is my app in a sealed box that behaves the same everywhere.

---

## 2. Why Docker exists

**The problem:** "It works on my machine." I build the app on my laptop, it
works, I put it on a server, and it breaks. The server has a different OS
version, a different Node/Java/Go version, or a missing library.

**The solution:** pack the app and everything it needs into one sealed box
(a **container**). Move the box. It works the same way everywhere. The server
only needs Docker installed.

```
     MY LAPTOP                              THE SERVER
┌──────────────────┐                  ┌──────────────────┐
│  ┌────────────┐  │                  │  ┌────────────┐  │
│  │ CONTAINER  │  │    same box,     │  │ CONTAINER  │  │
│  │ app + libs │  │ ───────────────► │  │ app + libs │  │
│  │ + runtime  │  │   same result    │  │ + runtime  │  │
│  └────────────┘  │                  │  └────────────┘  │
│  Docker          │                  │  Docker          │
└──────────────────┘                  └──────────────────┘
```

The laptop and server can be different underneath. The box carries its own
world inside, so the app does not notice.

### Container vs virtual machine

```
   VIRTUAL MACHINES                       CONTAINERS

┌───────┐ ┌───────┐ ┌───────┐         ┌───────┐ ┌───────┐ ┌───────┐
│  App  │ │  App  │ │  App  │         │  App  │ │  App  │ │  App  │
│ full  │ │ full  │ │ full  │         └───────┘ └───────┘ └───────┘
│  OS   │ │  OS   │ │  OS   │         ┌─────────────────────────────┐
└───────┘ └───────┘ └───────┘         │   ONE shared Linux kernel   │
┌─────────────────────────────┐       └─────────────────────────────┘
│         Hypervisor          │
└─────────────────────────────┘

  heavy (GBs), slow to start            light (MBs), starts in seconds
```

- A VM is a whole separate house for each family.
- A container is a locked apartment in the same building.
- A container is **just a normal Linux process in a locked room**:
  - **Namespaces** control what it can *see* (its own processes, network, files).
  - **cgroups** control what it can *use* (CPU, memory).
- Containers share the host's Linux kernel. They are not full operating systems.
- The server needs **Docker**, not a matching OS setup. That is the win.

---

## 3. Image, container, registry

```
  Dockerfile ──docker build──► IMAGE ──docker run──► CONTAINER
   (recipe card)           (recipe + packed        (the cooked meal,
                            ingredients,            alive and running)
                            read-only file)
```

| Word | What it is | Picture |
|------|-----------|---------|
| **Image** | Read-only template, a file on disk. It does not run. | Recipe plus packed ingredients |
| **Container** | A running (or stopped) copy made from an image | The cooked meal |
| **Registry** | A server that stores and shares **images** | A warehouse (Docker Hub is one) |

```
            ┌─────────┐   docker run   ┌────────────┐
            │  IMAGE  │ ─────────────► │ container 1│
            │  nginx  │ ─────────────► │ container 2│   many meals
            └─────────┘ ─────────────► │ container 3│   from one recipe
                                        └────────────┘
```

Important facts:

- One image can start many containers.
- Registries store **images**, not containers.
- Docker Hub is the public registry. Others: GitHub Container Registry, AWS ECR,
  private registries.
- Commands for **containers**: `run`, `start`, `stop`, `rm`, `logs`, `exec`.
- Commands for **images**: `build`, `pull`, `images`, `rmi`, `history`.
- Images are for **shipping**. Containers on a network are for **talking**.

---

## 4. Container lifecycle

A container is like a rented apartment.

```
docker run   = rent an apartment and move in
docker stop  = go out and lock the door (everything stays inside)
docker start = come back and unlock the door
docker rm    = give the apartment back (everything inside is thrown away)
```

```
                    docker run  (= create + start in one step)
                           │
   ┌──────────┐  start  ┌──────────┐  stop   ┌──────────┐   rm    ┌──────┐
   │ Created  │ ──────► │ Running  │ ──────► │  Exited  │ ──────► │ Gone │
   └──────────┘         └──────────┘ ◄────── └──────────┘         └──────┘
                                      start
```

| Stage | Process alive? | Container exists? | Data inside it? |
|-------|---------------|-------------------|-----------------|
| Running | Yes | Yes | Yes |
| Exited (stopped) | No | Yes | Yes |
| Gone (`rm`) | No | **No** | **Lost forever** |

- `docker run` makes a **new** container (and downloads the image if missing).
- `docker start` restarts an **existing** stopped container.
- `docker rm` deletes the **container**, never the image.
- Data written inside a container lives in a thin writable layer that is deleted
  with the container. That is why databases need volumes (section 11).

### Reading the STATUS column (exit codes)

| Status | Meaning | What to do |
|--------|---------|------------|
| `Up 5 minutes` | Running | Nothing |
| `Exited (0)` | Finished normally, or stopped cleanly | Nothing |
| `Exited (1)` or `(2)` | The app crashed | `docker logs NAME` |
| `Exited (137)` | Killed (SIGKILL), often out of memory | Check memory limits |
| `Exited (143)` | Stopped by SIGTERM, normal for `docker stop` | Nothing |
| `Created` | Made but never started | `docker start NAME` |

---

## 5. Everyday commands

### See what is happening

```bash
docker ps                      # running containers only
docker ps -a                   # ALL containers, including stopped ones
docker logs NAME               # what the app printed
docker logs -f NAME            # follow live (Ctrl+C leaves, container keeps running)
docker logs --tail 20 NAME     # last 20 lines
docker inspect NAME            # full technical details (long)
docker stats                   # live CPU and memory use
```

### Control containers

```bash
docker run ...                 # create and start from an image
docker stop NAME               # stop politely (SIGTERM, then force after 10s)
docker start NAME              # start an existing stopped container
docker restart NAME
docker rm NAME                 # delete a stopped container
docker rm -f NAME              # stop and delete in one go
docker exec -it NAME sh        # open a shell INSIDE a running container
```

`exec -it` is like opening a door into the locked room. Use `sh` on Alpine
images (they have no `bash`). Distroless images have no shell at all.

### Images

```bash
docker images                  # list images on this machine
docker pull IMAGE:TAG          # download without running
docker build -t NAME:TAG .     # build from a Dockerfile (the dot matters!)
docker build -f FILE -t NAME:TAG .   # use a Dockerfile with another name
docker history IMAGE           # see the build steps (layers)
docker rmi IMAGE               # delete an image
```

- `docker build -t my-app:v1 .` means: build, **t**ag it `my-app:v1`, and look for
  the Dockerfile in **this folder** (the `.`).
- An image cannot be deleted while a container (even a stopped one) uses it.

### The `docker run` flags I use constantly

```bash
docker run -d -p 8100:3000 --name hello-app -e KEY=value --rm my-app:v1
```

| Flag | Meaning | Picture |
|------|---------|---------|
| `-d` | Detached: run in the background | Work in the back office |
| `-p HOST:CONTAINER` | Port mapping | Cut a door into the container |
| `--name` | Give the container a name | A label on the door |
| `-e KEY=value` | Set an environment variable | Hand the app a note with settings |
| `--rm` | Delete the container automatically when it stops | Self-destructing apartment |
| `-it` | Interactive terminal | Sit inside and type |
| `-v SOURCE:PATH` | Volume or bind mount | Connect a storage unit |
| `--network NAME` | Join a network | Move into a building |

---

## 6. Ports

```
        -p  8100  :  3000
             │         │
       MY COMPUTER   INSIDE THE CONTAINER
        (outside)    (where the app listens)

  browser ─► localhost:8100 ─► [ door 8100 → 3000 ] ─► app in container
```

> **Left is where I stand, right is where I go.**

Rules:

- The **right** number must match the port the app listens on in its code.
  If not, the door leads to an empty room (`Connection reset by peer`).
- Two things cannot use the same host port: `port is already allocated`.
  Pick a different left number.
- `127.0.0.1:8080->8080` means only my own computer can reach it (safer).
  `0.0.0.0:8080->...` means anyone on my network can reach it.
- `EXPOSE 3000` in a Dockerfile is only a note. `-p` is what actually opens the door.
- After `docker run -d`, wait a second before testing. The app may still be starting.
- **Count the digits** when something fails (`300` vs `3000`).

---

## 7. Debugging routine

Do these in this order. Do not guess, look.

```
 Something is wrong
        │
        ▼
 1. Is the container running?        docker ps -a
        │
        ├── Exited ──► 2. Why did it stop?     docker logs NAME
        │
        ▼ (running)
 3. Does the port mapping match the code?   check -p and the app's port
        │
        ▼
 4. Can I look inside?               docker exec -it NAME sh
```

- When several errors appear, **fix the first one only**. The rest are often a chain
  reaction (a failed build causes "image not found", which causes "can't connect").
- `pull access denied` for my own image usually means the image was never built.

---

## 8. Images and layers

A **layer** is one **saved step**. Docker saves a checkpoint after every
Dockerfile instruction, like save points in a video game.

```
   Dockerfile                      Image (saved steps stacked up)

   FROM alpine          ───►   ┌──────────────────────────┐
   RUN create file2     ───►   │ step 3: file3  (13 bytes)│  ✔ saved
   RUN create file3     ───►   ├──────────────────────────┤
                               │ step 2: file2  (13 bytes)│  ✔ saved
                               ├──────────────────────────┤
                               │ step 1: alpine base      │  ✔ saved
                               └──────────────────────────┘
```

**The cache rule:** if a step (and everything above it) has not changed, Docker
reuses the saved step instead of running it again (`Using cache`).

```
 Change step 3:   step 1 ✔ reuse    step 2 ✔ reuse    step 3 ↻ redo
 Change step 2:   step 1 ✔ reuse    step 2 ↻ redo     step 3 ↻ redo
```

Everything from the changed step **downward** is rebuilt.

My proof (Lab 01): the second build showed step 2 with the same ID
(`b0962e99be2e`) as the first build. That means it was reused.

### Why this matters

If step 2 were `npm install` (3 minutes) and I change one line of code (step 3):

```
 Without saved steps:  rebuild everything   3 minutes every time
 With saved steps:     reuse step 2         5 seconds
```

So: **put things that change rarely at the top (install dependencies) and things
that change often at the bottom (my code).**

### More facts

- Layers are shared between images, so they are stored only once on disk.
- Layers are read-only. A running container adds one thin writable layer on top,
  which is deleted with the container.
- Each row of `docker history IMAGE` is one layer.
- Pulling an image prints one `Pull complete` line per layer.

### Tags

```
   postgres : 17
      │        └── tag (a version label)
      └── image name
```

- No tag means `latest`, but `latest` is only a **moving label**, not a guarantee.
- On servers, **pin the version** (`postgres:17`) so every machine runs the same thing.
- Different "flavors": `node:20` (big), `node:20-slim` (medium), `node:20-alpine` (small).

---

## 9. Dockerfile

A Dockerfile is a recipe card. Docker follows it top to bottom.

```dockerfile
FROM node:20-alpine         # start from this base image
WORKDIR /app                # work inside /app
COPY package.json .         # copy the dependency list first (changes rarely)
RUN npm install             # BUILD time: install dependencies once
COPY server.js .            # copy the code after (changes often)
EXPOSE 3000                 # a note: the app uses port 3000
CMD ["node", "server.js"]   # START time: run this when a container starts
```

| Instruction | Meaning | Kitchen picture |
|-------------|---------|-----------------|
| `FROM` | Starting image | Choose the starting kitchen |
| `WORKDIR` | Folder to work in | Stand at a table |
| `COPY` | Copy files from my computer into the image | Bring in ingredients |
| `RUN` | Command during **build** (once) | Prep work in advance |
| `CMD` | Command when the container **starts** | Serve when the customer arrives |
| `EXPOSE` | Documents the port (opens nothing) | A sign on the wall |

### RUN vs CMD

```
 docker build  ──►  RUN runs here  (once, while making the image)
 docker run    ──►  CMD runs here  (every time a container starts)
```

### Good habits

- **`.dockerignore`** keeps files out of the image: `.git`, `node_modules`, `.env`, logs.
- **Never put secrets in an image.** Anyone who gets the image can read them.
  Pass settings at run time: `docker run -e DB_PASSWORD=...`.
- Use a **pinned** base image (`node:20-alpine`, not `node:latest`).
- Run as **non-root** when possible.
- One program per container.

---

## 10. Multi-stage builds (Lab 02)

**The problem:** a normal image carries the whole kitchen (compiler, tools) just
to run one small program.

```
   SINGLE STAGE                          MULTI-STAGE

┌─────────────────────┐        ┌───────────────┐     ┌──────────────────┐
│ Go compiler + tools │        │ STAGE 1       │     │ STAGE 2          │
│ + source code       │        │ compiler +    │     │ tiny clean base  │
│ + my program        │        │ source        │────►│ + ONLY the       │
│                     │        │ builds the    │copy │   finished       │
│       304 MB        │        │ program       │     │   program        │
└─────────────────────┘        │ (thrown away) │     │     10.2 MB      │
                               └───────────────┘     └──────────────────┘
```

> Cook in one kitchen. Serve from a clean one.

**My result:** the same Go app went from **304 MB to 10.2 MB**, about 30 times smaller.

```dockerfile
FROM golang:1.25-alpine AS builder                  # stage 1, named "builder"
WORKDIR /app
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -o server .              # compile the program

FROM gcr.io/distroless/static-debian12:nonroot      # stage 2: a brand new, clean image
COPY --from=builder /app/server /server             # take ONLY the finished program
EXPOSE 3000
CMD ["/server"]
```

| Piece | Meaning |
|-------|---------|
| `AS builder` | Names a stage |
| second `FROM` | Starts a fresh image. Only the **last** stage becomes the final image |
| `COPY --from=builder` | Copies chosen files from an earlier stage |
| `CGO_ENABLED=0` | Makes a self-contained program that needs no system libraries |

### Choosing a base image

| Base | Size | Shell? | Use for |
|------|------|--------|---------|
| full (`node:20`) | Big | Yes | Easy debugging, but heavy |
| `-slim` | Medium | Yes | Balanced |
| `-alpine` | Small | Yes (`sh`) | Most production images |
| `distroless` | Very small | **No** | Production, maximum safety |
| `scratch` | Empty | No | Self-contained programs |

- Smaller means faster to pull and start, and less for an attacker to use.
- `nonroot` means the program runs as an unprivileged user.
- Distroless has **no shell**, so `docker exec -it NAME sh` fails. That is good for
  security, but debugging needs another approach (Lab 07).

---

## 11. Volumes

**The problem:** data written inside a container dies when the container is removed.

```
 container ──rm──► its writable layer is deleted ──► database rows GONE
```

**The fix:** a **volume** is storage that lives **outside** the container, like a
storage unit rented separately from the apartment.

```
  ┌─────────────┐
  │ container 1 │──┐
  └─────────────┘  │       ┌───────────────┐
       rm ✗        ├──────►│    VOLUME     │  lives on my disk,
  ┌─────────────┐  │       │  (my data)    │  survives docker rm
  │ container 2 │──┘       └───────────────┘
  └─────────────┘
   new container, same data ✓
```

A volume is **storage, not a container**. It has its own life.

### Two kinds

```
 Named volume:  -v pgdata:/var/lib/postgresql/data
                    │              │
              name of the      path INSIDE the container
              storage unit     where it appears

 Bind mount:    -v /home/me/site:/usr/share/nginx/html
                    │                    │
              a folder on MY         path INSIDE the container
              computer
```

| | Named volume | Bind mount |
|---|---|---|
| Left side is | a name | a path |
| Managed by | Docker | Me |
| Use for | Database data, production | Live code editing, development |

Same direction as ports: left is my side, right is inside the container.

### Rules and commands

- `docker rm` deletes the **container only**. The volume stays safe.
- `docker volume rm` deletes the data **permanently**.
- `docker system prune --volumes` can delete data I care about. Be careful.

```bash
docker volume ls
docker volume inspect NAME
docker volume create NAME
docker volume rm NAME
```

### The test that proves it

1. Start Postgres with a named volume and create a table.
2. `docker rm -f` the container.
3. Start a new container with the same volume.
4. The table is still there. Without the volume, it is gone.

---

## 12. Networking (Lab 03)

A Docker network is like a **building with an intercom**. Containers inside the
same building can call each other **by name**.

```
┌───────────────── network "lab-net" ─────────────────┐
│                                                     │
│   ┌──────────┐     "call db"      ┌──────────┐      │
│   │  my-app  │ ─────────────────► │    db    │      │
│   │172.22.0.3│  Docker looks up   │172.22.0.2│      │
│   └──────────┘  the name → IP     └──────────┘      │
│                                                     │
└─────────────────────────────────────────────────────┘
        a container on another network cannot see them
```

### Three rules

1. **Same network means they can talk.**
2. **Use the container's name as the address** (`http://web`, host `db`).
   IPs change when a container restarts, names do not.
3. **`localhost` means "myself".** Inside a container it is that same container.

```
 inside my-app container:
   DB_HOST=localhost   ✗  looks inside my-app itself (no database there)
   DB_HOST=db          ✓  asks Docker for the container named "db"
```

### Each program gets its own container

Postgres does not live inside the app image. My stack is separate containers
(iqub-service, member-service, two Postgres, RabbitMQ) that talk over a network.

### Ports vs networks

```
 -p 8100:3000   ─►  lets things OUTSIDE Docker (my browser) in
 network        ─►  lets containers talk to each other INSIDE
```

- Containers on the same network do **not** need `-p` to talk.
- Do not publish a database port unless I need it. If I do, bind it to `127.0.0.1`.

### Registry vs network

```
 REGISTRY  moves IMAGES to the server        (shipping, before anything runs)
 NETWORK   lets running CONTAINERS talk      (communication, after they start)
```

### My experiments (Lab 03)

| Test | Result | Why |
|------|--------|-----|
| Visitor on same custom network calls `web` | Worked | Docker DNS resolves names |
| Visitor on default network calls `web` | `bad address 'web'` | Different network, and the default bridge has no name lookup |
| Call by IP | Worked | But the IP can change |
| `--network none` | Only `lo` (127.0.0.1) | No network at all |
| `--network host` | Saw the laptop's real interfaces | No isolation |

### Network types

| Type | What it does | Use |
|------|--------------|-----|
| custom `bridge` | Private network, own IPs, **name lookup** | Almost always |
| default `bridge` | Private network, **no name lookup** | Avoid |
| `host` | Shares the laptop's network | Rare |
| `none` | No network | Isolated jobs |

Every Docker network shows up on the laptop as a virtual switch named `br-<id>`.

```bash
docker network create lab-net
docker network ls
docker network inspect lab-net       # who is on it, and their IPs
docker run --network lab-net ...
docker network rm lab-net
```

If a name does not resolve, check: is the target container **running**
(`docker ps`)? Is it on the **same network** (`docker network inspect`)?

---

## 13. My common mistakes

| Mistake | What happened | Fix |
|---------|---------------|-----|
| Forgot the `.` in `docker build -t name .` | `requires 1 argument` | The `.` is the folder with the Dockerfile |
| Mistyped a port (`300`, `900`) | `Connection reset by peer` | Count the digits |
| Mixed up `host:container` | Wrong door | Left is outside, right is inside |
| Ran `curl` right after `docker run -d` | Connection reset | Wait a second for the app to start |
| Thought a volume was a container | Confusion | A volume is storage |
| Thought data lived in the image | Lost data after `rm` | Data lives in the container's writable layer |
| Typed `-q0-` and `htt:://` | `wget` failed | Capital letter O, and `http://` |
| `bad address 'web'` | The `web` container had stopped | `docker ps -a`, then `docker start web` |
| Built from a missing `Dockerfile.multi` | `no such file`, then `pull access denied` | Fix the first error only |
| `docker run` pulled from the internet | DNS error `server misbehaving` | Use an image that is already local |
| Port already in use | `port is already allocated` | Choose another host port |

---

## 14. Self-test

Answer without looking. Write short answers in my own words.

1. What problem does Docker solve?
2. Image vs container vs registry?
3. `docker run` vs `docker start`?
4. A container shows `Exited (1)`. What do I do first?
5. In `-p 9000:5000`, which URL do I open, and which port does the app use?
6. `RUN` vs `CMD`?
7. What is a layer? Why is `Using cache` useful?
8. If I change step 2 of a 3-step Dockerfile, which steps rebuild?
9. Why copy `package.json` before the code?
10. What does a multi-stage build do? What happened to my image size?
11. Why does data vanish after `docker rm`, and what is the fix?
12. Named volume vs bind mount?
13. Why can't a container reach Postgres through `localhost`?
14. Why did calling `web` fail from the default network?
15. Registry vs Docker network?
16. Why pin `postgres:17` instead of `postgres:latest`?

### Answers

1. Docker packages the app with everything it needs, so it runs the same anywhere.
2. Image is the read-only template. Container is a running copy of it. Registry is a
   warehouse that stores images.
3. `run` creates a new container and starts it. `start` restarts an existing one.
4. `docker logs NAME` to read the error.
5. Open `localhost:9000`. The app listens on 5000.
6. `RUN` happens at build time (once). `CMD` happens when the container starts.
7. A layer is one saved build step. Docker reuses unchanged steps, so rebuilds are fast.
8. Steps 2 and 3. Everything from the changed step downward.
9. Dependencies change rarely, so that step is reused from cache.
10. It builds in one stage and ships a clean second stage with only the program.
    304 MB became 10.2 MB.
11. The data lived in the container's writable layer, which is deleted with it.
    Use a volume.
12. Named volume is managed by Docker (databases). Bind mount is a folder of mine
    (development).
13. `localhost` inside a container means that same container. Use the other
    container's name.
14. It was on a different network, and the default bridge has no name lookup.
15. The registry ships images to the server. The network lets running containers talk.
16. `latest` is a moving label. Pinning makes every machine run the same version.

---

## 15. One-page cheat sheet

```bash
# IMAGES
docker build -t NAME:TAG .            # build (don't forget the dot)
docker images                         # list
docker history IMAGE                  # see layers
docker pull IMAGE:TAG                 # download
docker rmi IMAGE                      # delete

# RUN
docker run -d -p HOST:CONTAINER --name NAME -e KEY=val IMAGE
docker run --rm -it IMAGE sh          # temporary interactive container
docker run -v VOLUME:/path IMAGE      # attach storage
docker run --network NET IMAGE        # join a network

# LOOK
docker ps                             # running
docker ps -a                          # all
docker logs NAME                      # output (add -f to follow)
docker exec -it NAME sh               # go inside
docker inspect NAME                   # details
docker stats                          # CPU and memory

# CONTROL
docker stop NAME
docker start NAME
docker rm NAME                        # delete container
docker rm -f NAME                     # force

# VOLUMES AND NETWORKS
docker volume ls / create / inspect / rm
docker network ls / create / inspect / rm
```

```
 Remember:
   port      left = my computer,  right = inside the container
   volume    left = storage name or folder,  right = path inside
   network   same network + container name = they can talk
   debug     docker ps -a  →  docker logs  →  check ports
   images    ship them.   containers  talk.
```
