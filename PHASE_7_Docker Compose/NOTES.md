# Phase 7 — Docker Compose Master Notes

## What Compose does
Docker Compose defines and manages an application made of multiple containers using a YAML configuration file.

## Core concepts
- **Service:** a component declared in the Compose file.
- **Container:** a running instance created from an image.
- **Image:** the template used to create a container.
- **Network:** allows containers to communicate.
- **Volume:** stores data independently of a container's writable layer.
- **Compose project:** the group of resources managed from a Compose configuration.

## Main command set (Compose v1)
```bash
docker-compose version
docker-compose config
docker-compose up
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose logs -f SERVICE
docker-compose exec SERVICE sh
docker-compose restart SERVICE
docker-compose down
docker-compose down -v
```

`docker-compose down` removes project containers and networks. Named volumes are retained unless `-v` is supplied. `down -v` deletes named volumes and their stored data.

## Important behavior
- Services on the same Compose network can normally reach each other using their service names as DNS names.
- `ports` publishes a container port on the host.
- `expose` documents/makes a port available to other containers without publishing it to the host.
- `volumes` can mount named volumes or host directories into containers.
- `depends_on` expresses startup dependencies. Basic `depends_on` ordering does not by itself prove that a dependency is ready to accept requests. Health checks and application retry logic matter.
- A Compose file describes the desired local environment; it does not create missing application source code or Dockerfiles.

## Compose v1 vs plugin
This machine reported Compose 1.29.2 and uses `docker-compose`. Newer Docker installations may use the plugin command `docker compose`. Confirm the installed command before running examples.

## Agri-Yield connection
The Agri-Yield design example uses 16 proposed microservice names plus PostgreSQL, Redis, and RabbitMQ as illustrative local infrastructure. Confirm the actual service list and each service's database/message-broker requirements before calling it the real architecture.

## My notes and observations
- Compose version:
- Commands executed:
- What worked:
- Errors and fixes:
- Screenshots added:
- What I learned:
