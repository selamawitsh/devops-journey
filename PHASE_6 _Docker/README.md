# Phase 6: Docker

Hands-on Docker labs from my DevOps learning roadmap.
Each lab folder has its own README with the commands I ran, what I saw,
and what I learned, plus a NOTES.md written for revision.

## Labs

| Lab | Topic | Status | Key result |
|-----|-------|--------|------------|
| [01-fundamentals](01-fundamentals/) | Images, containers, Dockerfile basics, build cache | Done | Built my first image and proved Docker reuses unchanged build steps |
| [02-dockerfile-best-practices](02-dockerfile-best-practices/) | Multi-stage builds, image size | Done | Image shrank from 304 MB to 10.2 MB |
| [03-networking](03-networking/) | Bridge networks, container DNS | Done | Containers find each other by name on a custom network |
| 04-volumes | Persistent data | In progress | |
| 05-registries | Tagging and pushing images | Planned | |
| 06-limits-and-security | Resource limits, non-root | Planned | |
| 07-debugging | Diagnosing broken containers | Planned | |

## Folder structure

```
PHASE_6 _Docker/
├── README.md
├── NOTES.md
├── 01-fundamentals/
├── 02-dockerfile-best-practices/
├── 03-networking/
├── 04-volumes/
├── 05-registries/
├── 06-limits-and-security/
└── 07-debugging/
```

## How each lab is written

Goal, what I built, folder structure, commands used, what I learned,
mistakes and fixes, and future improvements.

## Revision notes

See [NOTES.md](NOTES.md) for a quick revision guide covering Docker concepts,
commands, Dockerfile, volumes and networking.
