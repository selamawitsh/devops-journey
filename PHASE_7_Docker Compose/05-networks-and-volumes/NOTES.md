# Networks and Volumes Notes

## Networks
Services connected to the same Compose network can generally reach one another using the service name as the hostname.

## Ports
- `ports`: publishes a container port to the host.
- `expose`: documents a port for container-to-container use; it does not publish that port to the host.

## Volumes
- Named volume: managed by Docker and useful for persistent container data.
- Bind mount: maps a host path into a container.

## My observations
- Network created:
- Volume created:
- What data persisted after container recreation:
