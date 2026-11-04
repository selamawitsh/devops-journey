# Lesson 2 — Git and GitHub Basics

## Learning objectives
- Explain the difference between Git and GitHub.
- Describe the local-to-remote repository workflow.
- Recognize commits, branches, pushes, pull requests, and merges.
- Connect GitHub repository events to CI automation.

## 1. Git vs GitHub
**Git** is a distributed version control system. It records project history as commits and supports branching and merging.

**GitHub** is a hosting and collaboration platform for Git repositories. It adds pull requests, issues, access controls, branch protection, releases, and GitHub Actions.

Git can be used without GitHub. GitHub repositories use Git for version control.

## 2. Core terms
- **Repository:** project files plus version history.
- **Working tree:** files currently checked out on disk.
- **Staging area:** selected changes prepared for the next commit.
- **Commit:** saved snapshot with a message and metadata.
- **Branch:** movable reference to a line of development.
- **Remote:** another copy of the repository, often hosted on GitHub.
- **Push:** send local commits to a remote.
- **Pull:** fetch and integrate remote changes.
- **Pull request (PR):** proposal to review and merge changes into a target branch.

## 3. Basic workflow
```bash
git status
git add .
git commit -m "Add application feature"
git push origin main
```

A safer habit is to inspect changes before committing:
```bash
git status
git diff
git diff --staged
```

To work on a feature branch:
```bash
git switch -c feature/add-health-check
# edit files
git add .
git commit -m "Add health check"
git push -u origin feature/add-health-check
```

Then open a pull request on GitHub.

## 4. Why this matters for CI/CD
GitHub Actions can respond to repository events, such as:
- A push to a branch.
- A pull request being opened or updated.
- A tag being pushed.
- A scheduled event.
- A manually requested workflow run.

A team can require CI checks to pass before a pull request is merged. This connects version control to automated quality control.

## 5. Branches and protection
A common workflow is:
1. Keep `main` as the stable branch.
2. Create a short-lived branch for a change.
3. Push the branch.
4. Open a pull request.
5. Let automated checks run.
6. Review and merge only after required checks pass.

Branch protection can require pull requests, reviews, and passing status checks. Exact settings depend on repository permissions and GitHub plan/features.

## 6. Useful commands
```bash
git clone <repository-url>
git remote -v
git branch
git switch main
git pull
git log --oneline --graph --decorate
git status
```

Never commit passwords, access tokens, private keys, or production credentials.

## Review questions
1. What is the difference between Git and GitHub?
2. What does `git add` do?
3. What is the purpose of a branch?
4. What is a pull request?
5. How can a passing CI check protect the `main` branch?

## Practical checkpoint
Create a small change on a feature branch, commit it, push it to GitHub, and open a pull request. Observe which repository event occurs and where a future CI check would appear.

## Completion record
- [ ] I can explain the local Git workflow.
- [ ] I can create and push a branch.
- [ ] I understand how pushes and pull requests can trigger workflows.

## References
Add the Git/GitHub documentation or tutorial used during study.
