# Session 9 — Command Reference

## Reset (moves the branch pointer)

```bash
git reset --soft HEAD~1     # undo commit, keep changes staged
git reset --mixed HEAD~1    # undo commit, keep changes unstaged (default)
git reset HEAD~1            # same as --mixed
git reset --hard HEAD~1     # undo commit, discard changes entirely ⚠️
```

Resetting to a specific commit instead of a relative offset:

```bash
git reset --hard <commit-hash>
```

## Revert (adds a new undo commit — safe for shared/pushed branches)

```bash
git revert HEAD              # undo the most recent commit
git revert <commit-hash>     # undo a specific commit
git revert --no-edit HEAD    # same, but skip the commit-message editor
```

## Reflog (recovery — shows where HEAD has recently pointed)

```bash
git reflog                   # full reflog for current branch
git reflog show main         # reflog for a specific branch
```

## Recovery pattern

```bash
git reflog                        # find the "lost" commit's hash
git reset --hard <old-hash>       # point the branch back at it
```

## Inspection — run before anything destructive

```bash
git status
git log --oneline
git log --oneline --graph --all
```

## Setting up an isolated recovery lab (never practice `--hard`/`force` in your real repo)

```bash
cd ~/Desktop
mkdir git-recovery-lab
cd git-recovery-lab
git init
git branch -M main
```
