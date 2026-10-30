# Container Networking: My Notes

Written from zero. Read top to bottom the first time.

## Contents

1. The problem
2. Every container lives in its own room
3. A network is a building
4. Names instead of numbers
5. The localhost trap
6. Three directions of traffic
7. Which address do I use?
8. Custom vs default network
9. Network types
10. What I proved in Lab 03
11. If it doesn't work: checklist
12. Self-test

---

## 1. The problem

My app and my database are in **different containers**. How does the app find
the database?

```
   [ my-app ]  ──── ??? ────  [ database ]
```

Docker's answer is a **network**.

---

## 2. Every container lives in its own room

By default a container is isolated. It gets its **own network world**:

```
 ┌─────────────────────┐        ┌─────────────────────┐
 │ CONTAINER A         │        │ CONTAINER B         │
 │ own IP: 172.22.0.3  │        │ own IP: 172.22.0.2  │
 │ own "localhost"     │        │ own "localhost"     │
 │ own ports           │        │ own ports           │
 └─────────────────────┘        └─────────────────────┘
```

- Each container has its own IP address, its own ports and its own `localhost`.
- Container A's port 3000 and container B's port 3000 never clash, because they
  are in different rooms.
- Because they are separate rooms, they need a **connection** to talk.

---

## 3. A network is a building

A Docker network is like a **building with an intercom**. Containers that live in
the same building can call each other.

```
 ┌──────────────────── network "lab-net" ────────────────────┐
 │                                                           │
 │   ┌───────────┐    ┌───────────┐    ┌───────────┐         │
 │   │    web    │    │    db     │    │  my-app   │         │
 │   │172.22.0.2 │    │172.22.0.3 │    │172.22.0.4 │         │
 │   └───────────┘    └───────────┘    └───────────┘         │
 │          all of them can reach each other                 │
 └───────────────────────────────────────────────────────────┘

 ┌────────────────────┐
 │ container elsewhere│   ✗ different building, cannot see the ones above
 └────────────────────┘
```

Under the hood, a Docker network is a **virtual switch** on my laptop. I saw it
in `ip addr` as `br-9468a56c1b9c` with the address `172.22.0.1`. That is the
building's front desk, called the **gateway**.

```
 my laptop
 ├── wlp0s20f3   192.168.103.35   (real Wi-Fi)
 ├── docker0     172.17.0.1       (the default bridge)
 └── br-9468…    172.22.0.1       (my lab-net, a virtual switch)
```

**Rule 1: same network means they can talk.**

---

## 4. Names instead of numbers

Every container gets an IP address, but the IP **changes** when the container is
recreated. So Docker adds a phone book.

```
 my-app: "I want to call  db"
            │
            ▼
   Docker's built-in DNS (inside every container at 127.0.0.11)
            │  looks up the name "db"
            ▼
   "db is 172.22.0.3"
            │
            ▼
 my-app connects to 172.22.0.3
```

This is the same DNS idea as in my networking labs, but private to the network.

```
 http://web              ✓ the name always works
 http://172.22.0.2       ✗ works today, breaks when the container is recreated
```

**Rule 2: use the container's name as the address.**

Important: the phone book exists **only on a custom network** (one I create with
`docker network create`). The default network has no phone book (section 8).

---

## 5. The localhost trap

Inside a container, `localhost` means **that same container**. It never means my
laptop and never means another container.

```
 ┌──────────────── container "my-app" ───────────────┐
 │                                                   │
 │   DB_HOST=localhost   ───►  looks inside my-app   │
 │                             itself ✗ (no database)│
 │                                                   │
 └───────────────────────────────────────────────────┘

 ┌──────────────── container "my-app" ───────────────┐
 │                                                   │
 │   DB_HOST=db   ───►  asks Docker for "db"  ✓      │───► container "db"
 │                                                   │
 └───────────────────────────────────────────────────┘
```

**Rule 3: between containers, never use `localhost`. Use the other container's
name.** This is the most common bug when connecting services.

---

## 6. Three directions of traffic

There are three different directions, and each works differently.

```
 ① OUTSIDE ──► container       needs  -p  (publish a port)
 ② container ──► container     needs  same network + name (no -p)
 ③ container ──► internet      works by default (through the laptop)
```

### ① From my browser into a container: `-p`

```
   browser ─► localhost:8100 ─► [ door 8100 → 3000 ] ─► app in container

   docker run -d -p 8100:3000 my-app
                    │     │
              laptop side  container side
```

Left is where I stand, right is where I go.

### ② Container to container: network and name

```
   my-app ──► http://web:80 ──► web container
```

No `-p` needed.

**Important:** use the container's **own internal port**, not the published one.

```
   docker run -d --name db --network lab-net -p 5434:5432 postgres:17

   from my laptop:          localhost:5434    (the published port)
   from my-app container:   db:5432           (the internal port, NOT 5434)
```

### ③ Container to the internet

A container can reach out (for example to download packages). Its traffic leaves
through the laptop, which translates the address (NAT), the same idea as my home router.

```
   container 172.22.0.3 ─► laptop (NAT) ─► internet
```

### Safety habit

Do **not** publish a database port unless I need it from my laptop. Other
containers don't need it. If I do publish it, bind it to my own machine only:

```
   -p 127.0.0.1:5434:5432     ✓ only my laptop can connect
   -p 5434:5432               ✗ anyone on my network can connect
```

---

## 7. Which address do I use?

| From | To | Address to use |
|------|----|----------------|
| My browser or curl on the laptop | A container | `localhost:HOST_PORT` (the left number of `-p`) |
| A container | A container on the same network | `http://NAME:CONTAINER_PORT` |
| A container | The laptop itself (Linux) | `host.docker.internal`, with `--add-host=host.docker.internal:host-gateway` |
| A container | The internet | Normal address, works by default |

---

## 8. Custom network vs default network

```
 DEFAULT bridge (docker0)             CUSTOM bridge (docker network create)
┌───────────────────────┐            ┌───────────────────────────────┐
│ containers can reach  │            │ containers can reach each     │
│ each other by IP only │            │ other by IP and by NAME ✓     │
│ no phone book ✗       │            │ built-in phone book (DNS)     │
└───────────────────────┘            └───────────────────────────────┘
```

> If I start containers with no `--network`, they land on the default network
> and cannot find each other by name. **Always create my own network.**

---

## 9. Network types

| Type | Picture | What it does | Use |
|------|---------|--------------|-----|
| custom `bridge` | private building with a phone book | Own IPs, name lookup | Almost always |
| default `bridge` | private building, no phone book | Own IPs, no names | Avoid |
| `host` | no walls at all | Container uses the laptop's network directly | Rare |
| `none` | a sealed room | Only `lo` (127.0.0.1), no way in or out | Isolated jobs |

```
 bridge:  container ─[ own IP, behind a door ]─► laptop ─► world
 host:    container shares the laptop's network, no isolation
 none:    container has no network at all
```

A container can also join more than one network (`docker network connect`). For
example, a backend can sit on a "frontend" network and a "database" network, while
the database is only on the second one.

---

## 10. What I proved in Lab 03

| Test | Result | Why |
|------|--------|-----|
| Visitor on `lab-net` calls `web` | Worked | Same network, Docker DNS found the name |
| Visitor on the default network calls `web` | `bad address 'web'` | Different network, and the default bridge has no name lookup |
| Visitor on `lab-net` calls the IP | Worked | But the IP can change |
| `--network none` | Only `lo` | No network |
| `--network host` | Saw the laptop's real interfaces | No isolation |
| `docker network inspect` | Listed `web` and its IP | Shows who lives in the building |

Earlier, my first test failed with `bad address 'web'` for a different reason: the
`web` container had **stopped** after a restart, so the network was empty
(`"Containers": {}`).

---

## 11. If it doesn't work: checklist

```
 Can't reach a container?
        │
        ▼
 1. Is it running?                   docker ps -a      (start it if Exited)
        ▼
 2. Is it on the right network?      docker network inspect NET
        ▼
 3. Am I using its NAME, not localhost?
        ▼
 4. Am I using the container's own port (not the published one)?
        ▼
 5. From my laptop: is the -p mapping correct? (count the digits)
        ▼
 6. Did the app finish starting?     docker logs NAME
```

Commands:

```bash
docker network create NET
docker network ls
docker network inspect NET            # who is on it, and their IPs
docker network connect NET NAME       # add a running container
docker run --network NET ...
docker network rm NET
```

---

## 12. Self-test

1. Why can't two separate containers talk by default?
2. What is a Docker network, in my own picture?
3. Why use a container name instead of an IP?
4. Inside a container, what does `localhost` mean?
5. When do I need `-p`, and when don't I?
6. A Postgres container runs with `-p 5434:5432`. Which port does another
   container on the same network use?
7. Why did calling `web` fail from the default network?
8. What is the difference between `--network host` and `--network none`?
9. A container can't be found by name. What do I check first?

### Answers

1. Each container lives in its own isolated network room.
2. A building with an intercom: containers inside it can call each other.
3. IPs change when a container is recreated, names stay the same.
4. That same container itself.
5. `-p` is for traffic from outside Docker (my browser) into a container. Containers on
   the same network don't need it.
6. `5432`, the container's internal port, using the name (for example `db:5432`).
7. It was on a different network, and the default bridge has no name lookup.
8. `host` shares the laptop's network with no isolation. `none` gives no network at all.
9. Is the target container running, and is it on the same custom network?
