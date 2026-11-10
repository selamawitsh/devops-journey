# Phase 8 — CI/CD with GitHub Actions

**Roadmap phase:** 8 of 18  
**Repository:** `github-actions`  
**Level:** Junior  
**Scope:** Lessons 1–10 of the updated Phase 8 learning sequence

This repository documents the CI/CD learning phase. Each lesson has two files:
- `README.md` — lesson objective, hands-on checklist, evidence, and reflection.
- `NOTES.md` — study notes, examples, and review questions.

## Lesson index

| Lesson | Topic | Folder |
|---:|---|---|
| 1 | CI/CD fundamentals | `01-cicd-fundamentals/` |
| 2 | Git and GitHub basics | `02-git-and-github-basics/` |
| 3 | Understanding CI/CD pipelines | `03-understanding-cicd-pipelines/` |
| 4 | GitHub Actions fundamentals | `04-github-actions-fundamentals/` |
| 5 | Workflow YAML syntax | `05-workflow-yaml-syntax/` |
| 6 | Triggers, jobs, steps, and runners | `06-triggers-jobs-steps-runners/` |
| 7 | Building and testing pipelines | `07-building-and-testing-pipelines/` |
| 8 | Matrix builds, caching, and artifacts | `08-matrix-caching-artifacts/` |
| 9 | Docker build and push in CI | `09-docker-build-and-push-in-ci/` |
| 10 | Deployment automation | `10-deployment-automation/` |

## Phase 8 final project target

The roadmap's Phase 8 project is an automated pipeline that:
1. Receives code from GitHub.
2. Runs linting and tests.
3. Builds a Docker image.
4. Pushes the image to a container registry.
5. Deploys the application to a server.
6. Handles secrets securely.

The roadmap also includes Jenkins fundamentals and pipeline debugging in the full Phase 8 scope. These are beyond the first ten lessons documented here and should be added as later lesson folders.

## Important documentation rule

These files are learning records and templates. Update each README with the commands, workflow runs, screenshots, and lessons you **actually** completed. Do not present an example workflow as a working production deployment until you have implemented and tested it.

## Roadmap alignment

The contents align with Phase 8 in the supplied 18-phase DevOps roadmap. The roadmap describes CI/CD concepts, GitHub Actions, build/test pipelines, Docker build and push, deployment automation, secrets, Jenkins, debugging, and a full CI pipeline project.
