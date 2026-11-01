# Lesson 2: YAML Basics

## Learning goals
By the end of this lesson, you should be able to:
- Explain what YAML is and why Docker Compose uses it.
- Recognize mappings (key-value pairs), lists, strings, numbers, and Boolean values.
- Understand indentation and why spaces matter.
- Read the basic structure of a Compose file.

## 1. What is YAML?
YAML is a human-readable format for writing configuration. Docker Compose uses a YAML file (usually named `compose.yaml` or `docker-compose.yml`) to describe the services, networks, and volumes that make up an application.

## 2. Key-value pairs
A key is written before a colon, followed by its value:

```yaml
name: agri-yield
version: "1.0"
```

## 3. Lists
A list contains multiple items. Each item starts with a hyphen:

```yaml
services:
  - api
  - database
  - cache
```

## 4. Indentation
YAML uses indentation to show which values belong together. Use spaces, not tabs. Keep indentation consistent.

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
```

Here, `web` belongs to `services`; `image` and `ports` belong to `web`; and the port mapping is an item in the `ports` list.

## 5. Comments and quoted values
A comment starts with `#`. Quote port mappings because they are strings:

```yaml
services:
  web:
    image: nginx:alpine # Official lightweight Nginx image
    ports:
      - "8080:80"
```

## 6. How this connects to Docker Compose
A Compose file commonly has a top-level `services` section. Each service describes a container Compose should run. Later, you will also learn `volumes` and `networks`.

## Practice
1. Identify the keys in the example above.
2. Which values are lists?
3. What does the indentation tell you?
4. Change the host port from `8080` to `8081`. What URL would you open in your browser?

## Important reminder
YAML is indentation-sensitive. If the indentation is wrong, Compose may reject the file or interpret it differently.
