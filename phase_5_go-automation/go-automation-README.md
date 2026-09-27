# Go for DevOps Automation (Phase 5)

Part of `devops-journey`. This phase treats Go as an Intern -> Junior DevOps automation language: building real tools (auditors, health checkers, CLI tools) rather than learning Go as a general-purpose language in isolation.

Each module below is its own folder with its own `README.md`. Each lesson inside a module has three files: `lesson-N-notes.md`, `lesson-N-recall.md`, `lesson-N-exercise.md`, plus the actual Go code.

Workflow per topic: learn the concept, do the exercise, get it reviewed, commit, then move on. No topic is skipped ahead of schedule.

---

## Modules

| Module | Covers | Status |
|---|---|---|
| [01-go-fundamentals](01-go-fundamentals/README.md) | syntax, variables, functions, control flow, arrays/slices, maps, structs, error handling | In progress |
| 02-modules-and-packages | `go.mod`, imports, package design | Not started |
| 03-files-and-system | files, directories, OS information | Not started |
| 04-working-with-apis | HTTP client, JSON, authentication, retry/backoff | Not started |
| 05-aws-sdk | EC2, S3, IAM automation | Not started |
| 06-config-parsing | JSON, YAML, config generation | Not started |
| 07-os-exec | safely executing system commands | Not started |
| 08-concurrency | goroutines, channels | Not started |
| 09-cli-tools | `flag`, then Cobra | Not started |
| 10-logging-errors | structured logging, error wrapping | Not started |
| 11-testing | Go testing, table-driven tests | Not started |
| 12-build-distribution | builds, cross-compilation | Not started |

## Projects

Built once the matching modules are done, combining several concepts each:

| Project | Depends on |
|---|---|
| projects/01-aws-resource-auditor | 04-working-with-apis, 05-aws-sdk |
| projects/02-config-generator | 06-config-parsing |
| projects/03-server-health-checker | 08-concurrency |
| projects/04-devops-toolkit | 09-cli-tools, 10-logging-errors, 11-testing, 12-build-distribution |

## Current progress

- Module 01, Lesson 1 (hello-go): complete
- Module 01, Lesson 2 (variables): in review
