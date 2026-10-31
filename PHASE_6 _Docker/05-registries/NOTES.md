# Registries, Tags and Pushing Images: My Notes

Written from zero. Read top to bottom the first time.

## Contents

1. The problem
2. The registry
3. Registry vs GitHub
4. Anatomy of an image name
5. Tags are stickers
6. Version numbers (semver)
7. Tag vs digest
8. Login and tokens
9. Push and pull, step by step
10. Public vs private, and which registry
11. Security rules
12. What I proved in Lab 05
13. If it doesn't work: checklist
14. Self-test

---

## 1. The problem

Everything I build exists only on **my laptop**. A server cannot run an image
that it cannot get.

```
 my laptop                              a server somewhere
 ┌──────────────────────────┐          ┌──────────────────────────┐
 │ docker images            │          │ "go-hello? never heard   │
 │   go-hello:multi         │   ???    │  of it"                  │
 └──────────────────────────┘          └──────────────────────────┘
```

---

## 2. The registry

A **registry** is a warehouse for images. I upload an image once, and any machine
that is allowed to can download it.

```
 my laptop                 REGISTRY                   the server
 ┌─────────┐   push      ┌───────────┐    pull       ┌─────────┐
 │  image  │ ──────────► │ warehouse │ ────────────► │  image  │ ──run──► container
 └─────────┘             │ of images │               └─────────┘
                         └───────────┘
```

- A registry stores **images**, not containers.
- `docker push` uploads. `docker pull` downloads.
- Docker Hub is the biggest public registry. I used it every time I ran
  `docker run nginx` or `docker pull postgres:17`.
- Downloading a public image needs no account. **Uploading always needs a login.**

---

## 3. Registry vs GitHub

```
                 GitHub                      Registry
 stores          code                        images
 upload          git push                    docker push
 download        git pull / git clone        docker pull
 proves who I am saved credentials           docker login (saved credentials)
 versions        commits, tags               image tags
```

Same idea, different thing stored.

---

## 4. Anatomy of an image name

The full name tells Docker **where** the image lives.

```
   ghcr.io / selamawitsh / go-hello : 1.0.0
      │           │           │        │
      │           │           │        └ TAG: the version label
      │           │           └ REPOSITORY: the image's name
      │           └ NAMESPACE: whose shelf (my GitHub username)
      └ REGISTRY: which warehouse
```

When Docker reads a name, it goes left to right:
**which warehouse, whose shelf, which image, which version.**

### Names with no registry in front

```
 nginx                =  docker.io/library/nginx:latest
 postgres:17          =  docker.io/library/postgres:17
 selamawitsh/app      =  docker.io/selamawitsh/app:latest
```

No registry in the name means **Docker Hub**. No tag means `latest`.

That is why my image needed the `ghcr.io/...` prefix before I could push it to
GitHub's registry. Without it, Docker would have tried Docker Hub.

---

## 5. Tags are stickers

A tag is a **label** stuck on an image. One image can have many labels.

```
 go-hello:multi          ─┐
 go-hello:1.0.0          ─┤
 go-hello:1.0            ─┤
 go-hello:1              ─┼──►  ONE image  (ID 6f5ab802f7fb, 10.2 MB, stored once)
 go-hello:latest         ─┤
 ghcr.io/selamawitsh/go-hello:1.0.0   ─┤
 ghcr.io/selamawitsh/go-hello:latest  ─┘
```

My proof: every row of `docker images go-hello` had the **same IMAGE ID**.
Tags are not copies.

### The tag command, piece by piece

```
docker tag go-hello:multi ghcr.io/selamawitsh/go-hello:1.0.0
   │    │        │                    │
   │    │        │                    └ the NEW name I want to add (target)
   │    │        └ the image I already have (source)
   │    └ tag = add another name to an image
   └ docker
```

- `docker tag` copies nothing. It only adds a label, and it prints nothing when it works.
- `docker rmi NAME:TAG` removes **one label**. The image itself is deleted only
  when its last label is removed.

---

## 6. Version numbers (semver)

```
   1  .  4  .  2
   │     │     │
   │     │     └ PATCH: a bug fix, nothing new
   │     └ MINOR: a new feature, still compatible
   └ MAJOR: a breaking change
```

| Tag | Means | Moves when... |
|-----|-------|---------------|
| `1.4.2` | Exactly this release | Never (fixed forever) |
| `1.4` | Latest patch of 1.4 | A new 1.4.x is released |
| `1` | Latest of major version 1 | A new 1.x.x is released |
| `latest` | The newest release | Every release |

When I release 1.0.1, I push `1.0.1`, and I **move** `1.0`, `1` and `latest` to it.
`1.0.0` stays where it is.

```
 before:   1.0.0 ─► image A      1.0 ─► A      1 ─► A      latest ─► A
 release 1.0.1:
 after:    1.0.0 ─► image A      1.0 ─► B      1 ─► B      latest ─► B
           1.0.1 ─► image B
```

### Which tag do I use where?

| Place | Use | Why |
|-------|-----|-----|
| Production server | `1.0.0` (exact) | Predictable, and I can roll back |
| Staging or testing | `1.0` or `1` | Gets bug fixes automatically |
| Quick local experiments | `latest` | Convenient, but it can change under me |

> `latest` is **only a label**. It does not mean "safest" or "newest on my
> machine". It means whatever someone last pushed with that label.

---

## 7. Tag vs digest

```
 TAG     = a nickname      can be moved to another image later
 DIGEST  = a fingerprint   always points to exactly one image content
```

My push output ended with:

```
 1.0.0:  digest: sha256:0b8d3b2c...55af86
 latest: digest: sha256:0b8d3b2c...55af86      ← the same fingerprint
```

Two tags, one digest, one image.

I can pull by digest when I need to be 100% exact:

```
docker pull ghcr.io/selamawitsh/go-hello@sha256:0b8d3b2c...
                                          │
                                          └ @ means "this exact fingerprint"
```

```
 pull a tag:      "give me what 1.0.0 points to today"
 pull a digest:   "give me exactly this content, forever"
```

---

## 8. Login and tokens

### Why a login at all

The registry holds **my** shelf. If anyone could upload there, a stranger could
replace my image with a harmful one, and my server would pull it.

```
 anyone ─────────► push ─► 🛡 guard: "Who are you?" ─► ✗ denied
 me, logged in ──► push ─► 🛡 guard: "Welcome back"  ─► ✓ shelf
```

`docker login` shows my ID to the guard. It does one thing: it **saves my
username and token** on my laptop (in `~/.docker/config.json`). Every
`docker push` after that uses the saved ID.

| Action | Login needed? |
|--------|---------------|
| `docker pull` of a public image | No |
| `docker push` | **Yes, always** |
| `docker pull` of a private image | **Yes** |

### Token vs password

```
 password  = master key to my whole GitHub account
 token     = a small key: only "packages", can expire, can be deleted
```

If a token leaks, I delete it and nothing else is harmed.

### Create the token (GitHub in the browser)

1. Profile picture, then **Settings**.
2. **Developer settings**, then **Personal access tokens**, then **Tokens (classic)**.
3. **Generate new token (classic)**.
4. Note `docker-ghcr`, expiration 30 days, tick **`write:packages`**.
5. **Generate token** and copy it. GitHub shows it only once.

### Log in, piece by piece

```
read -s -p "Paste token: " CR_PAT
 │    │  │  │               │
 │    │  │  │               └ the variable that will hold the token
 │    │  │  └ the label shown on screen (any text)
 │    │  └ -p = show a prompt label
 │    └ -s = silent: don't show what I paste
 └ read a value from the keyboard
```

Two separate moments:

```
 1. I type the command and press Enter.
 2. THEN the terminal waits, and I paste the token.   ← the token goes HERE
```

```
echo $CR_PAT | docker login ghcr.io -u selamawitsh --password-stdin
  │              │      │      │       │              │
  │              │      │      │       │              └ read the password from the pipe
  │              │      │      │       └ -u = my username
  │              │      │      └ the registry to log in to
  │              │      └ log in
  │              └ docker
  └ print the token and send it (|) into the next command
```

- `--password-stdin` keeps the token out of the command line, so it is not saved in
  my shell history.
- Then `unset CR_PAT` removes the token from the terminal's memory.
- `docker logout ghcr.io` deletes the saved login from my laptop.

### The mistake I made

```
 wrong:   read -s -p "ghp_xxxx...  " CR_PAT      ← token typed inside the label
 right:   read -s -p "Paste token: " CR_PAT      ← then paste at the silent prompt
```

The variable stayed empty, so `docker login` had no password and said
`cannot perform an interactive login from a non TTY device`. The token had also
been exposed, so I revoked it and made a new one.

---

## 9. Push and pull, step by step

```
 ┌─────────────────────────────── my laptop ──────────────────────────────┐
 │  1. docker build        ──►  image go-hello:multi                      │
 │  2. docker tag          ──►  add 1.0.0, latest, ghcr.io/... names      │
 │  3. docker login        ──►  show my ID to the registry                │
 │  4. docker push         ──►  upload ────────────────┐                  │
 └─────────────────────────────────────────────────────┼──────────────────┘
                                                       ▼
                                              ┌─────────────────┐
                                              │    REGISTRY     │
                                              └────────┬────────┘
 ┌──────────────────────────── any server ──────────────┼─────────────────┐
 │  5. docker pull         ◄── download ────────────────┘                 │
 │  6. docker run          ──►  container                                 │
 └────────────────────────────────────────────────────────────────────────┘
```

### Push, piece by piece

```
docker push ghcr.io/selamawitsh/go-hello:1.0.0
   │    │      │          │          │       │
   │    │      │          │          │       └ version tag
   │    │      │          │          └ image name
   │    │      │          └ my shelf
   │    │      └ the warehouse
   │    └ push = upload
   └ docker
```

### Layers are shared

A push uploads **layers** (the saved steps of an image). The registry skips any layer
it already has.

```
 push 1.0.0:    13 layers → "Pushed"                 (all new)
 push latest:   same 13 layers → "Layer already exists"  (nothing uploaded)
```

Pull works the same way. When I pulled the image back, 12 layers said
`Already exists` (shared with the base image still on my laptop), and only **1 layer**,
the one holding my program, was downloaded.

```
 registry image  =  [ 12 base layers ]  +  [ 1 app layer ]
                     already on laptop ✓     downloaded ↓
```

### How I proved the image travelled

```bash
docker rmi -f 6f5ab802f7fb        # delete the image (every tag) from my laptop
docker pull ghcr.io/selamawitsh/go-hello:1.0.0
docker run -d -p 8300:3000 --name go-from-registry ghcr.io/selamawitsh/go-hello:1.0.0
curl http://localhost:8300        # Hello from a Go app in Docker!
```

```
 docker rmi -f 6f5ab802f7fb
        │     │  │
        │     │  └ the image ID shared by all my tags
        │     └ -f = force (it has several tags)
        └ rmi = remove image
```

---

## 10. Public vs private, and which registry

- **Public:** anyone can pull, no login. Good for open-source images.
- **Private:** only people with permission can pull, and they must log in.
- New packages on GitHub's registry start **private**.
- A server that pulls a private image must log in too. Kubernetes does this later with
  an "image pull secret".

| Registry | Address | Good for |
|----------|---------|----------|
| Docker Hub | `docker.io` (the default) | Public images, the biggest library |
| GitHub Container Registry | `ghcr.io` | Projects that already live on GitHub |
| AWS ECR | `<account>.dkr.ecr.<region>.amazonaws.com` | Images running on AWS |
| Google Artifact Registry | `<region>-docker.pkg.dev` | Images running on Google Cloud |
| Azure Container Registry | `<name>.azurecr.io` | Images running on Azure |
| Self-hosted (`registry:2`, Harbor) | my own server | Full control, internal networks |

I used GHCR because it needs no new account.

---

## 11. Security rules

```
 A token or password goes ONLY:
   ✓ into the silent prompt of my own terminal
   ✗ not in a chat
   ✗ not typed inside a command
   ✗ not in a file I commit to Git
   ✗ not in a Dockerfile or an image
```

- Use the **smallest scope** needed (`write:packages` only).
- Give tokens an **expiry** (30 days).
- If a token is exposed: **revoke it first**, create a new one, then clear the
  terminal history (`history -c` and `history -w`).
- Bots scan GitHub for leaked tokens within seconds, so never assume "nobody will see it".
- Before committing, check my files: `grep -r "ghp_" .` should print nothing.
- Log out when I am done: `docker logout ghcr.io`.
- Never bake secrets into an image. Anyone who can pull the image can read them.
- Don't use `latest` for production. Pin an exact version.

---

## 12. What I proved in Lab 05

| Test | Result |
|------|--------|
| Added 5 tags to one image | All rows had the same IMAGE ID (tags are labels) |
| Pushed `1.0.0` | 13 layers `Pushed` |
| Pushed `latest` | 13 layers `Layer already exists`, same digest |
| Package page on GitHub | `go-hello` appeared under Packages, private |
| Deleted the image locally, pulled it back | Only 1 layer downloaded, 12 already existed |
| Ran the pulled image | `Hello from a Go app in Docker!` |

---

## 13. If it doesn't work: checklist

```
 push or pull failed?
        │
        ▼
 1. Is the image name correct and in lowercase?   (registries reject capitals)
        ▼
 2. Does the name start with the registry (ghcr.io/...)?
        ▼
 3. Am I logged in?                               (docker login, then try again)
        ▼
 4. Does the token have write:packages, and has it expired?
        ▼
 5. Does the tag I am pushing exist locally?      docker images
```

| Message | Meaning | Fix |
|---------|---------|-----|
| `denied` / `unauthorized` | Not logged in, or wrong token scope | `docker login`, check the scope |
| `requested access to the resource is denied` | The name has the wrong namespace or no registry prefix | Retag with the full `ghcr.io/USER/name` |
| `name unknown` | The repository does not exist (or I have no access) | Check the spelling and that I pushed it |
| `invalid reference format` | A capital letter or a bad character in the name | Use lowercase only |
| `manifest unknown` | That tag does not exist in the registry | Check the tags on the package page |
| `cannot perform an interactive login from a non TTY device` | The token variable was empty | Redo the silent prompt |

---

## 14. Self-test

1. Why can't a server run an image that is only on my laptop?
2. What is a registry? How is it like GitHub?
3. In `ghcr.io/selamawitsh/go-hello:1.0.0`, what are the four parts?
4. What does `docker tag` do, and does it copy the image?
5. What do `1`, `0` and `0` mean in `1.0.0`?
6. Which tag should a production server use, and why not `latest`?
7. Tag vs digest: what is the difference?
8. Why does `docker push` need a login, but pulling `nginx` does not?
9. Why use a token instead of my password? Where must I never put it?
10. When I pushed `latest` after `1.0.0`, why did every layer say `Layer already exists`?

### Answers

1. The server has to download it from somewhere, and my laptop is not reachable.
   A registry is the shared place both sides can reach.
2. A warehouse that stores images. GitHub stores code, a registry stores images.
   `docker push` and `docker pull` match `git push` and `git pull`.
3. Registry, namespace (my shelf), repository (image name), tag (version).
4. It adds another name (label) to an existing image. It copies nothing.
5. Major, minor, patch: breaking change, new feature, bug fix.
6. An exact version such as `1.0.0`. `latest` is a moving label, so the server could
   get a different image later.
7. A tag is a movable nickname. A digest is a fingerprint of the exact content.
8. Anyone may download a public image, but only the owner may upload to a shelf.
9. A token has limited permissions, can expire and can be revoked. Never put it in
   a chat, a command, a file I commit, or an image.
10. Both tags point to the same image, so the registry already had every layer.
