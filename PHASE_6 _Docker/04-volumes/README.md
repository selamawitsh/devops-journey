# Lab 04: Volumes and Persistent Data

## Goal

Prove that data stored inside a container is lost when the container is
removed, and that data stored in a volume survives.

## Idea

```
 WITHOUT a volume                      WITH a volume

 ┌──────────────┐                      ┌──────────────┐
 │  container   │                      │  container   │
 │  ┌────────┐  │                      │              │
 │  │ my data│  │   rm: data gone      │              │──► [ VOLUME ] my data
 │  └────────┘  │                      └──────────────┘     survives rm
 └──────────────┘
```

A container keeps its data in a thin writable layer that is deleted with the
container. A volume is storage outside the container with its own life.

## Experiments and results

| Test | What I did | Result |
|------|-----------|--------|
| 1. No volume | Created a table in Postgres, ran `docker rm -fv`, started a new container | `relation "notes" does not exist`, the data was lost |
| 2. Named volume | Same test with `-v pgdata:/var/lib/postgresql/data` | The row `I survive rm` was still there in a new container |
| 3. Bind mount | Served a local folder with nginx, edited the file on my laptop | The page changed from Version 1 to Version 2 without restarting |

In Test 2 the container ID changed (`f8057d06...` to `c871672b...`), proving
the second container was brand new while the data stayed.

## Commands I used

```bash
# Test 1: no volume
docker run -d --name db-novol -e POSTGRES_PASSWORD=secret postgres:17
docker exec db-novol psql -U postgres -c "CREATE TABLE notes (id serial, text varchar(50)); INSERT INTO notes (text) VALUES ('hello');"
docker rm -fv db-novol
docker run -d --name db-novol -e POSTGRES_PASSWORD=secret postgres:17
docker exec db-novol psql -U postgres -c "SELECT * FROM notes;"     # error

# Test 2: named volume
docker volume create pgdata
docker run -d --name db-vol -e POSTGRES_PASSWORD=secret -v pgdata:/var/lib/postgresql/data postgres:17
docker exec db-vol psql -U postgres -c "CREATE TABLE IF NOT EXISTS notes (id serial, text varchar(50)); INSERT INTO notes (text) VALUES ('I survive rm');"
docker rm -fv db-vol
docker run -d --name db-vol -e POSTGRES_PASSWORD=secret -v pgdata:/var/lib/postgresql/data postgres:17
docker exec db-vol psql -U postgres -c "SELECT * FROM notes;"       # row is still there
docker volume inspect pgdata

# Test 3: bind mount
mkdir site && echo "<h1>Version 1</h1>" > site/index.html
docker run -d --name site -p 8200:80 -v "$PWD/site:/usr/share/nginx/html" nginx
curl http://localhost:8200
echo "<h1>Version 2</h1>" > site/index.html
curl http://localhost:8200

# Cleanup
docker rm -fv site db-vol
docker volume rm pgdata
```

## Reading the `-v` flag

```
-v pgdata : /var/lib/postgresql/data
     │              │
     │              └ path inside the container
     └ name of the volume (or a folder path for a bind mount)
```

## Named volume vs bind mount

| | Named volume | Bind mount |
|---|---|---|
| Left side of `-v` | A name (`pgdata`) | A full path (`$PWD/site`) |
| Who manages it | Docker | Me |
| Where it lives | `/var/lib/docker/volumes/pgdata/_data` | Any folder I choose |
| Use for | Database data, production | Live editing in development |

There is only one copy of the files in a bind mount. The laptop and the container
look at the same folder, so edits show up immediately.

## What I learned

- Removing a container does not remove a named volume. `docker rm -v` only removes
  anonymous volumes (volumes without a name).
- `docker volume inspect` shows the `Mountpoint`, the real folder on my disk.
- A bind mount needs a full path. A bare name like `site` would be treated as a
  volume name.
- `docker volume rm` deletes data permanently, so I use the exact name.

## Mistakes and fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| `container name "/db-vol" is already in use` | A stopped container still holds its name | `docker rm -fv db-vol`, then run again |
| `bash: !': event not found` | A `!` inside double quotes triggers Bash history expansion, so the whole command never ran | Remove the `!` (or run `set +H`) |
| `relation "notes" does not exist` after the failed command | The table was never created because of the Bash error | Re-run the create command |

## Future improvements

- Back up and restore a volume with `tar`.
- Try a read-only bind mount (`:ro`).
- Try a tmpfs mount (data kept in memory only).
- Use volumes in Docker Compose (Phase 7).
