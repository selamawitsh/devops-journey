# Lesson 6: Environment Management — Study Notes

## 1. What is environment management?

Environment management means keeping configuration separate from application code so settings can be changed without rewriting the application.

An application may need a database host, port, username, password, database name, API URLs, or application mode. Different environments, such as development and production, may need different values.

| Configuration | Development example | Production example |
|---|---|---|
| Database host | `postgres` | `production-db` |
| Database name | `test_db` | `production_db` |
| Debug mode | `true` | `false` |

These are examples; actual values depend on the application.

## 2. Environment variables

An environment variable is a named value that a program can read while it is running.

Example:

```env
DB_HOST=postgres
DB_USER=app_user
DB_PASSWORD=example123
DB_NAME=agriv_yield
```

In Docker Compose, `environment` passes variables directly into a service container.

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: app_user
      POSTGRES_PASSWORD: example123
      POSTGRES_DB: agriv_yield
```

The official PostgreSQL image recognizes these variables for its initial database setup. The example password is for learning only.

## 3. Project `.env` file

A project `.env` file is commonly used by Docker Compose to substitute variables in the Compose configuration.

Example `.env`:

```env
POSTGRES_USER=app_user
POSTGRES_PASSWORD=example123
POSTGRES_DB=agriv_yield
```

Compose file:

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
```

Compose substitutes expressions such as `${POSTGRES_USER}` with their values when it processes the configuration.

**Important:** The project `.env` file does not automatically pass every variable into every container. It supplies values for Compose variable substitution.

## 4. `environment` vs `env_file` vs `.env`

These mechanisms are related, but they do different jobs.

### A. `environment`

Defines variables in the Compose service configuration and passes them into the container.

```yaml
services:
  app:
    image: nginx:alpine
    environment:
      APP_MODE: development
      APP_PORT: "8080"
```

### B. `env_file`

Loads variables from a specified file and passes them into the service container.

Example `app.env`:

```env
APP_MODE=development
APP_PORT=8080
```

Compose file:

```yaml
services:
  app:
    image: nginx:alpine
    env_file:
      - app.env
```

### C. Project `.env`

Provides values for Compose variable substitution.

Example `.env`:

```env
APP_IMAGE=nginx:alpine
APP_PORT=8080
```

Compose file:

```yaml
services:
  app:
    image: ${APP_IMAGE}
    ports:
      - "${APP_PORT}:80"
```

| Mechanism | Main purpose |
|---|---|
| `environment` | Defines variables passed into a container |
| `env_file` | Loads variables from a file into a container |
| Project `.env` | Supplies values for Compose variable substitution |

## 5. Environment-specific override files

An application may need different settings in development and production. You can use a common Compose file and an override file for each environment.

Example structure:

```text
project/
├── docker-compose.yml
├── docker-compose.dev.yml
└── docker-compose.prod.yml
```

Base `docker-compose.yml`:

```yaml
services:
  app:
    image: my-app:latest
    restart: unless-stopped
```

Development override `docker-compose.dev.yml`:

```yaml
services:
  app:
    environment:
      APP_MODE: development
      DEBUG: "true"
    ports:
      - "8080:8080"
```

Production override `docker-compose.prod.yml`:

```yaml
services:
  app:
    environment:
      APP_MODE: production
      DEBUG: "false"
```

Use the development configuration:

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

Use the production configuration:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

Compose combines files in the order supplied. The later file can override or extend settings from the earlier file according to Compose merge rules.

`my-app:latest` is an example image name. It must exist locally or be available from a registry.

## 6. Secrets and safe credential handling

A secret is sensitive information that should not be exposed publicly. Examples include database passwords, API keys, access tokens, and private keys.

Never put real credentials directly into application code or a public Git repository.

### Local development `.env`

A `.env` file can be convenient for local development, but it is not encrypted. It is a plain text file. Protect it and keep it out of Git.

### `.gitignore`

A targeted example:

```gitignore
.env
.env.*
!.env.example
```

This ignores `.env` and other `.env.*` files while allowing `.env.example` to be committed.

If your project uses differently named secret files such as `app.env`, add the relevant filename or pattern to `.gitignore` too.

### `.env.example`

Create a safe example file with placeholder values:

```env
POSTGRES_USER=your_username
POSTGRES_PASSWORD=replace_with_a_local_password
POSTGRES_DB=your_database
```

Commit `.env.example` so other developers can see which variables are required, but never put real credentials in it.

## 7. Docker Compose secrets

Compose supports a `secrets` feature for providing sensitive data to services as files.

```yaml
services:
  app:
    image: my-app:latest
    secrets:
      - db_password

secrets:
  db_password:
    file: ./db_password.txt
```

The secret is made available to the service as a file, typically at:

```text
/run/secrets/db_password
```

The application must be designed to read the password from that file.

### Limitations and cautions
- Protect the source file, such as `db_password.txt`.
- Do not commit the real secret file to Git.
- Restrict access to the host and files containing secrets.
- Local Compose secrets are not the same as a full production secrets-management platform.
- Do not assume the source file is encrypted just because it is declared under `secrets`.

## 8. Practical lab: configuration for PostgreSQL

### Lab goal

Create a small Compose project demonstrating:
- A PostgreSQL service.
- Project `.env` variable substitution.
- `env_file` for container environment variables.
- `.gitignore` and `.env.example`.
- A development override file.

This is a learning configuration, not a complete production secrets solution.

### Step 1: Create a project directory

```bash
mkdir compose-environment-lab
cd compose-environment-lab
```

### Step 2: Create `.env`

```env
POSTGRES_USER=app_user
POSTGRES_PASSWORD=local_learning_password
POSTGRES_DB=app_db
POSTGRES_PORT=5432
```

This file supplies values for Compose substitution in this lab.

### Step 3: Create `app.env`

```env
APP_MODE=development
APP_LOG_LEVEL=debug
```

This file will be passed into a service using `env_file`.

### Step 4: Create `docker-compose.yml`

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  app-config-example:
    image: nginx:alpine
    env_file:
      - app.env
    environment:
      APP_SOURCE: compose

volumes:
  postgres_data:
```

`app-config-example` demonstrates passing variables into a container. Nginx does not automatically use the example `APP_MODE` or `APP_LOG_LEVEL` values; they are simply available as environment variables inside the container.

### Step 5: Create `.gitignore`

```gitignore
.env
.env.*
!.env.example
app.env
```

This keeps the real local configuration files out of Git while allowing `.env.example` to be committed.

### Step 6: Create `.env.example`

```env
POSTGRES_USER=your_username
POSTGRES_PASSWORD=replace_with_a_local_password
POSTGRES_DB=your_database
POSTGRES_PORT=5432
```

Use placeholders only. Do not copy real credentials into this file.

### Step 7: Create `docker-compose.dev.yml`

```yaml
services:
  app-config-example:
    environment:
      APP_MODE: development
      DEBUG: "true"
```

Display the combined configuration:

```bash
docker-compose -f docker-compose.yml -f docker-compose.dev.yml config
```

The `config` command displays the resolved configuration. Be careful: resolved configuration can display substituted passwords, so do not share its output publicly.

### Step 8: Validate the main configuration

```bash
docker-compose config
```

Fix YAML or configuration errors before starting services.

### Step 9: Start and inspect services

```bash
docker-compose up -d
docker-compose ps
docker-compose logs
```

### Step 10: Check Git ignore rules

If this folder is inside a Git repository:

```bash
git status --short
```

The real `.env` and `app.env` files should not appear as untracked files if the ignore rules are working and the files were not already tracked.

Check the ignore rules:

```bash
git check-ignore -v .env app.env
```

If a file was already tracked before adding it to `.gitignore`, `.gitignore` alone will not untrack it. To remove it from the Git index without deleting your local copy:

```bash
git rm --cached .env
```

Only run that command if `.env` is already tracked.

### Step 11: Stop the project

```bash
docker-compose down
```

This removes the project's containers and networks but normally retains named volumes.

To also remove the project's declared named volumes:

```bash
docker-compose down -v
```

**Warning:** This can permanently delete database data stored in those volumes.

## 9. Useful commands

| Command | Purpose |
|---|---|
| `docker-compose config` | Validate and display resolved Compose configuration |
| `docker-compose -f base.yml -f dev.yml config` | Display configuration after combining files |
| `docker-compose up -d` | Start services in the background |
| `docker-compose ps` | List project containers |
| `docker-compose logs` | View service logs |
| `docker-compose down` | Stop and remove containers and project networks |
| `git status --short` | Show concise Git working-tree status |
| `git check-ignore -v .env` | Show which ignore rule applies to `.env` |

This lesson uses `docker-compose` with a hyphen, matching the Compose version previously reported on your machine.

## 10. Key points to remember

1. Environment variables provide configuration to applications.
2. `environment` defines variables directly in the Compose service configuration.
3. `env_file` loads variables from a file into a container.
4. The project `.env` file commonly supplies values for Compose variable substitution.
5. Override files help maintain different configurations for development and production.
6. Never commit real passwords, API keys, or tokens to GitHub.
7. `.env.example` documents required variables using placeholders.
8. A `.env` file is not encrypted.
9. Compose secrets provide file-based secret delivery, but do not replace a complete production secrets-management solution.
10. Check `.gitignore` and Git status before committing.

## 11. Self-check questions

1. What is an environment variable?
2. What is the purpose of the `environment` option?
3. What does `env_file` do?
4. What is the common purpose of the project `.env` file?
5. Why are `.env` and `env_file` not the same thing?
6. Why might a project use development and production override files?
7. What is a secret? Give three examples.
8. Why should real credentials never be committed to GitHub?
9. What is the purpose of `.env.example`?
10. What is one limitation of local Docker Compose secrets?

## 12. My notes

- Variables used:
- How configuration was passed:
- How the Compose files were combined:
- How secrets were kept out of Git:
- Problems encountered:
- How I solved them:
- What I learned:
