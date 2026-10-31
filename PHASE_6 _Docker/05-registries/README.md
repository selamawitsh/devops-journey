# Lab 05: Image Registries and Tagging

## Goal

Tag an image with proper version numbers, push it to a registry, and prove that
it can be pulled back and run from there.

## Idea

```
 laptop ──docker push──► REGISTRY ──docker pull──► any server ──run──► container
```

A registry is a warehouse for images, like GitHub is for code. Pushing needs a login.
Pulling a public image does not.

## How an image name is built

```
 ghcr.io / selamawitsh / go-hello : 1.0.0
    │           │            │        │
    │           │            │        └ tag (version)
    │           │            └ image name
    │           └ my GitHub username (the shelf)
    └ registry (GitHub Container Registry)
```

## Tagging strategy (semantic versioning)

```
 1 . 0 . 0
 │   │   └ PATCH: bug fix
 │   └ MINOR: new feature, compatible
 └ MAJOR: breaking change
```

| Tag | Meaning | Changes? |
|-----|---------|----------|
| `1.0.0` | Exactly this release | Never |
| `1.0` | Latest patch of 1.0 | With each 1.0.x |
| `1` | Latest of major version 1 | With each 1.x.x |
| `latest` | Newest release | With every release |

Servers should pin an exact version (`1.0.0`). `latest` is a moving label.

## What I did

Starting from the multi-stage image of Lab 02 (`go-hello:multi`, 10.2 MB):

1. Added version tags with `docker tag`. All tags shared one image ID
   (`6f5ab802f7fb`), which proves tags are labels and not copies.
2. Added the registry address in front of the name (`ghcr.io/selamawitsh/go-hello`).
3. Created a personal access token with the `write:packages` scope.
4. Logged in with `docker login`.
5. Pushed `1.0.0` and `latest`.
6. Deleted the image from my laptop, pulled it back from the registry and ran it.

## Commands I used

```bash
# tags
docker tag go-hello:multi go-hello:1.0.0
docker tag go-hello:multi go-hello:1.0
docker tag go-hello:multi go-hello:1
docker tag go-hello:multi go-hello:latest

# registry names
GH_USER=selamawitsh
docker tag go-hello:multi ghcr.io/$GH_USER/go-hello:1.0.0
docker tag go-hello:multi ghcr.io/$GH_USER/go-hello:latest

# login (the token is typed into a silent prompt, never into the command)
read -s -p "Paste token: " CR_PAT
echo $CR_PAT | docker login ghcr.io -u $GH_USER --password-stdin
unset CR_PAT

# push
docker push ghcr.io/$GH_USER/go-hello:1.0.0
docker push ghcr.io/$GH_USER/go-hello:latest

# prove it travelled
docker rmi -f 6f5ab802f7fb
docker pull ghcr.io/$GH_USER/go-hello:1.0.0
docker run -d -p 8300:3000 --name go-from-registry ghcr.io/$GH_USER/go-hello:1.0.0
curl http://localhost:8300

# cleanup
docker rm -f go-from-registry
docker logout ghcr.io
```

## What I saw

- First push: 13 layers, all `Pushed`.
- Second push (`latest`): all 13 layers said `Layer already exists`, and the digest
  was identical to the first push. Two tags, one image.
- Pulling back: 12 layers were `Already exists` (shared with the base image still on
  my laptop) and only 1 layer was downloaded: the one holding my program.
- The package appeared under the **Packages** tab of my GitHub profile, private by default.

## What I learned

- A registry stores images. Push needs authentication, and a private image needs it to pull too.
- A token is safer than a password: it has limited permissions, expires, and can be revoked.
- A digest (`sha256:...`) is the fingerprint of the image content. A tag is only a label.
- Layers are shared, so Docker uploads and downloads only what is missing.
- `--password-stdin` keeps the token out of the shell history.

## Mistakes and fixes

| Problem | Cause | Fix |
|---------|-------|-----|
| `cannot perform an interactive login from a non TTY device` | I typed the token inside the quotes of the prompt text, so the variable stayed empty | Press Enter first, then paste the token at the silent prompt |
| Token exposed | The token ended up on screen and in my terminal history | Revoked it on GitHub immediately, created a new one, cleared the history |

Security rule: a token goes only into a silent prompt, never into a chat, a command,
a file or a commit.

## Future improvements

- Build and push automatically from GitHub Actions (CI/CD phase).
- Make the package public, or compare public and private pulls.
- Scan the image for vulnerabilities (Trivy) before pushing.
- Push multi-architecture images.
