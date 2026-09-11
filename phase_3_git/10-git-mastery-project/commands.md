# Session 10 — Command Reference

Every command used across the whole capstone workflow, in the order you'll typically run them.

## 1. Confirm a clean starting point

```bash
cd ~/Desktop/devops-journey
git status              # must show "nothing to commit, working tree clean"
```

## 2. Scaffold the project folder

```bash
mkdir -p phase_3_git/10-git-mastery-project/screenshots
```

## 3. First commit — project structure

```bash
git add phase_3_git/10-git-mastery-project/
git commit -m "add git mastery project structure"
```

## 4. Create and switch to the feature branch

```bash
git switch -c feature/git-mastery
git branch               # confirm the * is on feature/git-mastery
```

## 5. Second commit — deployment docs

```bash
git add phase_3_git/10-git-mastery-project/deployment.md
git diff --staged        # sanity-check what's about to be committed
git commit -m "add deployment workflow documentation"
```

## 6. Push the feature branch and open a PR

```bash
git push -u origin feature/git-mastery
```
→ open the Pull Request on GitHub (`feature/git-mastery` → `main`)

## 7. Add the CI check

```bash
mkdir -p .github/workflows
# create .github/workflows/devops-journey-check.yml
git add .github/workflows/devops-journey-check.yml
git commit -m "add github actions repository check"
git push
```

## 8. Merge, then sync local main

```bash
git switch main
git pull
git log --oneline --graph --all
```

## 9. Tag the release

```bash
git tag -a v1.0.0 -m "Git mastery project v1.0.0"
git tag                     # confirm it's listed
git show v1.0.0             # inspect the tag
git push origin v1.0.0      # push the tag to GitHub
```

## 10. Add lessons learned (after everything above is merged)

```bash
git switch -c docs/lessons-learned
# edit phase_3_git/10-git-mastery-project/lessons-learned.md
git add phase_3_git/10-git-mastery-project/lessons-learned.md
git commit -m "add lessons learned for git mastery project"
git push -u origin docs/lessons-learned
# open PR, merge, sync main
```
