# Topic 2: The Dockerfile — FROM, WORKDIR, COPY, RUN, CMD

## What is a Dockerfile?

A Dockerfile is a **plain text file** (named `Dockerfile` with no extension) that contains a series of instructions. Docker reads these instructions line by line and executes them to **build an image**.

Think of it as a recipe or a blueprint:
- You write the Dockerfile (the recipe)
- Docker follows it to create an image (the finished dish, frozen and portable)
- From that image, you can create as many containers as you want (serving the dish)

**The entire purpose of a Dockerfile is to build an image of your application.**

---

## Why Do We Need a Dockerfile?

Without a Dockerfile, you would have to:
1. Manually start a base image
2. Manually enter the container
3. Manually install dependencies
4. Manually copy your code
5. Manually configure everything
6. Manually save the result as a new image

This is slow, error-prone, and impossible to automate. A Dockerfile makes the entire process:
- **Repeatable** — same result every time
- **Version-controllable** — you can track changes in Git
- **Shareable** — anyone with the Dockerfile can build the exact same image
- **Automated** — CI/CD pipelines can build images automatically

---

## The Five Core Instructions

### 1. FROM — Choose Your Base Image

```dockerfile
FROM golang:1.22-alpine

What it does:

    Every Dockerfile must start with FROM

    It specifies the base image — the starting point for your build

    You don't build from nothing; you stand on the shoulders of existing images

Why we use it:

    Saves enormous time — you don't need to install an OS, a language runtime, or basic tools

    The base image already has Go (or Node, Python, etc.) installed and configured

How we chose our base image:

    golang — the official Go language image

    1.22 — a specific version tag. Never use latest in production because it changes unexpectedly and breaks your build

    -alpine — based on Alpine Linux, a tiny (~5MB) Linux distribution. This makes our final image much smaller

Common base images:

Base Image	        What It Provides
node:18-alpine	    Node.js 18 on Alpine Linux
python:3.12-slim	Python 3.12 on slim Debian
golang:1.22-alpine	Go 1.22 on Alpine Linux
nginx:1.25-alpine	Nginx web server on Alpine
alpine:3.19	        Just Alpine Linux, nothing else
scratch	Empty image — for static binaries only



### 2. WORKDIR — Set the Working Directory

dockerfile
WORKDIR /app

What it does:

Sets the current working directory inside the container for all following instructions

If the directory doesn't exist, Docker creates it automatically

Why we use it:

Without it, all commands run in / (the root directory), and your files get scattered everywhere

Keeps your application organized in one place

All subsequent commands (RUN, COPY, CMD) execute relative to this directory

Much cleaner than writing cd /app && some-command repeatedly

What happens if you don't use WORKDIR:

dockerfile
# Bad — without WORKDIR
COPY . /app
RUN cd /app && go build -o my-app .
CMD ["/app/my-app"]  # You have to use full paths everywhere
dockerfile
# Good — with WORKDIR
WORKDIR /app
COPY . .
RUN go build -o my-app .
CMD ["./my-app"]  # Clean, relative paths


3. COPY — Bring Files Into the Image
dockerfile
COPY go.mod .
COPY . .
What it does:

Copies files and directories from your host machine (your laptop) into the image

Syntax: COPY <source-on-host> <destination-in-image>

The destination can be absolute (/app/server.go) or relative to WORKDIR

Files become a permanent part of the image

Why we copy go.mod first:
This is a critical optimization called layer caching. Dependencies (listed in go.mod or package.json) change much less frequently than your application code. By copying the dependencies file first and downloading dependencies in a separate step, Docker can cache that layer. When you change your source code but not your dependencies, the slow download step is skipped — it uses the cache instead.

The pattern:

dockerfile
COPY go.mod .          # Copy dependencies list first (changes rarely)
RUN go mod download    # Download dependencies (slow, but cached)
COPY . .               # Copy everything else (changes often)
COPY vs ADD:

Instruction	What It Does	When To Use
COPY	Copies files from host to image	Always — this is the default choice
ADD	Same as COPY, plus auto-extracts tar files and can fetch URLs	Only when you specifically need tar extraction or URL fetching
Interview point: Docker's official best practice is to use COPY unless you specifically need ADD's extra features. COPY is simpler, more predictable, and makes your intent clearer.

4. RUN — Execute Commands During Build
dockerfile
RUN go mod download
RUN go build -o dockerfile-basics .
What it does:

Executes a command inside the image at build time

The result (files created, packages installed) becomes a permanent layer in the image

Each RUN creates one new layer

Why we use it:

To install dependencies (go mod download, npm install, pip install)

To compile code (go build, npm run build)

To set up configuration

To do anything that needs to be baked into the image

Why chain commands with &&:

dockerfile
# Bad — creates 3 separate layers, bigger image
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# Good — creates 1 layer, smaller image, prevents caching issues
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*
Each RUN creates a layer. More layers = bigger image. Chaining related commands reduces layers and ensures they always run together (avoiding cache inconsistencies).

Critical rule: Always combine apt-get update and apt-get install in the same RUN command. If they're separate, the update layer could be cached and become stale, causing the install to fail with 404 errors for outdated package URLs.

5. CMD — Define the Default Command
dockerfile
CMD ["./dockerfile-basics"]
What it does:

Specifies the default command to run when a container starts from this image

It's the default — users can override it when running the container

Only one CMD per Dockerfile. If you write multiple, only the last one takes effect

The two forms:

dockerfile
# Exec form (preferred) — runs the binary directly
CMD ["./my-app"]

# Shell form — runs inside /bin/sh -c
CMD ./my-app
Why we use the exec form:

The binary runs as PID 1 directly, so it receives OS signals properly

Shell form wraps the command in a shell, which can cause signal handling issues

Exec form is the recommended best practice

CMD vs ENTRYPOINT:

Instruction	Purpose	Can Be Overridden?
CMD	Default command for the container	Yes — docker run my-image other-command
ENTRYPOINT	Mandatory command that always runs	Only with --entrypoint flag
dockerfile
# CMD only — fully overridable
CMD ["go", "run", "main.go"]
# docker run my-image /bin/bash  ← runs bash instead

# ENTRYPOINT + CMD — CMD becomes default arguments
ENTRYPOINT ["go", "run"]
CMD ["main.go"]
# docker run my-image                ← runs "go run main.go"
# docker run my-image test.go        ← runs "go run test.go"