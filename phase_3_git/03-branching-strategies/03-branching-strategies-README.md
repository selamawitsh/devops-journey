# Session 3: Branching Strategies

## Goal

By the end of this session you should be able to:

1. Explain what a branch actually is, down to the file level
2. Create, switch to, and delete branches
3. Merge one branch into another, and know the two different ways a merge can happen
4. Explain GitHub Flow, Git Flow, and Trunk-based development
5. Say which strategy fits `devops-journey`, and why

In real teams, almost nobody commits directly to `main`. This session is about why that rule exists, what actually happens on disk when you branch, and how the rule gets enforced day to day.

---

## 1. What a Branch Actually Is

From Session 2: a branch is a reference — a small text file containing one commit hash. Nothing clever, nothing magical. Let's not just say that — let's look at it.

### The commit-graph view

Before creating a branch:

```
A --- B --- C
            ^
           main
```

After creating a branch — both names point at the exact same commit, because nothing has changed yet:

```
A --- B --- C
            ^
        main, feature
```

After committing on `feature`:

```
A --- B --- C --- D
            ^     ^
           main  feature
```

`main` still points at `C`. `feature` moved on to `D`. Two labels, one shared history, now diverging.

### The file-level view — proving it yourself

This is the part most explanations skip, and it's worth two minutes because it turns "a branch is a pointer" from a phrase you memorized into something you've actually seen.

```bash
cd ~/Desktop/devops-journey
git branch feature/git-branching
cat .git/refs/heads/main
cat .git/refs/heads/feature/git-branching
```

Both commands print the **same 40-character commit hash**. That's it — that is the entire internal representation of "these two branches point at the same place."

Section 4 below has you switch to this branch and make a real commit on it. Once you've done that, come back and re-run both `cat` commands. `main`'s file will still hold the old hash; `feature/git-branching`'s file will hold the new one. That difference — two small files holding two different hashes — is the entire mechanism behind every branching diagram in this document.

---

## 2. Why Branches Exist

If you only had `main`, every experiment, half-finished feature, and untested idea would sit directly in the one branch other people — and eventually your CI/CD pipeline — rely on being stable.

```
main
  |
  +-- create feature branch
             |
             v
        experiment
             |
             v
          test it
             |
             v
           merge
```

### A concrete scenario

Say you're adding a new "farmer credit score" calculation to Agri-Yield. You're not sure the formula is right yet, and you want to try three different weightings before settling on one. If you did this directly on `main`:

- Anyone pulling the repo mid-experiment gets your half-finished, possibly-wrong formula.
- If your laptop crashes mid-change, `main` itself could be left broken.
- There's no clean point to say "this is the version we reviewed and approved."

With a branch, all of that experimentation is invisible to everyone else until you decide it's ready and merge it. This is precisely why company code review policies are built around branches and Pull Requests, not around people directly editing a shared branch.

---

## 3. Everyday Branch Commands

### Check where you are

```bash
cd ~/Desktop/devops-journey
git branch
```

```
* main
```

The `*` marks your current branch. `git status`'s first line tells you the same thing.

### Create a branch

```bash
git branch feature/git-branching
git branch
```

```
  feature/git-branching
* main
```

Internally: Git just created one new file, `.git/refs/heads/feature/git-branching`, containing the current commit's hash. That's the entire operation — which is also why it's instantaneous even in a repository with a million commits.

Important: **creating a branch does not move you to it.** The `*` is still next to `main`.

### Switch to it

```bash
git switch feature/git-branching
git branch
```

```
* feature/git-branching
  main
```

Internally: Git updates `HEAD` (recall Session 2 — `HEAD` is a pointer to your current branch) to point at `refs/heads/feature/git-branching` instead of `refs/heads/main`. It also rewrites your working directory files to match whatever that branch's commit's tree contains. If the two branches have different file states, this is the moment you'd see files change on disk.

```bash
cat .git/HEAD
```

Before switching this would print `ref: refs/heads/main`; after, `ref: refs/heads/feature/git-branching`.

### Why `switch` and Not the Older `checkout`

You'll still see `git checkout feature/git-branching` in older tutorials and at plenty of companies — it does the same thing here, and still works today. Here's the actual history: `checkout` used to do *two unrelated jobs* — switching branches, **and** restoring individual files to an old version (`git checkout -- file.txt`, covered properly in Session 9). One command silently behaving differently depending on its arguments caused real, repeated mistakes — people meaning to switch branches and accidentally discarding file changes instead. Git's maintainers split the two jobs into `switch` (branches) and `restore` (files) specifically to make intent unambiguous. This course uses `switch`; just recognize `checkout` on sight, since it's still everywhere in the wild.

### Create and switch in one step

```bash
git switch -c feature/test
```

`-c` = create. Equivalent to running `git branch feature/test` then `git switch feature/test`, but this is the version you'll actually type most often once the two-step version feels slow.

---

## 4. Mini Lab: Make a Real Change on a Branch

Confirm you're on `feature/git-branching`:

```bash
git branch
```

Create the folder and file:

```bash
mkdir -p phase_3_git/03-branching-strategies
cat > phase_3_git/03-branching-strategies/branching-notes.md << 'EOF'
# Git Branching

A branch allows developers to work on changes separately
without directly modifying the main branch.
EOF
```

Stage and commit as usual:

```bash
git status
git add phase_3_git/03-branching-strategies/branching-notes.md
git commit -m "docs: add Git branching notes"
```

See it on the branch:

```bash
git log --oneline --all --decorate
```

`--all` shows commits across every branch; `--decorate` labels which branch name points where — genuinely useful the moment you have two branches disagreeing about history, which is exactly your situation right now.

The state after this:

```
A --- B --- C --- D
            ^     ^
           main  feature/git-branching
```

Now go prove Section 1's claim with your own eyes:

```bash
cat .git/refs/heads/main
cat .git/refs/heads/feature/git-branching
```

Different hashes. `main` does not have commit `D` — your experiment is fully isolated until you decide otherwise.

---

## 5. Merging

Switch back and bring the change in:

```bash
git switch main
git branch
git merge feature/git-branching
```

### What actually happens during a merge — two different outcomes

This matters enough to show visually now, even though Session 4 goes much deeper.

**Case A — Fast-forward.** If `main` hasn't moved since you branched off it (nobody else committed to `main` in the meantime), Git doesn't need to combine anything. It just slides the `main` pointer forward to `D`:

```
Before:              After (fast-forward):
A---B---C                A---B---C---D
        ^                            ^
       main                         main
        \                    feature/git-branching
         D
         ^
  feature/git-branching
```

This is what will happen in your lab right now, since nothing else has touched `main`.

**Case B — Real merge commit.** If `main` *had* moved forward (say to `E`) while you were working on your branch, Git can't just slide the pointer — the histories actually diverged. It creates a brand-new commit with **two** parents, one from each branch:

```
A---B---C---E                (main moved on without you)
        \    \
         D    M   <- new merge commit, main now points here
         ^
  feature/git-branching
```

You'll deliberately produce Case B in Session 4 and see exactly how Git decides what the merged file content should be.

```bash
git log --oneline --decorate --graph --all
```

`--graph` draws these branch/merge relationships as ASCII art — genuinely part of your everyday toolkit once history has more than two branches in it.

---

## 6. Deleting a Merged Branch

```bash
git branch -d feature/git-branching
git branch
```

```
* main
```

### What actually gets deleted

Only the pointer — the small file `.git/refs/heads/feature/git-branching`. The commit `D` itself is untouched and still fully part of `main`'s history (you can see it in `git log` on `main` right now). Nothing about your work is lost; you've only removed a now-redundant label.

`-d` (lowercase) is deliberately a "safe delete" — Git checks whether the branch's work has been merged somewhere reachable, and refuses if not. This is a real, everyday safeguard: it's the difference between deleting a label for work that's safely preserved elsewhere, versus deleting your only pointer to work that would otherwise become unreachable and eventually get garbage-collected. Try deleting an unmerged branch in the lab challenge below and read exactly what Git tells you.

---

## 7. The Full Local Workflow

```
create branch
      |
     work
      |
    commit
      |
     test
      |
    merge into main
      |
  delete branch
```

Every branching strategy below is really just a variation on when and how this loop happens, and who reviews it before the merge step.

---

## 8. Branching Strategies — the DevOps Part

The individual commands above are identical everywhere. What differs between companies is the *policy* wrapped around them.

### GitHub Flow

```
main
 |
 +-- feature/login   ----PR----> main
 |
 +-- feature/payment ----PR----> main
 |
 +-- fix/navbar       ----PR----> main
```

```
create branch -> make changes -> push branch -> open Pull Request -> review -> merge into main
```

One long-lived branch (`main`), everything else short-lived and merged only through a reviewed Pull Request. This is dominant on modern software projects, especially anything with continuous deployment — every merge to `main` can trigger an automatic deploy, so the PR review is the actual safety gate.

### Git Flow

```
main -------------------------o-----------o------->  (production releases)
  \                            \           \
   +-- develop --o---o---o---o--+--o---o---o
        |    \        \
        |     feature/x feature/y
        |
        +-- release/1.2 -> merged into both main and develop
```

Plus `hotfix/...` branches that come off `main` directly for urgent production fixes, then get merged back into both `main` and `develop`. `develop` is where day-to-day integration happens; `main` represents released/production code, only ever updated via a release or a hotfix.

More structure, more ceremony. This fits products with scheduled, versioned releases (packaged desktop software, mobile apps with app-store review cycles) better than continuously-deployed web services — the extra branches exist specifically to manage the gap between "code is done" and "code is actually released," which barely exists for a service that deploys on every merge.

### Trunk-Based Development

```
             main
               |
       +-------+-------+-------+
       |       |       |       |
    change   change   change   change
   (hours,  (hours,  (hours,  (hours,
   not      not      not      not
   weeks)   weeks)   weeks)   weeks)
```

One long-lived branch, and everyone integrates small changes into it very frequently — branches, if they exist at all, live for hours, not weeks. There's no long-lived `develop` catching problems before they reach `main`, so this model leans entirely on strong automated testing and CI to catch issues immediately after each tiny merge, rather than during a big periodic integration.

### Comparison

| Strategy | Main idea | Complexity | Fits best when |
|---|---|---|---|
| GitHub Flow | Feature branch, then PR, then main | Low | Continuous deployment, small-to-medium teams |
| Git Flow | main + develop + feature/release/hotfix | High | Scheduled, versioned releases |
| Trunk-based | Small changes merged frequently, minimal branching | Low | Very strong CI/CD, high commit frequency |

### Recommendation for `devops-journey`

GitHub Flow. Your learning path is Git -> GitHub -> Pull Requests -> CI/CD, and GitHub Flow is the exact workflow those pieces are built around — GitHub Actions (later in your roadmap) is designed to trigger off Pull Requests and merges to `main` in this model. It also reflects what the large majority of companies hiring for DevOps and junior engineering roles actually run day to day. Git Flow shows up more in specific niches (versioned packaged software) than in typical web/cloud teams — worth knowing it exists and being able to explain it, but not what you should default to.

---

## Active Recall

1. What is a Git branch, at the file level — not just conceptually, but literally what and where?
2. What's the difference between `git branch feature/test` and `git switch feature/test`?
3. What does `git switch -c feature/test` do in one step?
4. Why create a feature branch instead of committing directly to `main`?
5. What is a fast-forward merge, and how is it different from a merge that creates a new merge commit?
6. After merging, why is it safe to delete the feature branch — what exactly gets removed, and what doesn't?
7. Which branching strategy are we using for `devops-journey`, and why does it fit better than Git Flow?
8. Complete the workflow: `Create feature branch -> Work -> Commit -> ??? -> Merge`
