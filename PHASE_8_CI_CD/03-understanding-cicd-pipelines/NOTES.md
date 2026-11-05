# Lesson 3 — Understanding CI/CD Pipelines

## Learning objectives
- Define a pipeline and its stages.
- Explain the difference between a stage, job, and step at a conceptual level.
- Understand dependencies and execution order.
- Trace a code change through a pipeline.

## 1. What is a pipeline?
A CI/CD pipeline is an automated workflow that takes a software change through a defined set of checks and delivery activities. It turns a repeatable process into executable configuration.

A pipeline should make it clear:
- What event starts it.
- What work must be performed.
- What must succeed before later work begins.
- What output is produced.
- Where the output is stored or deployed.
- How success or failure is reported.

## 2. Example pipeline flow
```text
Developer pushes code
        |
        v
Source checkout
        |
        v
Install dependencies
        |
        v
Lint / static checks
        |
        v
Run tests
        |
        v
Build application
        |
        v
Build container image
        |
        v
Publish image
        |
        v
Deploy to environment
        |
        v
Health check / verification
```

A small project may omit some stages. For example, a documentation-only repository may not need a compilation or Docker stage.

## 3. Stage, job, and step
These words are used differently by different CI systems, so always check the platform's terminology.

- **Stage:** a logical phase of a pipeline, such as test or deploy.
- **Job:** a unit of work assigned to an execution environment. Jobs may run sequentially or in parallel depending on dependencies and platform configuration.
- **Step:** an individual action or command within a job.

In GitHub Actions, a workflow contains jobs, and each job contains steps. GitHub Actions does not require a separate `stages` keyword.

## 4. Dependencies and order
A pipeline must express which work depends on other work.

Example:
- `test` should complete successfully before `build` begins.
- `publish` should depend on a successful image build.
- `deploy` should depend on a successful publish.

Independent checks, such as linting and unit tests, may run in parallel to reduce feedback time.

## 5. Failure behavior
A well-designed pipeline should stop unsafe downstream work when a required check fails.

Example: if tests fail, the pipeline should not publish and deploy that unvalidated version. Some systems support explicit conditions for cleanup or reporting steps that should still run after a failure.

## 6. Artifacts and outputs
A job may produce:
- A compiled application.
- A test report.
- A coverage report.
- A packaged archive.
- A container image.

An artifact is a saved output that later jobs or people can retrieve. A container image is commonly stored in a container registry.

## 7. Feedback and traceability
Useful pipeline feedback includes:
- Which commit was tested.
- Which job or step failed.
- The command and error output.
- Test results.
- The artifact or image version produced.
- Whether deployment and health checks succeeded.

Use immutable identifiers, such as a commit SHA or version tag, to make it clear what was built and deployed.

## 8. Pipeline design principles
- Keep jobs focused and understandable.
- Fail early on fast checks.
- Avoid repeating expensive setup unnecessarily.
- Keep secrets out of source code and logs.
- Make deployment depend on validated build output.
- Record enough information to troubleshoot failures.
- Prefer reproducible builds and explicit versions.

## Review questions
1. What is a CI/CD pipeline?
2. What is the difference between a job and a step in GitHub Actions?
3. Which stages should run before publishing an image?
4. Why might linting and tests run in parallel?
5. Why should deployment depend on successful validation?

## Practical checkpoint
Draw a pipeline for a simple web application. Identify its trigger, jobs, steps, dependencies, artifacts, and failure points. Explain what should happen when unit tests fail.

## Completion record
- [ ] I can trace a commit through a pipeline.
- [ ] I can explain jobs, steps, and dependencies.
- [ ] I can explain how pipeline failure prevents unsafe delivery.

## References
Add the resources actually used during this lesson.
