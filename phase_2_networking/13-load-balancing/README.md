# 13 — Load Balancing

## Learning Objectives
By the end of this module you should be able to:
- Explain what problem load balancing solves
- Distinguish Layer 4 vs. Layer 7 load balancing
- Describe common balancing algorithms and when to use each
- Explain what health checks are for
- Stand up a working load balancer in front of multiple backends with nginx + Docker

## Why This Matters
This module is the payoff for everything before it. An AWS ALB, an NLB, an nginx `upstream` block, a Kubernetes `Service` — they're all load balancers, differing mainly in *layer* (L4 vs L7) and *where they run*. Once you've built one by hand, the managed cloud versions stop being black boxes.

## Core Concepts

### The problem load balancing solves
A single server can only handle so much traffic, and if it goes down, everything depending on it goes down too. A **load balancer** sits in front of multiple backend servers, spreading requests across them — improving both capacity (horizontal scaling) and availability (if one backend dies, traffic just routes around it).

### Layer 4 vs. Layer 7
- **L4 (transport layer)**: balances based on IP/port only, without looking at the actual application data. Fast, protocol-agnostic, but "dumb" — it can't make decisions based on URL paths, headers, or cookies. Example: AWS Network Load Balancer (NLB).
- **L7 (application layer)**: understands HTTP. Can route `/api/*` to one backend pool and `/static/*` to another, inspect headers, handle SSL termination, and more. Example: nginx, HAProxy (in HTTP mode), AWS Application Load Balancer (ALB).

For most web application traffic, you'll reach for L7. L4 shows up more for raw TCP services or extreme low-latency needs.

### Balancing algorithms
| Algorithm | How it works | Good for |
|---|---|---|
| Round robin | Requests cycle evenly across backends, in order | Simple, stateless services with similar capacity |
| Least connections | New request goes to the backend with the fewest active connections | Backends with variable request duration |
| IP hash | Client's IP determines which backend they always hit | "Sticky" behavior without cookies |
| Weighted | Like round robin, but some backends get more traffic than others | Mixed-capacity backend hardware |

### Health checks
A load balancer periodically probes each backend (e.g., `GET /health` every few seconds). If a backend fails enough checks in a row, it's pulled out of rotation automatically — no human needs to intervene. This is the mechanism that turns "a server crashed" into "nobody noticed," which is the whole point of high availability.

### Sticky sessions (awareness level)
Some applications store session state in server memory, so a user must keep hitting the *same* backend. "Sticky sessions" (via cookie or IP hash) solve this at the load-balancer level — though the more scalable long-term fix is usually making backends stateless (session data in a shared store like Redis instead).

## Key Commands / Config Cheat Sheet
```nginx
upstream backend_pool {
    least_conn;
    server backend1:80;
    server backend2:80;
    server backend3:80;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend_pool;
    }
}
```

---

## Lab Exercise

### Prerequisites
- Docker and Docker Compose installed

### Steps
1. **Create three tiny backend "apps"** that just identify themselves — e.g., a folder per backend with an `index.html` containing `Hello from backend 1`, `2`, `3`.
2. **Write a `docker-compose.yml`**:
   ```yaml
   version: "3.8"
   services:
     backend1:
       image: nginx:alpine
       volumes:
         - ./backend1:/usr/share/nginx/html
     backend2:
       image: nginx:alpine
       volumes:
         - ./backend2:/usr/share/nginx/html
     backend3:
       image: nginx:alpine
       volumes:
         - ./backend3:/usr/share/nginx/html
     loadbalancer:
       image: nginx:alpine
       volumes:
         - ./lb.conf:/etc/nginx/conf.d/default.conf
       ports:
         - "8080:80"
       depends_on:
         - backend1
         - backend2
         - backend3
   ```
3. **Write `lb.conf`** using the round-robin config from the cheat sheet above, pointing at `backend1:80`, `backend2:80`, `backend3:80` (Docker Compose's internal DNS resolves those service names automatically).
4. **Bring it up**: `docker compose up -d`
5. **Test round robin**: hit the load balancer repeatedly and watch it cycle:
   ```bash
   for i in {1..6}; do curl -s http://localhost:8080; done
   ```
   You should see the "Hello from backend N" responses rotate.
6. **Simulate a failure**: `docker compose stop backend2`, then repeat the curl loop. Depending on your nginx config, you may see errors until you add a basic health check / `max_fails` setting — this is the gap that real health checks close:
   ```nginx
   server backend2:80 max_fails=1 fail_timeout=5s;
   ```
7. **Switch algorithms**: change `least_conn;` to nothing (default round robin) vs. `ip_hash;` and observe how repeated requests from your one test client behave differently under `ip_hash` (you should keep landing on the *same* backend).

### Checkpoint Questions
1. Why would you choose an L7 load balancer over an L4 one for a typical web application?
2. What actually happens, step by step, when a health check fails for a backend?
3. In the `ip_hash` test, why did your requests keep landing on the same backend instead of rotating?
4. If your backends store session data in local memory instead of a shared store like Redis, what load-balancing problem does that create?
