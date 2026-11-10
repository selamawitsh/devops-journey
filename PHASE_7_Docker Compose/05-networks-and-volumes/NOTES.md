# Phase 7: Docker Compose
## Lesson 5: Networks and Volumes

## 1. Learning objectives

By the end of this lesson, you should be able to:

- Explain why containers need networks.
- Describe how services communicate in a Docker Compose project.
- Explain the difference between a default network and a custom network.
- Explain what Docker volumes are and why they are useful.
- Distinguish named volumes from bind mounts.
- Configure persistent storage for a database in a Compose file.
- Use basic commands to inspect and manage networks and volumes.

---

# Part A: Docker Compose Networks

## 2. What is a Docker network?

A Docker network allows containers to communicate with one another and, when configured, with other networks or the outside world.

Think of a network as a communication path. If an application container needs to send a request to a database container, they need a network through which they can communicate.

### Example

Imagine an application with two services:

- `auth-service`: handles user login.
- `postgres`: stores user information.

The auth service needs to communicate with PostgreSQL to read or save user information. A Docker network makes this communication possible.

## 3. The default Compose network

When you start a Compose project, Docker Compose normally creates a default network for that project. Services in the same Compose project can communicate through this network.

They can use their **service names** as hostnames.

For example, if the database service is named `postgres`, an application in the same network can use `postgres` as the database hostname.

Example database connection settings:

```text
DB_HOST=postgres
DB_PORT=5432
```

The hostname is `postgres` because that is the Compose service name. You generally do not need to find and hard-code the container's IP address.

### Important points

- Services in the same Compose network can communicate with one another.
- Compose provides service-name-based DNS on its networks.
- Container IP addresses can change when containers are recreated.
- Using service names is more reliable than hard-coding container IP addresses.

## 4. Defining a custom network

Compose can also define named networks. A custom network is useful when you want to control which services can communicate with which other services.

Example:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      - frontend

  app:
    image: my-app:latest
    networks:
      - frontend
      - backend

  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: example
      POSTGRES_DB: app_db
    networks:
      - backend

networks:
  frontend:
  backend:
```

### Understand the example

- `web` joins the `frontend` network.
- `app` joins both `frontend` and `backend`.
- `postgres` joins the `backend` network.
- `app` can communicate with both `web` and `postgres`.
- `web` and `postgres` do not share a network in this example.

This is a simple way to separate services into communication groups.

> The image `my-app:latest` is an example placeholder. It will work only if that image exists locally or can be pulled from a registry.

## 5. `ports` versus `expose`

These two settings are easy to confuse.

### `ports`

`ports` publishes a container port to the host machine. This allows software outside the container network, such as your browser, to reach the service through the host.

Example:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```

Meaning:

- `8080` is the port on your host machine.
- `80` is the port inside the container.
- You can open `http://localhost:8080` on the host to reach Nginx.

### `expose`

`expose` documents or makes a container port available to other containers on the network, without publishing it as a host port.

Example:

```yaml
services:
  app:
    image: my-app:latest
    expose:
      - "5000"
```

### Quick comparison

| Setting | Main purpose |
|---|---|
| `ports` | Publishes a container port to the host |
| `expose` | Makes/document ports for container-to-container use; does not publish them to the host |

Containers on the same Compose network can generally communicate with each other on the service's listening port without needing `ports` or `expose`.

---

# Part B: Docker Volumes and Persistent Storage

## 6. What is a Docker volume?

A Docker volume is a way to store data outside a container's temporary writable layer.

Think about a PostgreSQL container that stores customer records. If the container is removed and later recreated, you do not want to lose the database data.

A volume can keep that data separate from the container's lifecycle.

### Why are volumes important?

- They help preserve data when containers are replaced.
- They allow data to be shared or reused where appropriate.
- They are useful for databases and other stateful services.
- Docker manages named volumes for you.

## 7. Named volumes

A named volume is a volume identified by a name and managed by Docker.

Example:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: example
      POSTGRES_DB: app_db
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Understand the example

- `postgres_data` is the named volume.
- `/var/lib/postgresql/data` is the data directory inside the PostgreSQL container.
- Docker stores the database files in the named volume.
- If the PostgreSQL container is removed and recreated while the volume is retained, the data can remain available.

The volume is declared at the bottom under the top-level `volumes:` section.

## 8. Bind mounts

A bind mount connects a specific file or directory on your host machine to a path inside a container.

Example:

```yaml
services:
  web:
    image: nginx:alpine
    volumes:
      - ./website:/usr/share/nginx/html
```

### Understand the example

- `./website` is a directory on your computer, relative to the Compose file.
- `/usr/share/nginx/html` is the directory inside the container.
- Files you edit in the host directory are reflected in the mounted directory inside the container.

Bind mounts are especially useful during development because you can edit files on your computer without rebuilding the image every time.

## 9. Named volumes versus bind mounts

| Feature | Named volume | Bind mount |
|---|---|---|
| Storage location | Managed by Docker | A specific host path |
| Common use | Database and persistent application data | Source code and development files |
| Host path control | Docker manages the storage location | You choose the host path |
| Example | `postgres_data:/var/lib/postgresql/data` | `./website:/usr/share/nginx/html` |

**Simple way to remember:**

- Use a named volume when you want Docker to manage persistent data.
- Use a bind mount when you want to connect a particular folder or file from your computer to a container.

## 10. What happens to volumes when containers are removed?

A named volume normally remains when you run:

```bash
docker-compose down
```

This removes the Compose containers and networks, but does not normally remove named volumes.

To remove the Compose project and its declared named volumes, you can run:

```bash
docker-compose down -v
```

**Warning:** `-v` removes the project's declared named volumes. Data stored in those volumes can be permanently lost. Do not use it when you need to keep your database data.

---

# Part C: Practical Lab

## 11. Lab goal

Create a small Compose project with:

- An Nginx web server.
- A PostgreSQL database.
- A custom network for communication.
- A named volume for persistent database storage.

This lab demonstrates the basic network and volume concepts. It does not create a real application that connects Nginx to PostgreSQL.

## 12. Create the project directory

```bash
mkdir compose-networks-volumes
cd compose-networks-volumes
```

Create a file named `docker-compose.yml`:

```bash
nano docker-compose.yml
```

Add this configuration:

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      - frontend

  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: example
      POSTGRES_DB: app_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend

networks:
  frontend:
  backend:

volumes:
  postgres_data:
```

Save the file.

## 13. Validate the Compose file

Run:

```bash
docker-compose config
```

This checks and displays the resolved Compose configuration. Fix any YAML or configuration errors before starting the containers.

## 14. Start the services

```bash
docker-compose up -d
```

Docker Compose downloads the images if needed, creates the network and volume, and starts the containers.

## 15. Check the containers

```bash
docker-compose ps
```

You should see the `web` and `postgres` services running if startup succeeds.

## 16. Open the Nginx page

On the same computer, open this address in your browser:

```text
http://localhost:8080
```

You should see the default Nginx welcome page.

## 17. Inspect networks

List Docker networks:

```bash
docker network ls
```

Inspect the Compose network names shown in the output:

```bash
docker network inspect <network_name>
```

Replace `<network_name>` with the actual network name from your output.

## 18. Inspect volumes

List Docker volumes:

```bash
docker volume ls
```

Inspect the named volume:

```bash
docker volume inspect <volume_name>
```

Replace `<volume_name>` with the actual volume name from your output.

## 19. Stop the project and preserve data

Run:

```bash
docker-compose down
```

This removes the project's containers and networks while normally retaining the named volume.

Start it again:

```bash
docker-compose up -d
```

The PostgreSQL container can reuse the existing volume.

When you have finished the lab and no longer need its data, you can remove the project and its declared volumes with:

```bash
docker-compose down -v
```

Remember that this deletes the data in the named volume.

---

# Part D: Important Commands

| Command | Purpose |
|---|---|
| `docker-compose up -d` | Start services in the background |
| `docker-compose ps` | List the project's containers |
| `docker-compose logs` | View service logs |
| `docker-compose down` | Stop and remove containers and project networks |
| `docker-compose down -v` | Also remove declared named volumes |
| `docker network ls` | List Docker networks |
| `docker network inspect NAME` | Inspect a network |
| `docker volume ls` | List Docker volumes |
| `docker volume inspect NAME` | Inspect a volume |

This learning environment uses the `docker-compose` command with a hyphen, matching the version installed on your machine.

---

# Part E: Key Things to Remember

1. A Docker network allows containers to communicate.
2. Compose normally creates a default network for a project.
3. Services on the same Compose network can use service names as hostnames.
4. `ports` publishes a container port to the host.
5. `expose` does not publish a port to the host.
6. A Docker volume stores data separately from a container's writable layer.
7. Named volumes are managed by Docker and are useful for persistent data.
8. Bind mounts connect a specific host file or directory to a container.
9. `docker-compose down` normally preserves named volumes.
10. `docker-compose down -v` removes declared named volumes and can delete their data.


## Lesson Summary

Docker Compose networks provide communication between services. Compose service names make it easier for containers to find one another without hard-coding IP addresses.

Docker volumes help keep important data outside a container's writable layer. Named volumes are useful for persistent database data, while bind mounts are useful when a container needs access to a particular host directory or file.

Together, networks and volumes help you build multi-container development environments that can communicate and preserve important data.
