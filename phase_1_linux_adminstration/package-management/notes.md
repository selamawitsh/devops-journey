# Notes — Linux Package Management

## dpkg vs apt
- `dpkg` is the low-level tool. It installs/removes/tracks individual `.deb` files **on this machine only** — it has no concept of the internet or repositories.
- `apt` sits on top of `dpkg`. It talks to remote repos, resolves dependencies, downloads the right `.deb` files, then calls `dpkg` to actually install them.

**Key commands:**
| Command | Layer | What it does |
|---|---|---|
| `dpkg -l` | dpkg | List all installed packages |
| `dpkg -s <pkg>` | dpkg | Show status/metadata of an installed package |
| `dpkg -L <pkg>` | dpkg | List every file a package put on disk |
| `apt-cache policy <pkg>` | apt | Show installed vs candidate version + which repo it comes from |
| `apt-cache depends <pkg>` | apt | Show dependency tree |
| `apt list --broken` | apt | Show packages in a broken state |

## Dependency resolution
Packages declare `Depends:`, `Conflicts:`, `Recommends:`, `Suggests:` in their metadata. apt builds a dependency graph across every package it's about to touch and computes a full install plan *before* changing anything on disk.

If that graph can't be satisfied (version conflict, missing dependency, partial previous install), apt refuses and reports why — reading that error message correctly is 90% of fixing it.

## Held & pinned packages
- **Hold** (`apt-mark hold <pkg>`): quick, one-machine, easy to forget. Freezes a package at its current version so `apt upgrade` skips it.
- **Pin** (`/etc/apt/preferences.d/`): declarative, version-controllable, survives across machines when checked into config management. Uses numeric priority to prefer specific versions/origins.

Use a hold for a one-off "don't touch this today." Use a pin when the rule needs to be reproducible across servers (this is what you'll do in Ansible later).

## Repos & GPG keys
- A repo is just a URL apt checks for a package index (`/etc/apt/sources.list`, `/etc/apt/sources.list.d/*.list`).
- GPG signing proves the index actually came from who it claims to — without it, anyone could serve malicious `.deb` files from a fake mirror.
- Modern syntax uses `signed-by=/path/to/keyring.gpg` scoped to that one repo file. The old `apt-key add` trusted a key **globally** for every repo — a real security regression, which is why it's deprecated.
