# Lab 1 Notes — First Compose File

## File
`compose.yaml`

## Configuration
```yaml
version: "3.8"
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```

## Commands
```bash
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```

## Expected result
Nginx is reachable at `http://localhost:8080` while the service is running.

## My actual results
- Did the image download?
- What did `docker-compose ps` show?
- Did the web page open?
- What happened after `docker-compose down`?
- Errors and fixes:
