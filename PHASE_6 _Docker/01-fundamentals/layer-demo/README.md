# Layer demo: how Docker reuses build steps

## Goal

Understand image layers by watching Docker reuse and rebuild steps.

## Dockerfile

```dockerfile
FROM alpine:3.22
RUN echo "I am layer 2, changed" > /file2.txt
RUN echo "I am layer 3, changed" > /file3.txt
```

## Idea

Docker saves a checkpoint (a layer) after every Dockerfile step.
On the next build, if a step and everything above it are unchanged,
Docker reuses the saved checkpoint instead of running the step again.

## Experiment

| Build | What I changed | Result |
|-------|----------------|--------|
| v1 | First build | All steps ran |
| v2 | Changed the last step only | Step 2 said `Using cache`, only step 3 reran |
| v3 | Changed step 2 | Step 2 and step 3 both reran |

## Commands

```bash
docker build -t layer-demo:v1 .
docker history layer-demo:v1
docker build -t layer-demo:v2 .    # after editing the last line
docker run --rm layer-demo:v2 cat /file2.txt /file3.txt
docker build -t layer-demo:v3 .    # after editing step 2
```

## What I saw

- `docker history` showed one row per step. Each of my `RUN` layers was
  only 13 bytes, because a layer holds only what that step added.
- The same ID (`b0962e99be2e`) appeared in v1 and v2 for step 2,
  which proves the layer was reused.
- A container sees all layers combined: both files were present.

## What I learned

- A layer is one saved step. An image is the layers stacked together.
- If a step changes, that step and every step after it are rebuilt.
- So order matters: put slow steps that change rarely (like installing
  dependencies) at the top, and things that change often (my code) at the bottom.
- This makes rebuilds fast, and layers are shared between images to save disk space.
