# Session 10 — Practical Lab: Build the Git Mastery Project

This is the capstone for Phase 3. You'll build a small, real feature end-to-end using every workflow from Sessions 1–9.

---

## Part 1 — Confirm a clean starting point

```bash
cd ~/Desktop/devops-journey
git status
```
Must show `nothing to commit, working tree clean` before continuing. If it doesn't, don't discard anything — sort that out first.

## Part 2 — Scaffold the project folder

```bash
mkdir -p phase_3_git/10-git-mastery-project/screenshots
```

## Part 3 — Create the project README

```bash
cat > phase_3_git/10-git-mastery-project/README.md << 'EOF'
# Git Mastery Project

This project combines the Git and GitHub skills I learned during Phase 3 of my DevOps journey.

## Goals

- Practice GitHub Flow
- Work with feature branches
- Create meaningful commits
- Practice branch synchronization
- Use Pull Requests
- Use GitHub Actions
- Create Git tags and releases
- Practice Git recovery with reflog
- Understand safe Git workflows

## Workflow

```text
main
  ↓
feature branch
  ↓
changes
  ↓
commit
  ↓
push
  ↓
Pull Request
  ↓
GitHub Actions
  ↓
review
  ↓
merge
  ↓
tag/release
```

## Skills Demonstrated

- Git fundamentals
- Git internals
- Branching
- Merge
- Rebase
- Conflict resolution
- Git hooks
- Tags
- GitHub Flow
- GitHub Actions
- Reset
- Revert
- Reflog

## Lessons Learned

See `lessons-learned.md`.

## Future Improvements

- Add automated tests
- Add more CI checks
- Add deployment automation
- Add security scanning
EOF
```

## Part 4 — Create CONTRIBUTING.md

```bash
cat > phase_3_git/10-git-mastery-project/CONTRIBUTING.md << 'EOF'
# Contributing

## Branch Naming

Use descriptive branch names.

Examples:
- feature/add-monitoring
- feature/update-documentation
- fix/github-action

## Commit Messages

Use short and descriptive commit messages.

Examples:
- add deployment documentation
- fix workflow configuration
- update networking documentation

## Workflow

1. Update the local main branch.
2. Create a feature branch.
3. Make a small change.
4. Commit the change.
5. Push the branch.
6. Open a Pull Request.
7. Wait for automated checks.
8. Review the changes.
9. Merge into main.

## Before Pushing

Run:
```bash
git status
git diff
```
Make sure no secrets or unnecessary files are included.

## Pull Requests

Every Pull Request should explain:
- What changed?
- Why was it changed?
- How was it tested?
EOF
```

## Part 5 — First meaningful commit

```bash
git status
git add phase_3_git/10-git-mastery-project/
git commit -m "add git mastery project structure"
```

## Part 6 — Create your feature branch

```bash
git switch -c feature/git-mastery
git branch
```

## Part 7 — Add the deployment documentation

```bash
cat > phase_3_git/10-git-mastery-project/deployment.md << 'EOF'
# Deployment Workflow

A basic DevOps deployment workflow can be represented as:

```text
Developer
    ↓
Git feature branch
    ↓
Pull Request
    ↓
CI checks
    ↓
main branch
    ↓
Build
    ↓
Deploy
```

## Development Workflow

Developers should:
1. Create a feature branch.
2. Make changes.
3. Commit the changes.
4. Push the branch to GitHub.
5. Open a Pull Request.
6. Wait for automated checks.
7. Merge after review.

## CI/CD

Continuous Integration checks whether new changes are safe to merge.

Continuous Delivery or Deployment can automate the process of delivering the application after changes are merged.
EOF
```

## Part 8 — Commit it

```bash
git add phase_3_git/10-git-mastery-project/deployment.md
git diff --staged
git commit -m "add deployment workflow documentation"
```

## Part 9 — Push and open the PR

```bash
git push -u origin feature/git-mastery
```

On GitHub, open the PR (`feature/git-mastery` → `main`). Title and description:

```
Title: Add Git mastery project

## What changed?
Added the Git mastery project documentation.

## Why?
This project combines the Git and GitHub skills learned during Phase 3.

## Testing
- Checked Git status
- Checked staged changes
- Verified documentation files

## Checklist
- [x] Documentation added
- [x] Changes committed
- [x] No secrets included
- [x] Git workflow followed
```

## Part 10 — Add the CI check

```bash
mkdir -p .github/workflows
```

```bash
cat > .github/workflows/devops-journey-check.yml << 'EOF'
name: DevOps Journey Check

on:
  pull_request:
    branches:
      - main

jobs:
  check:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Check repository
        run: |
          echo "Checking DevOps journey repository..."
          echo "GitHub Actions is working!"
EOF
```

```bash
git add .github/workflows/devops-journey-check.yml
git commit -m "add github actions repository check"
git push
```

Confirm the check appears and passes on the PR (`✓ DevOps Journey Check`).

## Part 11 — Merge and sync

Merge the PR on GitHub once the check is green, then:

```bash
git switch main
git pull
git log --oneline --graph --all
```

## Part 12 — Tag the release

```bash
git tag -a v1.0.0 -m "Git mastery project v1.0.0"
git tag
git show v1.0.0
git push origin v1.0.0
```

## Part 13 — Write lessons learned (in your own words)

Don't copy a template verbatim — write what you actually experienced this phase. Use this as a starting skeleton only:

```bash
cat > phase_3_git/10-git-mastery-project/lessons-learned.md << 'EOF'
# Lessons Learned

## Git Fundamentals

## Git Internals

## Branching

## Merge vs Rebase

## Conflict Resolution

## Git Hooks

## Tags

## GitHub Workflow

## Recovery

## DevOps Connection
EOF
```

Fill each section with what you personally ran into — a conflict you actually resolved, a reset you actually recovered from, etc. Commit this through its own small branch → PR → merge cycle, same as everything else in this project.

---

## Final active recall — answer from memory before closing out Phase 3

1. What is the difference between `git reset` and `git revert`?
2. What command can help recover a commit after a bad reset?
3. Why do we normally use feature branches instead of directly changing `main`?
4. What is a Pull Request?
5. What does GitHub Actions do?
6. Why are tags like `v1.0.0` useful?
7. Why is `feature branch → Pull Request → CI → review → main` a useful workflow on a real team?

---

## Completion checklist

- [ ] `10-git-mastery-project/` created with README.md, CONTRIBUTING.md, deployment.md, lessons-learned.md
- [ ] Work done on `feature/git-mastery`, not directly on main
- [ ] Two separate, meaningful commits
- [ ] PR opened with a full description
- [ ] GitHub Actions check passing before merge
- [ ] Merged into main, tagged `v1.0.0`
- [ ] Lessons learned written in your own words and merged
- [ ] Final active-recall questions answered from memory
- [ ] Screenshots of the PR, the passing check, and the tag saved to `10-git-mastery-project/screenshots/`
