# Session 8 — Command Reference

## Branches

```bash
git branch                          # list local branches
git branch -r                       # list remote branches
git branch -a                       # list all branches (local + remote)
git switch -c feature/my-feature    # create + switch to a new branch
git switch main                     # switch back to main
git branch -d feature/my-feature    # delete a local branch (after merge)
```

## Syncing with remote

```bash
git remote -v                            # check configured remotes
git pull                                 # update current branch from remote
git push -u origin feature/my-feature    # push a new branch, set upstream
git push                                 # subsequent pushes on that branch
```

## Full feature-branch → PR → merge cycle

```bash
git switch main
git pull
git switch -c feature/github-workflow

# ...make changes...

git add .
git commit -m "docs: add GitHub workflow notes"
git push -u origin feature/github-workflow

# → open PR on GitHub, review, wait for checks, merge

git switch main
git pull   # bring the merged changes back into local main
```

## Setting up GitHub Actions (repo root, not inside a phase folder)

```bash
cd ~/Desktop/devops-journey
mkdir -p .github/workflows
```

```bash
cat > .github/workflows/test.yml << 'EOF'
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

Push it through its own feature branch and PR, same cycle as above.

## CODEOWNERS and PR template (optional, repo root)

```bash
cat > .github/CODEOWNERS << 'EOF'
.github/workflows/  @your-github-username
EOF

cat > .github/pull_request_template.md << 'EOF'
## What changed?

## Why?

## Testing

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No secrets committed
EOF
```

## Inspecting a PR / Actions run from the CLI (if `gh` is installed)

```bash
gh pr create --fill                 # open a PR from the current branch
gh pr view --web                    # open the PR in a browser
gh pr checks                        # see status check results
gh run list                         # list recent Actions runs
gh run watch                        # watch a run live
```
