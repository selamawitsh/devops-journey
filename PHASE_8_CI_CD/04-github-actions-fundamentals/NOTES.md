# Lesson 4 — GitHub Actions Fundamentals

## Learning objectives
- Explain what GitHub Actions is.
- Identify workflows, events, jobs, steps, actions, and runners.
- Locate workflow files in a repository.
- Explain how a workflow run is displayed in GitHub.

## 1. What is GitHub Actions?
GitHub Actions is GitHub's automation platform. It can automate software workflows such as building, testing, packaging, and deploying applications in response to repository events or manual/scheduled triggers.

## 2. Main components
- **Workflow:** an automated process defined in a YAML file.
- **Event:** something that triggers a workflow, such as `push` or `pull_request`.
- **Job:** a set of steps that runs on a runner.
- **Runner:** the machine/environment that executes a job.
- **Step:** an individual task within a job.
- **Action:** a reusable unit of automation that can be used as a step.
- **Workflow run:** one execution of a workflow.

## 3. Workflow location
GitHub Actions workflow files are stored in:
```text
.github/workflows/
```

For example:
```text
project/
└── .github/
    └── workflows/
        └── ci.yml
```

The YAML file describes when the workflow runs and what jobs it performs.

## 4. Conceptual example
```yaml
name: Basic CI

on:
  push:
    branches: [main]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - name: Get repository code
        uses: actions/checkout@v4

      - name: Show a message
        run: echo "The workflow is running"
```

This example:
- Names the workflow `Basic CI`.
- Runs on pushes to `main`.
- Defines one job named `check`.
- Requests an Ubuntu runner.
- Checks out the repository.
- Executes a shell command.

The action version shown is an example; review action versions and security guidance before using them in a real project.

## 5. `uses` vs `run`
- `uses` calls an action.
- `run` executes shell commands in the runner environment.

Example:
```yaml
- name: Check current directory
  run: pwd
```

## 6. Workflow run lifecycle
1. An event occurs.
2. GitHub evaluates which workflows match the event.
3. A workflow run is created.
4. Eligible jobs are assigned to runners.
5. Steps execute in order within each job.
6. GitHub records logs and a final status.

## 7. Where to inspect results
In a GitHub repository, open the **Actions** tab. Select a workflow run to inspect:
- Overall status.
- Jobs.
- Individual steps.
- Logs.
- Failure messages.

## Review questions
1. What is GitHub Actions used for?
2. Where are workflow files stored?
3. What is a runner?
4. What is the difference between `uses` and `run`?
5. Where do you inspect a failed workflow?

## Practical checkpoint
Create a minimal workflow that runs on a push to `main`, checks out the code, and prints a message. Push it and inspect the workflow run in the Actions tab.

## Completion record
- [ ] I can identify the main GitHub Actions components.
- [ ] I know where workflow files belong.
- [ ] I can inspect a workflow run and its logs.

## References
Add the official GitHub Actions documentation pages used.
