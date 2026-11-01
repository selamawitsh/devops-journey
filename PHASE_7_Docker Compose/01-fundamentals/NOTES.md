# Lesson 1 Notes — Docker Compose

## Definition
Docker Compose is a tool for defining and managing applications that use multiple containers.

## Why it is useful
1. Keeps multi-container configuration in one YAML file.
2. Starts and stops related services together.
3. Defines networking between services.
4. Defines persistent volumes.
5. Helps make development environments repeatable.

## Service vs container
A service is a definition in the Compose file. A container is an instance created for that service. One service can be scaled to more than one container in some configurations.

## Network
Containers on the same Compose network can communicate using service names. For example, an application can connect to a database host named `postgres` when the Compose service is named `postgres`.

## Volume
A named volume stores data outside the lifecycle of an individual container. Removing a container does not automatically mean its named volume is removed.

## Port mapping
`8080:80` means host port 8080 forwards to port 80 inside the container.

## Commands
```bash
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```

