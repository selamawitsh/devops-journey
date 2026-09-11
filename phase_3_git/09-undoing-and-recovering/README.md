# Session 9 — Undoing & Recovering in Git

Detailed notes with diagrams. This session covers the three commands that get you out of "I think I just destroyed my work" moments: `git reset`, `git revert`, `git reflog`.

---

## 1. The problem

```
A ──► B ──► C ──► D
                   ▲
                  main
```

```
A = initial project
B = add login
C = add database
D = add monitoring   ← "I don't want this one"
```

Three different tools solve three different versions of this problem:

```
reset   →  move the branch pointer backward, as if D never happened
revert  →  add a NEW commit that undoes D, keeping D visible in history
reflog  →  recovery tool — shows where HEAD has recently pointed,
           even after a reset "throws a commit away"
```

---

## 2. `git reset` — move the branch pointer

```
Before:                          After `git reset --hard HEAD~1`:

A ──► B ──► C ──► D              A ──► B ──► C ──► D
                   ▲                          ▲
                  main                       main
```

`D` still physically exists in Git's object database for a while — it's just no longer reachable from `main`. This matters later (see reflog).

### The three flavors of reset

```
                    commit    staging area    working directory
                    removed?  (git add)        (your files)
─────────────────────────────────────────────────────────────────
--soft              yes       kept staged      kept
--mixed (default)   yes       unstaged         kept
--hard              yes       discarded        discarded ⚠️
```

- **`--soft`** — "undo the commit, keep everything staged and ready to re-commit."
- **`--mixed`** — "undo the commit, put my changes back as unstaged edits."
- **`--hard`** — "take me back to exactly that old commit." This is the dangerous one — anything not committed elsewhere is gone from your working directory.

```
git reset --soft HEAD~1
git reset --mixed HEAD~1   (same as: git reset HEAD~1)
git reset --hard HEAD~1
```

---

## 3. `git revert` — undo by adding a new commit

```
Before:                    After `git revert HEAD`:

A ──► B ──► C              A ──► B ──► C ──► D
            ▲                               ▲
           main                            main

                            D = "revert: undo C"
```

Nothing is deleted or rewritten. History stays linear and honest — anyone looking at the log can see both the mistake *and* the fix.

### Why this matters once work is pushed

```
GitHub main:  A ──► B ──► C     (already pushed — teammates have pulled this)
```

If you `reset --hard` and force-push here, you rewrite history everyone else already has — their local `main` and yours now disagree. `revert` avoids that entirely: it just adds a normal new commit.

---

## 4. Reset vs Revert — the rule

| | `git reset` | `git revert` |
|---|---|---|
| Moves the branch pointer backward | ✔ | ✘ |
| Creates a new "undo" commit | ✘ | ✔ |
| Rewrites history | ✔ (danger with `--hard` + shared branches) | ✘ (safe for shared branches) |

```
private / local-only work   →  reset is fine
already pushed / shared     →  revert is safer
```

---

## 5. `git reflog` — where HEAD has actually been

`git log` shows your project's *commit* history. `git reflog` shows everywhere **HEAD has pointed**, including commits that a reset just made unreachable from any branch.

```
git log      →  "show me the history of my project"
git reflog   →  "show me where Git recently went"
```

Example output:

```
abc1234 HEAD@{0}: reset: moving to HEAD~1
def5678 HEAD@{1}: commit: add monitoring feature
9ac0123 HEAD@{2}: commit: add database feature
```

Even though `main` no longer points at `def5678`, reflog remembers it existed — which means you can point a branch back at it.

---

## 6. The recovery pattern

```
   git reset --hard HEAD~1        ← the mistake
            │
            ▼
   "where did my commit go?!"
            │
            ▼
       git reflog                 ← find the old commit hash
            │
            ▼
   git reset --hard <old-hash>    ← point main back at it
            │
            ▼
       commit is back ✅
```

---

## 7. DevOps example: production deploy repo

```
v1 ──► v2 ──► v3          v3 pushed, then breaks production
```

**Risky move** — rewrites shared history:
```bash
git reset --hard HEAD~1
git push --force
```

**Safer move** — adds a new commit, history stays intact and visible to the team:
```bash
git revert HEAD
git push
```
```
v1 ──► v2 ──► v3 ──► v4
                       ▲
                 "revert: undo v3"
```

---

## 8. Habit to build before any dangerous operation

```bash
git status
git log --oneline --graph --all
```

Run these — and actually read the output — before:

```
git reset --hard
git rebase
git push --force
```

Understanding what's about to move, get discarded, or get rewritten is the whole skill here. The commands themselves are simple; the judgment about when to use which one is what this session is really teaching.
