# Lesson 4: Multi-Service Orchestration

## Learning Objectives

By the end of this lesson, you should be able to:

- Explain multi-service orchestration.
- Understand the difference between a Compose service and a running container.
- Explain service dependencies.
- Use `depends_on` to define startup dependencies.
- Explain the difference between container startup and application readiness.
- Configure a health check.
- Understand Docker Compose restart policies.

---

## 1. What Is a Service?

A **service** is a definition in a Docker Compose file that describes how a container should run.

An Agri-Yield application might have these services:

- `auth-service`: handles user authentication.
- `user-service`: manages user information.
- `product-service`: manages agricultural products.
- `postgres`: stores application data.
- `redis`: provides caching.

A service is the configuration in the Compose file. A container is the actual running instance created from that configuration.

## 2. What Is Multi-Service Orchestration?

Multi-service orchestration means managing multiple related services together, including their configuration, networking, dependencies, and lifecycle.

Docker Compose lets us describe services in one YAML file and manage them together.

### Useful Commands

```bash
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```

- `up -d`: creates and starts services in the background.
- `ps`: shows the containers' status.
- `logs`: displays service logs.
- `down`: stops and removes Compose containers and networks. Named volumes are normally retained unless `-v` is used.

## 3. Why Do Services Depend on Each Other?

A service may need another service to do its job.

For example:

- `auth-service` handles login.
- `postgres` stores user information.
- `auth-service` needs PostgreSQL to retrieve user information.

In this example, PostgreSQL is a dependency of the authentication service.

## 4. The `depends_on` Property

The `depends_on` property defines startup dependencies between services.

```yaml
services:
  postgres:
    image: postgres:16

  auth-service:
    image: my-auth-app:latest
    depends_on:
      - postgres
```

This tells Docker Compose to start `postgres` before starting `auth-service`.

### Important: Startup Order Is Not Readiness

Starting a container does not necessarily mean the application inside it is ready.

For example, the PostgreSQL container may have started while PostgreSQL is still initializing. If the authentication service tries to connect too early, its connection attempt may fail.

Basic short-form `depends_on` controls startup order. It does not wait for the dependency to become ready to accept requests.

## 5. What Is a Health Check?

A **health check** is a test Docker runs to check whether an application inside a container is working as expected.

### Common Health States

| Status | Meaning |
|---|---|
| `starting` | The health check is in its initial startup period or has not yet succeeded. |
| `healthy` | The health check has succeeded. |
| `unhealthy` | The configured health check has failed repeatedly. |

PostgreSQL provides a command called `pg_isready` that checks whether the server is accepting connections.

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: agriv_user
      POSTGRES_PASSWORD: example
      POSTGRES_DB: agriv_yield

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U agriv_user -d agriv_yield"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
```

### Health Check Properties

| Property | Meaning |
|---|---|
| `test` | The command Docker runs to check the service. |
| `interval` | How often Docker runs the health check. |
| `timeout` | How long Docker waits for one check before considering it failed. |
| `retries` | How many consecutive failures are needed before marking the container unhealthy. |
| `start_period` | Initial grace period during which failures do not count toward the retry limit. |

## 6. Combine `depends_on` with a Health Check

Compose can wait for a dependency's health check to succeed before starting a dependent service. This uses the long-form `depends_on` syntax.

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: agriv_user
      POSTGRES_PASSWORD: example
      POSTGRES_DB: agriv_yield

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U agriv_user -d agriv_yield"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

  auth-service:
    image: my-auth-app:latest
    depends_on:
      postgres:
        condition: service_healthy
```

### Intended Startup Sequence

1. Compose starts PostgreSQL.
2. Docker runs the PostgreSQL health check.
3. Compose waits until PostgreSQL is reported healthy.
4. Compose starts `auth-service`.

`condition: service_healthy` means the dependency must pass its health check before the dependent service is started.

**Important:** A health check does not automatically restart a container just because it becomes unhealthy. This startup dependency also does not guarantee that the database will remain healthy forever. Applications should implement connection retries and handle temporary dependency failures.

## 7. What Is a Restart Policy?

A restart policy tells Docker whether it should automatically try to restart a container after it stops.

```yaml
services:
  auth-service:
    image: my-auth-app:latest
    restart: unless-stopped
```

### Common Restart Policies

| Policy | Meaning |
|---|---|
| `no` | Do not automatically restart the container. This is the default. |
| `always` | Always try to restart the container when it stops. |
| `on-failure` | Restart when the container exits with a non-zero exit code. |
| `unless-stopped` | Restart unless the container was explicitly stopped. |

A restart policy is different from a health check. A health check reports the container's health; a restart policy controls restart behavior when the container stops.

---

## 8. Practical Exercise: PostgreSQL and an Authentication-Service Placeholder

This example combines a database health check, a startup dependency, and a restart policy.

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: agriv_user
      POSTGRES_PASSWORD: example
      POSTGRES_DB: agriv_yield
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U agriv_user -d agriv_yield"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s

  auth-service:
    image: nginx:alpine
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped
```

**Note:** Nginx is a placeholder for `auth-service` in this learning exercise. It is not a real authentication application.

### Run the Exercise

Save the configuration as `compose.yaml`, then run these commands from the same directory.

1. Validate the Compose configuration:

   ```bash
   docker-compose config
   ```

2. Start the services:

   ```bash
   docker-compose up -d
   ```

3. Check their status:

   ```bash
   docker-compose ps
   ```

4. View the logs:

   ```bash
   docker-compose logs
   ```

5. Stop and remove the Compose containers and network:

   ```bash
   docker-compose down
   ```

The example password is for local learning only. Do not use it for a real deployment or commit real credentials to GitHub.

## 9. Key Differences to Remember

| Feature | Main Purpose |
|---|---|
| `depends_on` | Defines service startup dependencies. |
| `healthcheck` | Checks whether an application in a container is healthy. |
| `condition: service_healthy` | Makes Compose wait for a dependency's health check to succeed before starting the dependent service. |
| `restart` | Defines restart behavior when a container stops. |

### Quick Memory Tip

- `depends_on` = **What should start first?**
- `healthcheck` = **Is the application healthy?**
- `service_healthy` = **Wait until the dependency passes its health check.**
- `restart` = **What should happen if the container stops?**

## 10. Agri-Yield Example

In the Agri-Yield architecture, services may depend on infrastructure services.

For example:

- `auth-service` may depend on PostgreSQL.
- `notification-service` may depend on RabbitMQ.
- Other services may depend on Redis for caching.

Configure each dependency based on the actual application requirements. A health check should test something meaningful for that specific service.

For a real microservices system, applications should also handle temporary network failures and retry connections when dependencies become unavailable.

---

## Lesson Summary

In this lesson, we learned that:

1. A Compose service is a definition; a container is the running instance.
2. Multi-service orchestration allows related containers to be managed together.
3. `depends_on` defines startup dependencies.
4. Basic `depends_on` does not guarantee application readiness.
5. Health checks help determine whether an application is healthy.
6. `condition: service_healthy` can make Compose wait for a dependency's health check during startup.
7. Restart policies control what Docker does when a container stops.

**Next lesson:** Networks and Volumes — how containers communicate and how data is persisted.
