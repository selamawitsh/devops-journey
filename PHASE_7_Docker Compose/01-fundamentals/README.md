# Lesson 1 — Docker Compose Fundamentals

## Learning objectives
- Explain why Compose is useful for multi-container applications.
- Distinguish images, containers, services, networks, and volumes.
- Explain how Compose relates to a microservices backend.
- Read a simple Compose file.

## 1. What is Docker Compose?
Docker Compose is a tool for defining and managing multi-container applications through a YAML configuration file, commonly `compose.yaml` or `docker-compose.yml`.

Instead of manually running many `docker run` commands, we describe the application services and their configuration together.

For this computer, use the Compose v1 command:
```bash
docker-compose version
```
The reported version is 1.29.2.

## 2. Why do we need it?
A backend may consist of an API, authentication service, database, cache, and message broker. Running and connecting each container manually becomes repetitive. Compose stores the configuration in one place and provides commands to manage the group.

Compose does not combine all microservices into one container. Each service normally runs as a separate container.

## 3. Important terms
| Term | Meaning |
|---|---|
| Image | Template used to create a container |
| Container | Instance created from an image |
| Service | Application component described in Compose |
| Network | Connects containers |
| Volume | Persists data outside a container's writable layer |

## 4. Agri-Yield example
Read `agri-yield-architecture.md`. It shows how a Compose file could describe a 16-service backend, plus supporting infrastructure.

The 16 names are illustrative until confirmed against the actual Agri-Yield design.

## 5. First lab
Go to `../03-first-compose-file/` and follow its README. It starts a simple Nginx container through Compose so you can observe a real service, port mapping, logs, and cleanup.

## 6. Commands to remember
```bash
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```

