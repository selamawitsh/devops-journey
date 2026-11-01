# Phase 7 — Docker Compose

**Roadmap phase:** 7 of 18  
**Repository folder:** `PHASE_7_Docker_Compose`

## Goal
Learn how to define, connect, configure, and manage multi-container applications with Docker Compose. The phase prepares for CI/CD, Nginx, and later Kubernetes work.

## Roadmap topics
1. Compose fundamentals — services, networks, volumes, Compose files, and the Compose specification.
2. Multi-service orchestration — dependencies, health checks, and startup ordering.
3. Environment management — `.env` files, overrides, and secrets.
4. Networking between services — internal DNS, published ports, and internal-only services.
5. Local development vs production — where Compose fits and why Kubernetes is introduced later.

## Phase project
Build a local multi-container environment based on the Agri-Yield agriculture platform example:
- 16 illustrative backend microservices.
- PostgreSQL, Redis, and RabbitMQ as example shared development infrastructure.
- A Compose network, persistent storage, environment configuration, and health checks.
- A documented startup procedure and runbook.

**Important:** The 16 service names in the example are proposed teaching names, not confirmed names from the original Agri-Yield project. Update them to match the real architecture. The full 16-service Compose file is a design template; it will not run until each service's source code and Dockerfile exist.

## Folder structure
```text
PHASE_7_Docker_Compose/
├── 01-fundamentals/
│   ├── README.md
│   ├── NOTES.md
│   └── agri-yield-architecture.md
├── 02-yaml-basics/
│   ├── README.md
│   └── NOTES.md
├── 03-first-compose-file/
│   ├── README.md
│   ├── NOTES.md
│   └── compose.yaml
├── 04-multi-service-orchestration/
│   ├── README.md
│   └── NOTES.md
├── 05-networks-and-volumes/
│   ├── README.md
│   └── NOTES.md
├── 06-environment-management/
│   ├── README.md
│   └── NOTES.md
├── NOTES.md
└── README.md
```

## Local tool version
The learning machine reported Docker Compose `1.29.2`. Use `docker-compose` (hyphen) in commands for this environment. Newer Compose plugin installations commonly use `docker compose` (space).

## Learning rules
- Complete the lesson and lab before moving to the next topic.
- Commit each topic in small increments.
- Record commands actually run, screenshots, errors, solutions, and lessons learned.
- Never commit real passwords, API keys, or production secrets.
