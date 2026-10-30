# Lab 03: Container Networking

## Goal

Understand how containers find and talk to each other, and prove the rules
with experiments.

## Idea

```
 lab-net (custom bridge):  [ visitor ] --"web"--> [ web ]    works
 default bridge:           [ visitor ] --"web"-->    ?       bad address
```

On a network I create myself, Docker runs a small DNS service, so containers
can call each other by name. The default bridge has no name lookup.

## Experiments and results

| Test | Command | Result |
|------|---------|--------|
| Same network, by name | `docker run --rm --network lab-net alpine:3.22 wget -qO- http://web` | Worked, got the nginx page |
| Default network, by name | `docker run --rm alpine:3.22 wget -qO- http://web` | `bad address 'web'` |
| Same network, by IP | `... wget -qO- http://172.22.0.2` | Worked, but the IP can change |
| `--network none` | `docker run --rm --network none alpine:3.22 ip addr` | Only `lo` (127.0.0.1), fully isolated |
| `--network host` | `docker run --rm --network host alpine:3.22 ip addr` | Saw the laptop's real interfaces, no isolation |

## Commands I used

```bash
docker network create lab-net
docker run -d --name web --network lab-net nginx
docker run --rm --network lab-net alpine:3.22 wget -qO- http://web | head -5
docker run --rm alpine:3.22 wget -qO- http://web
docker network inspect lab-net
docker run --rm --network none alpine:3.22 ip addr
docker run --rm --network host alpine:3.22 ip addr | grep inet

# cleanup
docker rm -f web
docker network rm lab-net
```

## What I saw

- `docker network inspect lab-net` listed `web` under `Containers` with an IP
  (`172.22.0.2`). Before `web` was running, the list was empty (`{}`).
- Each Docker network is a virtual switch on the host. `lab-net` appeared as
  `br-9468a56c1b9c` (`172.22.0.1`), matching the network ID.
- With `--network host` the container shares the laptop's network stack
  (Wi-Fi, `docker0`, all the bridges).

## Network types

| Type | What it does | When to use |
|------|--------------|-------------|
| `bridge` (custom) | Private network, own IPs, name lookup | Almost always |
| `bridge` (default) | Private network, but no name lookup | Avoid |
| `host` | Shares the host's network, no isolation | Rare, special cases |
| `none` | No network | Isolated jobs |

## Rules I learned

1. Same network means containers can talk.
2. Use the container **name** as the address (IPs change).
3. `localhost` inside a container means that container itself.
4. `-p` is only for letting things outside Docker in. Containers on the same
   network do not need it.

## Mistakes and fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| `wget: bad address 'web'` | The `web` container had stopped (exited after a restart), so the network was empty | `docker ps -a`, then `docker start web` |
| `wget` typo | Typed `-q0-` and `htt:://` | Capital letter O in `-qO-`, and `http://` |
| `docker run alpine` failed to pull | DNS problem on my internet connection (`server misbehaving`) | Use an image already on the machine, e.g. `alpine:3.22` |

## Future improvements

- Run an app and a database on the same network and connect by name.
- Test an `--internal` network that has no internet access.
- Try overlay networks (needed with Docker Swarm and Kubernetes-style setups).
