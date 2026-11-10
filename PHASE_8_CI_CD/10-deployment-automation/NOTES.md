# Lesson 10 — Deployment Automation

## Learning objectives
- Explain the purpose of deployment automation.
- Understand a basic deployment flow from CI to a server.
- Identify common SSH-based deployment requirements.
- Store deployment credentials securely.
- Include deployment verification and failure handling.

## 1. What is deployment automation?
Deployment automation uses scripts or CI/CD workflows to release a specific application version to an environment in a repeatable way.

It reduces manual steps and makes deployments more consistent. It does not remove the need for safe configuration, access control, testing, and recovery planning.

## 2. Typical flow
```text
Push / merge to main
        |
        v
Lint and test
        |
        v
Build application / Docker image
        |
        v
Publish versioned image
        |
        v
Connect to deployment target
        |
        v
Pull the intended image / release
        |
        v
Restart or update service
        |
        v
Health check
        |
        v
Report deployment result
```

For the Phase 8 portfolio project, deployment automation is a pipeline capability. The roadmap notes that a live-server deployment can be extended once the later AWS/Ansible phases are complete.

## 3. Common deployment approaches
- **SSH-based deployment:** workflow connects to a server and runs controlled deployment commands.
- **Deployment webhook:** workflow calls an authenticated endpoint that starts deployment.
- **Platform-native deployment:** workflow publishes an artifact or image and a hosting platform performs the rollout.

Choose an approach based on the target platform and its security model.

## 4. SSH deployment requirements
A typical SSH-based approach needs:
- A deployment host and user.
- Network access from the runner to the host.
- An SSH private key stored as a secret.
- The corresponding public key installed for the deployment user.
- Host-key verification.
- Least-privilege server permissions.
- A deployment script with predictable behavior.

Do not disable host-key checking as a shortcut in production. Verify the server identity using a trusted known-hosts entry or an equivalent secure approach.

## 5. Secrets and environment protection
Store sensitive values in GitHub Secrets or an appropriately scoped environment:
- SSH private key.
- Deployment hostname, if treated as sensitive by the project.
- Registry credentials, if not using a short-lived token.
- Other deployment credentials.

Use environment protection rules and required reviewers for sensitive production deployments where appropriate. Do not echo secret values into logs.

## 6. Make deployment repeatable
A deployment script should:
1. Identify the version to deploy.
2. Fetch or pull that exact version.
3. Update the service/container.
4. Check whether the service started.
5. Run a health check.
6. Return a non-zero exit status if deployment failed.

Avoid deploying an ambiguous `latest` image when a commit SHA or release tag can be used.

## 7. Verification and rollback
A successful SSH command does not prove the application is healthy.

Verification can include:
- Checking service/container status.
- Calling a health endpoint.
- Checking application logs.
- Confirming the expected version is running.

A rollback plan should identify the previous known-good image or release and define how to restore it. Practice the process in a test environment before relying on it.

## 8. Deployment safety
- Deploy only after required CI checks pass.
- Restrict production deployment permissions.
- Separate development, staging, and production environments.
- Use protected environments or approvals where appropriate.
- Keep credentials out of the repository.
- Verify host identity.
- Log deployment metadata without exposing secrets.
- Have a recovery plan.

## 9. Example job dependency
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Run real tests here"

  deploy:
    needs: test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy placeholder
        run: echo "Run a secure deployment script here"
```

This is only a structural example. It does not perform a real deployment. Add the correct deployment mechanism, credentials, host verification, and health checks for the chosen environment.

## Review questions
1. Why should deployment depend on successful tests?
2. What information is needed for SSH-based deployment?
3. Why is host-key verification important?
4. Why is a commit-specific image tag safer than an ambiguous tag?
5. What should a deployment health check verify?
6. What is the purpose of a rollback plan?

## Practical checkpoint
In a safe test environment, document the target, deployment method, secrets required, deployment steps, health check, and rollback method. Implement the deployment only when the target server and credentials are ready.

## Completion record
- [ ] I can explain the deployment flow.
- [ ] I understand SSH credentials and host verification.
- [ ] I know how to store deployment secrets safely.
- [ ] I can describe verification and rollback.
- [ ] I understand that the example workflow is not a completed live deployment.

## References
Add the GitHub Actions deployment, environments/secrets, SSH, and container registry documentation used.
