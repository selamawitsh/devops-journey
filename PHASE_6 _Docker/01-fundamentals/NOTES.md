# Docker Revision Notes

Read this when you want a quick refresh. Short, simple, with pictures.

---

## 1. Why Docker exists

**Problem:** "It works on my machine" but breaks on the server (different OS
version, missing libraries, different Node/Java/Go version).

**Solution:** pack the app and everything it needs into a sealed box
(a **container**). Move the box, and the app works the same everywhere.
The server only needs Docker installed.

```
 LAPTOP                      SERVER
┌───────────────┐          ┌───────────────┐
│ [ container ] │ ───────► │ [ container ] │   same box, same result
│ Docker        │          │ Docker        │
└───────────────┘          └───────────────┘
```

### Container vs virtual machine

```
 VIRTUAL MACHINES                 CONTAINERS
┌─────┐ ┌─────┐ ┌─────┐          ┌─────┐ ┌─────┐ ┌─────┐
│ App │ │ App │ │ App │          │ App │ │ App │ │ App │
│ OS  │ │ OS  │ │ OS  │          └─────┘ └─────┘ └─────┘
└─────┘ └─────┘ └─────┘          ┌───────────────────────┐
┌───────────────────────┐        │ ONE shared Linux kernel│
│      Hypervisor       │        └───────────────────────┘
└───────────────────────┘
 heavy, slow start                 light, starts in seconds
```

- A container is a normal Linux process in a "locked room".
- **Namespaces** control what it can *see*. **cgroups** control what it can *use*
  (CPU, memory).
- Containers share the host's Linux kernel. They are not full operating systems.

---

## 2. The three words

```
 Dockerfile ──docker build──► IMAGE ──docker run──► CONTAINER
 (recipe card)               (packed,               (running app)
                              read-only)
```

| Word | Meaning | Picture |
|------|---------|---------|
| Image | Read-only template, a file on disk | Recipe plus packed ingredients |
| Container | A running (or stopped) instance of an image | The cooked meal |
| Registry | A server that stores and shares **images** | A warehouse (Docker Hub is one) |

- One image can start many containers.
- Registries store **images**, not containers.
- Images are for **shipping**. Containers on a network are for **talking**.

---

## 3. Container lifecycle

```
                 docker run (= create + start)
                          │
  Created ──start──► Running ──stop──► Exited ──rm──► Gone
                          ▲               │
                          └───start───────┘
```

| State | Process alive? | Container exists? | Data inside? |
|-------|---------------|-------------------|--------------|
| Running | Yes | Yes | Yes |
| Exited | No | Yes | Yes |
| Gone (`rm`) | No | No | **Lost** |

- `docker run` makes a **new** container. `docker start` restarts an **existing** one.
- `docker rm` removes the **container**, not the image.

### Exit codes (the STATUS column)

| Code | Meaning |
|------|---------|
| `Exited (0)` | Finished normally |
| `Exited (1)` or `(2)` | The app crashed, so read the logs |
| `Exited (137)` | Killed (SIGKILL), often out of memory |
| `Exited (143)` | Stopped by SIGTERM, which is the normal result of `docker stop` |

---

## 4. Commands cheat sheet

### See what is happening
```bash
docker ps                      # running containers
docker ps -a                   # all containers, including stopped
docker logs NAME               # what the app printed
docker logs -f NAME            # follow live (Ctrl+C to leave)
docker logs --tail 20 NAME     # last 20 lines
docker inspect NAME            # full technical details
docker stats                   # live CPU and memory use
```

### Control containers
```bash
docker run ...                 # create and start
docker stop NAME               # stop politely
docker start NAME              # start an existing stopped container
docker restart NAME
docker rm NAME                 # delete a stopped container
docker rm -f NAME              # stop and delete in one go
docker exec -it NAME sh        # open a shell inside (use sh on Alpine)
```

### Images
```bash
docker images                  # list images
docker pull IMAGE:TAG          # download without running
docker build -t NAME:TAG .     # build from a Dockerfile (the . matters!)
docker history IMAGE           # see the build steps (layers)
docker rmi IMAGE               # delete an image
```

### Common `docker run` flags
| Flag | Meaning |
|------|---------|
| `-d` | Run in the background (detached) |
| `-p HOST:CONTAINER` | Port mapping |
| `--name NAME` | Give the container a name |
| `-e KEY=value` | Set an environment variable |
| `--rm` | Delete the container automatically when it stops |
| `-it` | Interactive terminal |
| `-v SOURCE:PATH` | Volume or bind mount |
| `--network NAME` | Join a network |

---

## 5. Port mapping

```
 -p 8100 : 3000
     │       │
 your computer   inside the container
 (outside)       (where the app listens)
```

**Left is where you stand, right is where you go.**

- The right number must match the port the app listens on in its code.
- Two things cannot use the same host port. Error: `port is already allocated`.
- `127.0.0.1:8080->8080` means only your own computer can reach it.
  `0.0.0.0:8080->...` means anyone on your network can reach it.
- Count the digits when something fails (`300` vs `3000`).

---

## 6. Debugging routine

```
1. Is the container running?       docker ps -a
2. What did the app say?           docker logs NAME
3. Do the ports and config match?  check the code and the -p flag
```

After `docker run -d`, wait a second or two before testing. The app may still
be starting.

---

## 7. Images and layers (simple version)

A layer is **one saved step of changes**, like a Git commit. An image is those
steps stacked up.

```
 Layer 4: copy my code           ← changes often
 Layer 3: npm install            ← changes rarely
 Layer 2: Node installed
 Layer 1: small Linux base       ← from the base image
```

- Each Dockerfile instruction makes a step.
- Docker **reuses** steps that have not changed (`Using cache` or `CACHED`).
- Layers are shared between images, so they are stored only once on disk.
- Layers are read-only. A running container adds one thin writable layer on top,
  which is deleted with the container.

**Order rule:** put things that change **rarely** at the top (install
dependencies) and things that change **often** at the bottom (your code).

### Tags

```
 postgres : 17
    │       └── tag (version label)
    └── image name
```

- No tag means `latest`. But `latest` is only a **moving label**.
- On servers, **pin a version** (`postgres:17`) so every machine runs the same thing.
- Variants: `node:20` (big), `node:20-slim` (medium), `node:20-alpine` (small).
- Smaller image means faster to pull and less to attack.

---

## 8. Dockerfile

```dockerfile
FROM node:20-alpine        # base image
WORKDIR /app               # working folder inside the image
COPY package.json .        # copy dependency list first
RUN npm install            # BUILD time: install dependencies
COPY server.js .           # copy code after (changes often)
EXPOSE 3000                # documentation only: the app uses port 3000
CMD ["node", "server.js"]  # START time: what runs when the container starts
```

| Instruction | Meaning |
|-------------|---------|
| `FROM` | Starting image |
| `WORKDIR` | Folder to work in |
| `COPY` | Copy files from my computer into the image |
| `RUN` | Command during **build** (happens once) |
| `CMD` | Command when the container **starts** |
| `EXPOSE` | Note about the port (it does not open anything) |

- `RUN` = prep work in advance. `CMD` = serving when the customer arrives.
- `EXPOSE` only documents. `-p` is what actually opens the door.
- `.dockerignore` keeps files out of the image (`.env`, `node_modules`, `.git`).
- Never put secrets in an image. Anyone who gets the image can read them.
- Pass settings at run time with `-e` instead of hardcoding them.

---

## 9. Volumes (keeping data)

**Problem:** data written inside a container is deleted with the container.

**Fix:** a **volume** is storage that lives outside the container.

```
 container ─┐
            ├──► VOLUME (on your disk, survives rm)
 new container ─┘
```

| | Named volume | Bind mount |
|---|---|---|
| Example | `-v pgdata:/var/lib/postgresql/data` | `-v ~/site:/usr/share/nginx/html` |
| Left side | a name | a path on my computer |
| Managed by | Docker | Me |
| Use for | Database data (production) | Live code editing (development) |

- A volume is **storage**, not a container.
- `docker rm` deletes the container only. The volume stays.
- `docker volume rm` deletes the data permanently.
- `docker system prune --volumes` can delete data you care about. Be careful.

```bash
docker volume ls
docker volume inspect NAME
docker volume create NAME
docker volume rm NAME
```

---

## 10. Networking

```
┌──────────── network "app-net" ────────────┐
│  [ iqub-service ] ◄────► [ db ]           │
│       calls "db" by NAME                  │
└───────────────────────────────────────────┘
```

Three rules:

1. **Same network means they can talk.**
2. **Use the container name as the address** (`http://web`, host `db`).
   IPs change, names do not.
3. **`localhost` means "myself".** Inside a container it is that same container,
   so the database host must be the database container's name, not `localhost`.

- Each program gets its own container (one container per program). Postgres does not live
  inside the app image.
- Names only work on a **custom** network. The default bridge network has no name lookup.
- `-p` is for letting things **outside** Docker in. Containers on the same network
  do not need `-p` to talk to each other.
- Do not publish a database port unless you need it. If you do, bind it to
  `127.0.0.1`.
- Registry versus network: the registry moves **images** to the server. The network
  lets running **containers** talk.

```bash
docker network create app-net
docker network ls
docker network inspect app-net
docker run --network app-net ...
docker network rm app-net
```

Types: `bridge` (default, 95% of cases), `host` (shares the computer's network), `none`
(no network).

---

## 11. My common mistakes (so I can avoid them)

| Mistake | Fix |
|---------|-----|
| Forgot the `.` in `docker build -t name .` | The `.` is the folder with the Dockerfile |
| Mistyped a port (`300`, `900`) | Count the digits |
| Mixed up `host:container` | Left is outside, right is inside |
| Thought a volume was a container | A volume is storage |
| Used `localhost` between containers | Use the container name |
| `curl` right after `docker run -d` | Wait a second, then test |
| Typed `0` instead of the letter `O` in `wget -qO-` | Capital letter O |

---
