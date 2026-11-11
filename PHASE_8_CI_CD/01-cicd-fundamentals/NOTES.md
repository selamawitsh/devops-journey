# Lesson 1 — CI/CD Fundamentals

## Learning objectives
- Explain the problem CI/CD solves.
- Distinguish Continuous Integration (CI), Continuous Delivery (CD), and Continuous Deployment (CD).
- Describe a typical software delivery pipeline.
- Explain the benefits and risks of automation.

## 1. Why CI/CD exists
Without automation, developers may integrate code infrequently, run tests manually, build release packages by hand, and deploy through inconsistent steps. This creates late integration problems, human error, slow feedback, and releases that are difficult to reproduce.

CI/CD makes the path from a code change to a tested build—and potentially a running application—repeatable.

## 2. Continuous Integration (CI)
Continuous Integration is the practice of frequently merging small code changes into a shared repository and automatically validating each change.

A CI workflow commonly:
1. Receives a push or pull request.
2. Checks out the repository.
3. Installs required dependencies.
4. Runs linting or static checks.
5. Runs automated tests.
6. Reports success or failure.

The purpose is fast feedback. CI does not automatically mean that the application is deployed.

## 3. Continuous Delivery
Continuous Delivery keeps the application in a deployable state. The pipeline builds and validates a release candidate, and the release can be deployed when an authorized person or process approves it.

A production deployment may require a manual approval or release decision.

## 4. Continuous Deployment
Continuous Deployment goes one step further: every change that passes the required automated checks is automatically released to production.

This requires confidence in automated tests, monitoring, rollback procedures, and release controls.

## 5. CI vs Continuous Delivery vs Continuous Deployment

| Practice | Main outcome | Production release |
|---|---|---|
| CI | Changes are integrated and validated | Not implied |
| Continuous Delivery | A validated version is always ready to release | Usually requires approval |
| Continuous Deployment | Validated changes are released automatically | Automatic |

## 6. Typical pipeline stages
A pipeline may contain:
- **Source:** detect a push, pull request, or release.
- **Build:** compile/package the application or create an image.
- **Test:** run unit, integration, and other automated checks.
- **Package:** produce an artifact or container image.
- **Publish:** store the artifact in a registry.
- **Deploy:** release it to a target environment.
- **Verify:** perform health checks and observe the deployment.

Not every pipeline has every stage. The design depends on the application and delivery requirements.

## 7. Benefits
- Earlier feedback about defects.
- Repeatable builds and deployments.
- Less manual repetitive work.
- More consistent release processes.
- Smaller changes that are easier to investigate.
- Better visibility into whether a change passed validation.

## 8. Risks and controls
Automation can also make a mistake happen faster. Use:
- Automated tests and code checks.
- Protected branches and required status checks.
- Least-privilege credentials.
- Secret storage rather than hard-coded credentials.
- Staging environments and approval gates where appropriate.
- Health checks, logs, and rollback plans.

## 9. Key terms
- **Pipeline:** automated sequence of jobs or stages.
- **Build:** process of turning source code into a runnable/packageable output.
- **Artifact:** output saved from a build, such as a JAR, binary, or test report.
- **Deployment:** making a version available in an environment.
- **Rollback:** returning to a previous known-good version.
- **Feedback loop:** time between making a change and learning whether it works.

## Review questions
1. Does CI automatically deploy to production? Explain.
2. What is the difference between Continuous Delivery and Continuous Deployment?
3. Why should changes be integrated frequently?
4. Name five common pipeline stages.
5. Why can automation increase risk if tests and permissions are weak?

## Practical checkpoint
Draw a simple pipeline for a small application. Label where code is checked, tested, packaged, published, and deployed. Mark which steps are automated and where a human approval might be required.

## Completion record
- [ ] I can explain CI, Continuous Delivery, and Continuous Deployment.
- [ ] I can describe a basic pipeline from commit to deployment.
- [ ] I can explain at least three benefits and three safety controls.

## References
These notes follow the CI/CD concepts and pipeline-stage focus of Phase 8 in the DevOps roadmap. Add links to the documentation or learning resources actually used during study.
