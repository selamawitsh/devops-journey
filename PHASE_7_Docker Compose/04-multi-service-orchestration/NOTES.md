# Multi-Service Orchestration Notes

## Key idea
A Compose project can define several services and their relationships.

## `depends_on`
`depends_on` expresses dependency/startup ordering. Basic dependency ordering does not guarantee that the dependency is fully ready to accept connections.

## Health checks
A health check runs a command to determine whether a service is healthy. A dependent application should also handle temporary connection failures and retry.

## My notes
- Example:
- Command run:
- Observations:
