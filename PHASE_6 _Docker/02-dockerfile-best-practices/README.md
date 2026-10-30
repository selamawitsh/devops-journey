# Lab 02: Dockerfile Best Practices (multi-stage build)

## Goal

Shrink a Docker image by using a multi-stage build, and measure the difference.

## What I built

A tiny Go web server, built into two images:

- `go-hello:single` (one stage, includes the Go compiler)
- `go-hello:multi` (two stages, only the compiled program ships)

## Idea

```
 Stage 1 "builder": Go compiler + source  -> builds /app/server
                         |  COPY --from=builder (only the program)
 Stage 2 "final": tiny distroless image + /server   <- this becomes the image
```

Everything in stage 1 is discarded. Only the last stage becomes the image.

## Folder structure

```
02-dockerfile-best-practices/
├── README.md
└── go-hello/
    ├── main.go
    ├── go.mod
    ├── Dockerfile.single
    └── Dockerfile.multi
```

## Result

| Image | Base | Size |
|-------|------|------|
| `go-hello:single` | `golang:1.25-alpine` | 304 MB |
| `go-hello:multi` | `distroless/static-debian12:nonroot` | 10.2 MB |

About 30 times smaller, with identical behavior.

## Commands I used

```bash
docker build -f Dockerfile.single -t go-hello:single .
docker run -d -p 8300:3000 --name go-single go-hello:single
curl http://localhost:8300

docker build -f Dockerfile.multi -t go-hello:multi .
docker images go-hello

docker rm -f go-single
docker run -d -p 8300:3000 --name go-multi go-hello:multi
curl http://localhost:8300
docker exec -it go-multi sh     # fails: there is no shell in the image
```

## Why the multi-stage version is better

- **Smaller:** faster to pull, store and start.
- **Safer:** no compiler, shell or package manager inside, so there is less
  for an attacker to use.
- **Runs as non-root:** the `nonroot` base image runs the app as an
  unprivileged user.
- `CGO_ENABLED=0` builds a self-contained program that needs no system libraries,
  which is what lets it run on an almost empty image.

## What I learned

- A second `FROM` starts a fresh image. `COPY --from=builder` takes only what I choose
  from the previous stage.
- Docker reused the first build steps (`Using cache`) in the second build
  because they were identical.
- Distroless images have no shell, so `docker exec -it NAME sh` does not work.
  Debugging needs a different approach (see Lab 07).

## Mistakes and fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| Build said `Dockerfile.multi: no such file` | I had not created the file yet | Create it, then rebuild |
| `docker run` said `pull access denied` | The image did not exist because the build failed, so Docker searched Docker Hub | Fix the first error (the build) first |

When several errors appear, fix the first one. The rest are usually a chain reaction.

## Future improvements

- Add a `.dockerignore`.
- Add a healthcheck.
- Try `FROM scratch` as the final stage and compare the size.
- Apply the same pattern to a real service from my own backend.
