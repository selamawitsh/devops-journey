# Lesson 7 — Building and Testing Pipelines

## Learning objectives
- Explain why CI should run automated checks.
- Set up the application environment on a runner.
- Run linting, tests, and a build command.
- Understand how exit codes affect pipeline status.

## 1. Purpose
A CI pipeline should give reliable feedback about a change before it is merged or released. It should execute the same documented checks consistently.

Common checks:
- Formatting and linting.
- Static analysis.
- Unit tests.
- Integration tests.
- Compilation or packaging.
- Security and dependency checks.

Choose checks that match the language and framework of the application.

## 2. Typical job sequence
1. Check out repository source.
2. Set up the required runtime (for example, Java, Go, or Node.js).
3. Install or download dependencies.
4. Run linting/format checks.
5. Run tests.
6. Build/package the application.

## 3. Example: Go CI
This is an example for a Go repository. Adjust the Go version and commands to match the project.
```yaml
name: Go CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.23'

      - name: Format check
        run: test -z "$(gofmt -l .)"

      - name: Run tests
        run: go test ./...

      - name: Build
        run: go build ./...
```

The version is illustrative; use a version supported by the project and current action documentation.

## 4. Exit codes
Most shell commands return an exit code:
- `0` usually means success.
- A non-zero value usually indicates failure.

GitHub Actions normally marks a `run` step as failed when its command exits non-zero. This is useful because a failing test should make the job fail rather than silently pass.

Avoid hiding failures with patterns such as blindly appending `|| true`.

## 5. Make checks meaningful
- Run the same checks locally when possible.
- Ensure tests are deterministic.
- Do not skip failing tests just to get a green workflow.
- Keep dependencies explicit.
- Separate fast feedback from slower integration tests when useful.
- Make failure output readable.

## 6. Build output
A build may produce a binary, JAR, package, or other output. A later lesson covers how to preserve outputs as workflow artifacts or publish container images.

## Review questions
1. Why should linting and tests run in CI?
2. What does a non-zero exit code usually mean?
3. Why should CI use the same checks as local development?
4. What is the purpose of a build step?
5. Why is `|| true` dangerous when used to hide a failed test?

## Practical checkpoint
Choose one existing project, add a CI workflow that performs its real setup, lint/test, and build commands, then intentionally introduce a failing test and observe the result.

## Completion record
- [ ] The workflow checks out the source.
- [ ] The workflow installs or selects the correct runtime.
- [ ] Lint/test/build commands match the project.
- [ ] I can explain why a failed command makes the workflow fail.

## References
Add the official setup-action and language test/build documentation used.
