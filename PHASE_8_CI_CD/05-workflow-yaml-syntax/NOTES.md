# Lesson 5 — Workflow YAML Syntax

## Learning objectives
- Recognize YAML mappings, sequences, strings, booleans, and indentation.
- Understand the main top-level workflow keys.
- Read a simple GitHub Actions workflow.
- Avoid common YAML formatting errors.

## 1. YAML basics
YAML is a human-readable data-serialization format. GitHub Actions workflow files use YAML.

Mapping:
```yaml
name: CI
```

Sequence:
```yaml
branches:
  - main
  - develop
```

Inline sequence:
```yaml
branches: [main, develop]
```

Nested mapping:
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
```

## 2. Indentation matters
YAML uses indentation to represent structure. Use consistent spaces (commonly two spaces per level). Do not use tabs for indentation.

Incorrect indentation can change the structure or make the file invalid.

## 3. Common workflow keys
- `name`: workflow display name.
- `on`: event or events that trigger the workflow.
- `permissions`: permissions granted to the workflow's token.
- `env`: environment variables.
- `jobs`: jobs that make up the workflow.
- `runs-on`: runner environment for a job.
- `steps`: ordered list of steps.
- `uses`: action used by a step.
- `run`: shell command(s) executed by a step.
- `with`: inputs passed to an action.
- `needs`: job dependencies.

## 4. Example workflow
```yaml
name: CI

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout source
        uses: actions/checkout@v4

      - name: Print a message
        run: echo "CI started"
```

## 5. Multiline commands
A step can run multiple shell commands:
```yaml
- name: Inspect project
  run: |
    pwd
    ls -la
    git --version
```

The `|` block scalar preserves line breaks in the multiline value.

## 6. Expressions and contexts
GitHub Actions supports expressions, commonly written using `${{ ... }}`. Expressions can access contexts and functions.

Example:
```yaml
- name: Print branch
  run: echo "Branch: $GITHUB_REF"
```

Shell environment variables and GitHub Actions expressions are not interchangeable. Use the appropriate syntax for the context in which a value is evaluated.

## 7. Common mistakes
- Inconsistent indentation.
- Putting a step outside `steps`.
- Using `uses` and `run` incorrectly.
- Forgetting that `needs` references job IDs.
- Accidentally giving a workflow broader token permissions than required.
- Committing secrets in YAML.

## Review questions
1. What does indentation represent in YAML?
2. What is the purpose of `jobs`?
3. What is the difference between `uses` and `run`?
4. What does `needs` do?
5. Why should workflow permissions be limited?

## Practical checkpoint
Write a workflow with a name, a push trigger, one Ubuntu job, and two steps. Validate it by pushing it to GitHub and reviewing the Actions tab.

## Completion record
- [ ] I can read nested YAML structures.
- [ ] I can explain the key workflow fields.
- [ ] I can write a small workflow without indentation errors.

## References
Add the YAML and GitHub Actions syntax documentation used.
