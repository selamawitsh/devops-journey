# Lesson 6 — Triggers, Jobs, Steps, and Runners

## Learning objectives
- Configure common workflow triggers.
- Explain the role of jobs and steps.
- Understand runner selection.
- Configure job dependencies with `needs`.

## 1. Triggers (`on`)
A workflow trigger defines when GitHub Actions should start a workflow.

Common triggers include:
- `push`: when commits are pushed.
- `pull_request`: when pull-request activity occurs.
- `workflow_dispatch`: manual run from GitHub or API.
- `schedule`: scheduled execution using a cron expression.
- `release`: release-related activity.

Example:
```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

For pull requests, review the event activity types and branch filters needed by the workflow.

## 2. Jobs
A job is a group of steps executed on a runner. Jobs can run in parallel unless dependencies or other constraints require ordering.

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Linting"

  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing"
```

Here, `lint` and `test` can run independently.

## 3. Job dependencies (`needs`)
Use `needs` when a job must wait for another job to finish successfully.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Run tests"

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: echo "Build application"
```

The `build` job depends on `test`.

## 4. Steps
Steps execute sequentially inside a job. A step can:
- Run a shell command with `run`.
- Invoke a reusable action with `uses`.

Steps in the same job share the job's runner environment and workspace. Separate jobs normally run in separate environments, so files do not automatically carry over between jobs.

## 5. Runners
A runner is the machine that executes a job.

GitHub-hosted runners are maintained by GitHub and provide supported operating-system images. Self-hosted runners are machines that the repository or organization manages.

Consider:
- Operating system requirements.
- Required tools and software.
- Network access.
- Security and isolation.
- Cost and maintenance.
- Whether the runner needs access to private infrastructure.

## 6. Full example
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint placeholder
        run: echo "Run lint command here"

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Test placeholder
        run: echo "Run test command here"

  build:
    needs: [lint, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build placeholder
        run: echo "Build only after checks pass"
```

The commands are placeholders. Replace them with the actual commands for the application.

## Review questions
1. What is a workflow trigger?
2. What is the difference between `push` and `pull_request`?
3. How can two jobs run in parallel?
4. What does `needs` do?
5. Why do files not automatically appear in another job?

## Practical checkpoint
Create a workflow with separate lint and test jobs, then a build job that depends on both. Push a change and inspect the execution order.

## Completion record
- [ ] I can configure push and pull-request triggers.
- [ ] I can explain runner, job, and step.
- [ ] I can use `needs` to control job order.

## References
Add official documentation links used during study.
