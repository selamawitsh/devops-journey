# Notes: YAML Basics

## What is YAML?
- YAML is a human-readable data/configuration format.
- Docker Compose reads a YAML file to understand the application configuration.
- Common Compose filenames are `compose.yaml` and `docker-compose.yml`.

## Basic YAML structures

### Key-value pair
```yaml
image: nginx:alpine
```
`image` is the key; `nginx:alpine` is its value.

### List
```yaml
ports:
  - "8080:80"
  - "8443:443"
```
Each hyphen introduces one list item.

### Nested mapping
```yaml
services:
  web:
    image: nginx:alpine
```
`web` is nested under `services`; `image` is nested under `web`.

## Rules to remember
1. Use spaces for indentation; do not use tabs.
2. Keep indentation consistent.
3. A colon separates a key from its value.
4. A hyphen introduces a list item.
5. Use `#` to write a comment.
6. Quote port mappings such as `"8080:80"`.

## Read this Compose example
```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```
- `services`: top-level section.
- `web`: service name.
- `image`: image Compose should use.
- `ports`: list of port mappings.
- `"8080:80"`: publish container port 80 on host port 8080.

## Mini exercise
Create a file named `compose.yaml` with the example above. Save it, then from that directory run:

```bash
docker-compose config
```

This asks Docker Compose to parse and display the resolved configuration. If it reports an error, check spelling and indentation.

## Key takeaway
YAML describes configuration; Docker Compose uses that configuration to create and manage the containers for your application.


## Four Questions Docker Compose Answers for Every Service

Whenever you add a service to Docker Compose, you are essentially answering these four questions for Docker:

| Question Docker Asks | YAML Property | Example Answer |
|---|---|---|
| **How do I make it?** | `build:` (custom) OR `image:` (pre-made) | Look in my local folder `./services/auth` |
| **What should I name the package?** | `image:` | Name the built result `my-auth-app:latest` |
| **What virtual wires should I plug it into?** | `networks:` | Connect it to the `ecommerce-network` |
| **Who does it need to wait for?** | `depends_on:` | Wait until `message-broker` is alive |

### Important things to understand

- `build:` tells Docker Compose where to find the files needed to build a custom image.
- `image:` tells Docker Compose which image to use or what name to give a built image when used with `build:`.
- `networks:` specifies which Docker networks the service joins.
- `depends_on:` specifies service startup dependencies. Remember, it does not automatically guarantee that the dependency is ready to accept requests.
