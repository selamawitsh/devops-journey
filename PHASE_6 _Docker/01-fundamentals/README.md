# Lab 01: Docker Fundamentals

## Goal

Understand the basics of Docker by building my first image from a
Dockerfile and running it as a container.

## What I built

A tiny Node.js web server, packaged as a Docker image
(`my-first-image:v1`), and run as a container that answers HTTP requests.

## How it works

```text
Dockerfile --docker build--> Image --docker run--> Container
                                                      |
        browser/curl --> localhost:8100 --> container port 3000
```

- **Image**: a read-only template (the recipe).
- **Container**: a running instance of an image (the meal).
- **Port mapping** `-p 8100:3000`: host port on the left,
  container port on the right.

## Folder structure

```text
01-fundamentals/
├── README.md
└── my-first-image/
    ├── Dockerfile
    ├── .dockerignore
    └── server.js
```

## Dockerfile explained

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY server.js .
EXPOSE 3000
CMD ["node", "server.js"]
```

| Instruction | Purpose |
|-------------|---------|
| `FROM node:20-alpine` | Start from a small Linux image that includes Node 20 |
| `WORKDIR /app` | Set the working directory inside the image |
| `COPY server.js .` | Copy my code into the image |
| `EXPOSE 3000` | Document the port the app listens on |
| `CMD ["node", "server.js"]` | Command that runs when a container starts |

`RUN` happens at build time. `CMD` happens when the container starts.

## Commands I used

```bash
# Build the image
cd my-first-image
docker build -t my-first-image:v1 .

# List images
docker images

# Run a container (host port 8100 -> container port 3000)
docker run -d -p 8100:3000 --name hello-app my-first-image:v1

# Test it
curl http://localhost:8100
# Output: Hello from my first Docker image!

# Inspect
docker ps
docker logs hello-app
docker exec -it hello-app sh

# Stop and remove the container
docker rm -f hello-app
```

## What I learned

- An image is a template, and a container is a running copy of it.
  One image can start many containers.
- `docker build` needs the path to the Dockerfile folder (the `.` at the end).
- Port mapping is `-p HOST:CONTAINER`.
- `my-first-image:v1` is 136 MB, about the same as the `node:20-alpine`
  base image, because my app only adds one small file on top.
- Docker reuses unchanged build steps. During the build, the
  `WORKDIR` step printed `Using cache`.
- `.dockerignore` keeps files such as `.env` and `node_modules` out of the image.

## Mistakes and fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| `docker build` said it requires 1 argument | I forgot the `.` at the end | `docker build -t my-first-image:v1 .` |
| `curl` returned `Connection reset by peer` | I mapped the wrong container port (`8100:300`) | Use `8100:3000`, matching the port in `server.js` |
| Same error right after starting | I ran `curl` before the app finished starting | Wait a second after `docker run -d`, then test |

Debugging order that worked: `docker ps`, then `docker logs`, then check the
code and the port mapping.

## Notes

The build printed a warning that the legacy builder is deprecated and
BuildKit (buildx) is not installed. The build still works.

## Future improvements

- Run the app as a non-root user.
- Add an app with dependencies and show build caching with `npm install`.
- Compare image sizes using multi-stage builds (Lab 02).
- Push the image to a registry with version tags (Lab 05).
