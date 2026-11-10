# Lesson 9 — Docker Build and Push in CI

## Learning objectives
- Explain why container image builds belong in CI.
- Build an image from a repository Dockerfile.
- Authenticate to a registry securely.
- Tag and publish an image.
- Understand the difference between building and pushing.

## 1. Why build images in CI?
Building an image in a workflow makes the process repeatable and ties the image to a specific source revision. The pipeline can run tests first, build the image only after validation, and publish it for deployment.

## 2. Image naming and tags
A container image reference generally follows:
```text
registry/namespace/image:tag
```

Examples:
```text
ghcr.io/example-org/sample-api:latest
ghcr.io/example-org/sample-api:1.0.0
ghcr.io/example-org/sample-api:<commit-sha>
```

Avoid relying only on `latest` for deployment traceability. A commit SHA or release version identifies the exact image more clearly.

## 3. Build vs push
- **Build:** create the image locally on the runner.
- **Tag:** assign a name/version to the image.
- **Push:** upload the image to a registry.

A successful build does not mean the image has been published.

## 4. Example workflow outline
The following is a conceptual example for GitHub Container Registry (GHCR). Replace the image name and verify current action versions and permissions before using it.

```yaml
name: Build and Push Image

on:
  push:
    branches: [main]

permissions:
  contents: read
  packages: write

jobs:
  image:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ghcr.io/OWNER/IMAGE:latest
```

Replace `OWNER` and `IMAGE` with the appropriate lowercase registry namespace and image name. The workflow token needs only the permissions required for the operation.

## 5. Security
- Do not put registry passwords directly in YAML.
- Use GitHub-provided tokens or repository/environment secrets as appropriate.
- Grant only the permissions required.
- Do not print credentials.
- Review third-party actions and pinning/security practices.
- Avoid publishing images from untrusted pull-request contexts with write permissions.

## 6. Quality gates
A stronger workflow orders work like this:
```text
Checkout -> Lint -> Test -> Build image -> Push image
```

The image should not be published if required tests fail.

## 7. Verify publication
After a successful run:
- Open the registry package page.
- Confirm the expected image and tag exist.
- Check that the tag corresponds to the intended commit.
- Pull the image in a separate environment if appropriate.

## Review questions
1. What is the difference between building and pushing an image?
2. Why are immutable tags useful?
3. Why should tests run before publishing?
4. What does `packages: write` allow in this example?
5. Why should credentials not be written directly in YAML?

## Practical checkpoint
Add a Dockerfile to a small application, create a workflow that tests and builds it, and publish it to a registry using secure authentication. Record the image name and tag (never record credentials).

## Completion record
- [ ] The workflow builds the image.
- [ ] The workflow authenticates securely.
- [ ] The image is pushed to the intended registry.
- [ ] The published tag can be traced to a source revision.

## References
Add the Docker build/push action, GHCR, and GitHub token permissions documentation used.
