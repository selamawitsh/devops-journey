# Session 8 — Practical Lab

Goal: produce a real, reviewable Pull Request and a working GitHub Actions check on your `devops-journey` repo — the artifact a hiring manager can actually click through.

---

## Part 1 — Branch from main

```bash
cd ~/Desktop/devops-journey
git switch main
git pull
git switch -c feature/github-workflow
```

## Part 2 — Make a small, real change

Add your Session 8 notes into `phase_3_git/08-github-workflow/` (the three files you already have: README.md, commands.md, lab.md).

## Part 3 — Commit

```bash
git add .
git commit -m "docs: add GitHub workflow notes"
```

## Part 4 — Push the branch

```bash
git push -u origin feature/github-workflow
```

## Part 5 — Open a Pull Request

On GitHub: `feature/github-workflow` → **Compare & pull request** → target `main`.

Write a short description of what you added — this is good practice for the PR template habit.

## Part 6 — Review your own PR

Before merging, actually look at:
- the **Files changed** tab — does the diff match what you intended?
- the commit list — is the message clear?
- whether any checks are attached yet (none, until Part 8)

## Part 7 — Merge, then sync local main

```bash
git switch main
git pull
```

Confirm the new files exist on your local `main` now.

---

## Part 8 — Add a GitHub Actions check

This part goes through the **same branch → PR → merge cycle**, but adds the `.github/workflows/test.yml` file from `commands.md`, at the **repo root** (`devops-journey/.github/workflows/test.yml`).

```bash
git switch main
git pull
git switch -c feature/actions-check
mkdir -p .github/workflows
# create .github/workflows/test.yml (see commands.md)
git add .
git commit -m "ci: add basic GitHub Actions check"
git push -u origin feature/actions-check
```

Open a second PR. This time, before merging:

- [ ] Confirm the **DevOps Journey Check** appears under the PR's checks
- [ ] Confirm it runs and passes (green ✅)
- [ ] Only then merge

## Part 9 — Sync main again

```bash
git switch main
git pull
```

---

## Completion checklist

- [ ] `feature/github-workflow` branch created, pushed, PR'd, reviewed, merged
- [ ] `feature/actions-check` branch created, pushed, PR'd
- [ ] Actions check visible and passing on the second PR before merge
- [ ] Both branches merged, local `main` synced
- [ ] Screenshots captured: the open PR page, and the Actions check passing — saved to `08-github-workflow/screenshots/`

## Stretch goal (optional, do later once comfortable)

Turn on branch protection for `main` (Settings → Branches → Add rule): require a PR before merging, and require the `DevOps Journey Check` status to pass. This makes everything above *enforced*, not just practiced.
