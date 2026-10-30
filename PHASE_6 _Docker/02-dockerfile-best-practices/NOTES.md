
---

## 13. Dockerfile best practices and multi-stage builds

### The problem: one image carries the whole kitchen

```
 SINGLE STAGE                       MULTI-STAGE
┌────────────────────┐             ┌──────────────┐   ┌────────────────┐
│ compiler + tools   │             │ Stage 1:     │   │ Stage 2:       │
│ + source code      │             │ compiler +   │──►│ tiny base +    │
│ + my program       │             │ source       │   │ only the       │
│                    │             │ (discarded)  │   │ finished       │
│ 304 MB             │             └──────────────┘   │ program        │
└────────────────────┘                                │ 10.2 MB        │
                                                      └────────────────┘
```

You do not need the kitchen to eat the meal. Cook in one stage, serve from a clean one.

My result: **304 MB to 10.2 MB** (about 30 times smaller) for the same Go app.

### The multi-stage Dockerfile

```dockerfile
FROM golang:1.25-alpine AS builder         # stage 1, named "builder"
WORKDIR /app
COPY go.mod main.go ./
RUN CGO_ENABLED=0 go build -o server .     # compile the program

FROM gcr.io/distroless/static-debian12:nonroot   # stage 2: a brand new, clean image
COPY --from=builder /app/server /server    # take ONLY the finished program
EXPOSE 3000
CMD ["/server"]
```

| Piece | Meaning |
|-------|---------|
| `AS builder` | Gives a stage a name |
| second `FROM` | Starts a fresh, clean image. Only the **last** stage becomes the final image |
| `COPY --from=builder` | Reaches back into an earlier stage and copies only the files I choose |
| `CGO_ENABLED=0` | Builds a self-contained program that needs no system libraries, so it can run on a tiny image |
| `-f Dockerfile.multi` | Tells `docker build` which Dockerfile to use when it is not named `Dockerfile` |

### Choosing a base image

| Base | Size | Has a shell? | Use for |
|------|------|--------------|---------|
| `node:20` / full Debian | Big | Yes | Easy debugging, but heavy |
| `-slim` | Medium | Yes | Good balance |
| `-alpine` | Small | Yes (`sh`) | Most production images |
| `distroless` | Very small | **No** | Production, maximum safety |
| `scratch` | Empty | No | Self-contained programs (Go) |

- Smaller means faster to pull and start, and less to attack.
- `nonroot` means the program runs as an unprivileged user, not as root.
- Distroless has no shell, so `docker exec -it NAME sh` fails. That is a safety feature,
  but it makes debugging harder (see Lab 07).

### Best practices checklist

1. **Use multi-stage builds** for anything that needs compiling or building.
2. **Pick a small base image** and **pin its version** (`golang:1.25-alpine`, not `latest`).
3. **Order steps from rarely changing to often changing**, so the build cache is reused
   (dependencies first, source code last).
4. **Copy only what you need**, and use a `.dockerignore`
   (`.git`, `node_modules`, `.env`, logs).
5. **Run as non-root** whenever possible.
6. **Never put secrets in an image.** Pass them at run time with `-e` or a secrets tool.
7. **One program per container.**
8. **Combine related commands in one `RUN`** when it makes sense, so fewer unnecessary
   steps are saved.

### Why it matters

- **Faster:** small images pull, deploy and start quickly.
- **Safer:** no compiler, shell or package manager inside means fewer tools for an attacker.
- **Cheaper:** less storage and network traffic in registries and servers.

### What I saw in the build output

```
Step 2/8 ... ---> Using cache      (reused from the single-stage build)
Step 5/8 : FROM distroless ...     (the clean "second kitchen" begins here)
Step 6/8 : COPY --from=builder ... (only the program is carried over)
```