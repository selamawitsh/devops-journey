# Volumes and Persistent Data: My Notes

Written from zero. Read top to bottom the first time.

## Contents

1. The problem
2. Where does a container keep its data?
3. The fix: a volume
4. The kinds of storage
5. Reading the -v flag
6. What survives what
7. Named volumes in detail
8. Bind mounts in detail
9. Which one do I use?
10. Safety rules
11. What I proved in Lab 04
12. If my data is missing: checklist
13. Self-test

---

## 1. The problem

A container is **temporary**. I can delete it and create a new one at any time.
But a database holds data I want to keep.

```
   container (temporary)         my data (must be kept!)
   ┌──────────────────┐
   │ Postgres         │
   │  └─ my tables    │  ──── docker rm ────►  ??? gone
   └──────────────────┘
```

---

## 2. Where does a container keep its data?

An image is a stack of **read-only** layers. When a container starts, Docker puts
**one thin writable layer** on top. Everything the container writes goes there.

```
   ┌──────────────────────────────┐
   │ writable layer               │ ← my database rows are written HERE
   │ (belongs to THIS container)  │   deleted when the container is deleted
   ├──────────────────────────────┤
   │ image layers (read-only)     │ ← stay safe on disk, shared by containers
   └──────────────────────────────┘
```

So: **delete the container and its writable layer goes with it.**

- `docker stop` / `docker start`: the container still exists, so the data stays.
- `docker rm`: the container is gone, so the data is gone.

---

## 3. The fix: a volume

A volume is **storage that lives outside the container**, like a storage unit
rented separately from the apartment.

```
   ┌─────────────┐
   │ container 1 │──┐
   └─────────────┘  │         ┌────────────────┐
        rm ✗        ├────────►│     VOLUME     │   on my disk,
   ┌─────────────┐  │         │   (my data)    │   has its own life
   │ container 2 │──┘         └────────────────┘
   └─────────────┘
    a new container, the same data ✓
```

Important:

- A volume is **storage**, not a container.
- A container and a volume are two separate things. Deleting one does not
  delete the other.

---

## 4. The kinds of storage

```
 ┌──────────────────────────────────────────────────────────────────┐
 │ 1. NAMED VOLUME      Docker manages the folder, I give it a name │
 │ 2. BIND MOUNT        I choose a folder on my laptop              │
 │ 3. TMPFS             kept in memory (RAM), gone when it stops    │
 │ 4. ANONYMOUS VOLUME  a volume with no name (random id)           │
 └──────────────────────────────────────────────────────────────────┘
```

| Kind | Looks like | Where the data lives | Survives `docker rm`? |
|------|-----------|----------------------|-----------------------|
| Named volume | `-v pgdata:/var/lib/postgresql/data` | `/var/lib/docker/volumes/pgdata/_data` | Yes |
| Bind mount | `-v "$PWD/site:/usr/share/nginx/html"` | The folder I chose | Yes |
| tmpfs | `--tmpfs /cache` | RAM | No, and it is lost when the container stops |
| Anonymous volume | `-v /var/lib/postgresql/data` (no name) | Docker's folder, random name | Survives plain `rm`, deleted by `rm -v` |

### The anonymous volume trap

The Postgres image **declares** its data folder as a volume. If I run Postgres with
no `-v` at all, Docker silently creates an anonymous volume for it.

```
 run 1:  container A + anonymous volume 7f3a…   (my data is in 7f3a…)
 rm A
 run 2:  container B + a NEW anonymous volume 91c2…   ← empty! my data is in
                                                        7f3a… but nothing uses it
```

The data is not destroyed by plain `rm`, but a new container gets a **new, empty**
volume, so it looks like the data vanished. And `docker rm -v` deletes the old one
for good. That is what I saw in Test 1.

> **Always give my volume a name.**

---

## 5. Reading the -v flag

### Named volume

```
 -v  pgdata  :  /var/lib/postgresql/data
 │     │            │
 │     │            └ a path INSIDE the container
 │     │              (the folder Postgres keeps its files in)
 │     └ the NAME of the volume
 │       (Docker creates it if it doesn't exist yet)
 └ connect storage
```

### Bind mount

```
 -v  "$PWD/site"  :  /usr/share/nginx/html
 │        │               │
 │        │               └ a path INSIDE the container
 │        │                 (the folder nginx serves pages from)
 │        └ a FULL PATH on my laptop
 │          $PWD = the full path of my current folder
 └ connect storage
```

```
 How Docker decides which kind it is:

   left side = a name          →  named volume     (pgdata)
   left side = a path (/ or $PWD) →  bind mount    ($PWD/site)
```

If I write `-v site:/usr/share/nginx/html` (no full path), Docker thinks `site` is a
**volume name**, not my folder. That is the classic mix-up.

Same direction as ports: **left is my side, right is inside the container.**

### The longer, clearer form: --mount

```
 docker run --mount type=volume,source=pgdata,target=/var/lib/postgresql/data ...
 docker run --mount type=bind,source="$PWD/site",target=/usr/share/nginx/html ...
```

| Part | Meaning |
|------|---------|
| `type=` | `volume` or `bind` |
| `source=` | The volume name, or the folder on my laptop |
| `target=` | The path inside the container |

`--mount` says what it means in words, and gives an error if the bind folder does
not exist. `-v` would silently create it.

---

## 6. What survives what

| What I do | Data in the container's own layer | Anonymous volume | Named volume | Bind mount |
|-----------|----------------------------------|------------------|--------------|------------|
| `docker stop` then `start` | Stays | Stays | Stays | Stays |
| `docker rm` (no `-v`) | **Lost** | Stays (orphaned) | Stays | Stays |
| `docker rm -v` | **Lost** | **Deleted** | Stays | Stays |
| `docker volume rm NAME` | n/a | Deleted | **Deleted** | n/a (my folder) |
| Delete the image | Not affected | Not affected | Not affected | Not affected |

Remember: the **image** never holds my data. Deleting or rebuilding an image
does not touch a volume.

---

## 7. Named volumes in detail

```
 inside the container:   /var/lib/postgresql/data  ─┐
                                                    ├── the same files
 on my laptop:           /var/lib/docker/volumes/   ─┘
                         pgdata/_data
```

The `Mountpoint` from `docker volume inspect` is that real folder. It belongs to
Docker (and root). I do not edit files in there by hand.

### Commands, piece by piece

```
docker volume create pgdata
   │       │      │     │
   │       │      │     └ the name I choose
   │       │      └ create a new volume
   │       └ work with volumes
   └ docker
```

| Command | Meaning |
|---------|---------|
| `docker volume create NAME` | Make an empty named volume |
| `docker volume ls` | List all volumes |
| `docker volume inspect NAME` | Show details, including the `Mountpoint` |
| `docker volume rm NAME` | Delete a volume **and its data, permanently** |

Docker also creates a named volume automatically the first time I use
`-v NAME:/path`, if it does not exist yet.

### Starting Postgres with a volume

```
docker run -d --name db-vol -e POSTGRES_PASSWORD=secret -v pgdata:/var/lib/postgresql/data postgres:17
   │       │   │            │                          │                                      │
   │       │   │            │                          │                                      └ image
   │       │   │            │                          └ attach the storage unit "pgdata"
   │       │   │            └ -e = set an environment variable (the password)
   │       │   └ the container's name
   │       └ -d = run in the background
   └ create and start a container
```

### Running a command inside the container

```
docker exec db-vol psql -U postgres -c "SELECT * FROM notes;"
   │         │       │     │           │
   │         │       │     │           └ -c = run this SQL, then exit
   │         │       │     └ -U postgres = log in as user "postgres"
   │         │       └ psql = Postgres's command-line client
   │         └ the container to run it in
   └ run a command INSIDE a running container
```

### Removing a container

```
docker rm -fv db-vol
          │││
          ││└ the container's name
          │└ v = also remove its ANONYMOUS volumes (a named volume stays safe)
          └ f = force: stop it first if it is running
```

---

## 8. Bind mounts in detail

A bind mount shares **one real folder** between my laptop and the container.

```
 my laptop                              container
 ┌─────────────────────┐              ┌───────────────────────────┐
 │ 04-volumes/site/    │ ◄──────────► │ /usr/share/nginx/html     │
 │   index.html        │  SAME files  │  (nginx serves this)      │
 └─────────────────────┘              └───────────────────────────┘
   I edit here ──────────────────────►  the container sees it instantly
```

There is **no copy and no syncing**. Both sides look at the same files. That is
why my page changed from Version 1 to Version 2 with no restart.

```
docker run -d --name site -p 8200:80 -v "$PWD/site:/usr/share/nginx/html" nginx
                              │         │       │
                              │         │       └ the folder inside the container
                              │         └ my folder (full path, in quotes because
                              │           my folder name has a space)
                              └ -p 8200:80 = laptop port 8200 → container port 80
```

### Read-only bind mount

Add `:ro` at the end so the container can look but not change my files:

```
 -v "$PWD/site:/usr/share/nginx/html:ro"
                                     │
                                     └ ro = read-only
```

Good for config files and website files the container should never modify.

### Things to watch

- A bind mount needs a **full path** (`$PWD/site`, not just `site`).
- The folder on my laptop **hides** whatever was at that path in the image. If my
  folder is empty, the container sees an empty folder.
- File permissions on my laptop apply inside the container, which sometimes causes
  `permission denied`.

---

## 9. Which one do I use?

```
 Is it data I must not lose (database, uploads)?
        │
        ├── YES ──► NAMED VOLUME
        │
        └── NO ──► Do I want to edit files on my laptop and see changes live?
                        │
                        ├── YES ──► BIND MOUNT       (development)
                        │
                        └── NO ──► Is it temporary, secret or very fast data?
                                        │
                                        └── YES ──► TMPFS
```

| | Named volume | Bind mount |
|---|---|---|
| Left side of `-v` | A name | A full path |
| Managed by | Docker | Me |
| Typical use | Databases, production | Live code editing, config files |
| Works the same on every machine | Yes | No (needs that folder on that machine) |

In production the code is **baked into the image**, so nothing needs live editing.
Only data goes in volumes.

---

## 10. Safety rules

- `docker rm` deletes the **container only**. A named volume stays.
- `docker volume rm` deletes data **permanently**. Always use the exact name, and
  check `docker volume ls` first.
- Commands like `docker system prune --volumes` can delete volumes that no
  container is using. Do not run them where the data matters.
- A volume with no container attached is **not** garbage. It may hold a database.
- Never edit `/var/lib/docker/volumes/...` by hand.
- To check what a volume holds, attach it to a throwaway container:

```
docker run --rm -v pgdata:/data alpine ls /data
   │       │    │                 │      │  │
   │       │    │                 │      │  └ the folder to list
   │       │    │                 │      └ ls = list files
   │       │    │                 └ a tiny image
   │       │    └ attach the volume at /data
   │       └ --rm = delete this temporary container when it finishes
   └ run
```

---

## 11. What I proved in Lab 04

| Test | What I did | Result |
|------|-----------|--------|
| 1. No volume | Created a table, `docker rm -fv`, started a new container | `relation "notes" does not exist`, data lost |
| 2. Named volume | Same test with `-v pgdata:/var/lib/postgresql/data` | The row `I survive rm` was still there |
| 3. Bind mount | Edited `site/index.html` on my laptop | The page changed with no restart |

In Test 2 the container ID changed from `f8057d06…` to `c871672b…`, which proves the
second container was brand new while the data survived.

---

## 12. If my data is missing: checklist

```
 Data is missing after I recreated a container
        │
        ▼
 1. Did I use -v with a NAME at all?        (no -v = anonymous volume = new empty one)
        ▼
 2. Did I use the SAME volume name both times?   docker volume ls
        ▼
 3. Is the path on the RIGHT correct for this image?
    (Postgres: /var/lib/postgresql/data)
        ▼
 4. Did I run `docker rm -v` or `docker volume rm` on it?
        ▼
 5. Is it a bind mount to a folder that is empty or in the wrong place?
```

| Mistake | What happens | Fix |
|---------|--------------|-----|
| No `-v` | Data looks lost after `rm` | Use a named volume |
| `-v site:/path` instead of a full path | Docker makes a volume called `site` | `-v "$PWD/site:/path"` |
| Wrong path on the right side | The app writes somewhere else | Check the image docs |
| `container name already in use` | A stopped container keeps its name | `docker rm -f NAME` |
| `bash: !': event not found` | `!` inside double quotes confuses Bash | Remove the `!` or run `set +H` |

---

## 13. Self-test

1. Why does data disappear when I `docker rm` a container?
2. What is a volume, in my own picture? Is it a container?
3. Named volume vs bind mount: what is different, and when do I use each?
4. In `-v pgdata:/var/lib/postgresql/data`, what is on the left and what is on the right?
5. How does Docker decide whether the left side is a volume name or a folder?
6. I run `docker rm -fv db-vol`. Does `pgdata` survive? Why?
7. Why was my bind mount page updated without restarting the container?
8. What is the trap of running Postgres with no `-v` at all?
9. What does `docker volume rm` do, and why must I be careful?
10. Why do production systems put code in the image but data in a volume?

### Answers

1. The data lives in the container's writable layer, which is deleted with it.
2. A storage folder outside the container with its own life. It is not a container.
3. Named volume is managed by Docker and used for databases. Bind mount is a folder
   of mine and is used for live editing in development.
4. Left is the volume's name, right is the path inside the container.
5. A name means a named volume, and a full path means a bind mount.
6. Yes, because `-v` in `rm -fv` only removes anonymous volumes, and `pgdata` has a name.
7. There is only one copy of the files and both sides look at it.
8. Docker creates an anonymous volume, and a new container gets a new empty one.
9. It deletes the volume and its data permanently, so use the exact name.
10. Code is the same everywhere, so it is baked into the image. Data changes and must
    survive, so it goes in a volume.
