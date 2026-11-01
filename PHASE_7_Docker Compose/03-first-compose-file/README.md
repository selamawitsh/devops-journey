# Lab 1 — Run Your First Service with Docker Compose

## Objective
Create a tiny Compose project, start Nginx, access it from the host, inspect it, and stop it.

## Requirements
- Docker installed and running.
- Docker Compose available (`docker-compose version` should work).

## Step 1: Inspect the Compose file
This folder contains `compose.yaml`:
```yaml
version: "3.8"

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```

Explanation:
- `services` starts the service definitions.
- `web` is the Compose service name.
- `image` selects the Nginx image.
- `ports` maps host port 8080 to container port 80.

## Step 2: Start the service
Run from this folder:
```bash
docker-compose up -d
```

The first run may download the Nginx image. The `-d` flag runs it in the background.

## Step 3: Check the service
```bash
docker-compose ps
docker ps
docker-compose logs
```

Open `http://localhost:8080` in your browser. You should see the Nginx welcome page.

## Step 4: Stop the project
```bash
docker-compose down
```

## Step 5: Record evidence
Add your own screenshot of the Nginx page and terminal output to your repository if desired. Do not claim the lab is complete until you have run it successfully.

## Troubleshooting
- If Docker says it cannot connect to the daemon, check that the Docker service is running and that your user has permission to access it.
- If port 8080 is already in use, change the host side of the mapping, for example `"8081:80"`, then rerun `docker-compose up -d`.
- If `docker-compose` is not found, check the installed Compose command/version.


