# Session 4: Command Reference - Merge vs Rebase

## Setup Commands

| Command | What it does |
|---|---|
| `git init` | Creates a new repository. Used here for throwaway practice repos so nothing touches your real `devops-journey` history. |
| `git branch -M main` | Renames the current branch to `main`, forcefully. Used right after `git init` because a brand-new repo has no commits yet, so there's technically no branch to rename until after your first commit on some systems — this just guarantees you land on `main` regardless of your Git version's default. |

## Merge Commands

### `git merge <branch>`

Brings the named branch's changes into your **current** branch. What actually happens depends on whether the branches diverged:

**If nothing changed on your current branch since the other one split off** — fast-forward, no new commit:

```
Before:                          After:
A---B---C                        A---B---C---D
        ^                                    ^
     current                          current, <branch>
          \
           D
           ^
        <branch>
```

**If both branches changed** — a new merge commit is created, with two parents:

```
Before:                                  After:
        D  <- <branch>                          D
       /                                       / \
A --- B --- C  <- current                A --- B---C---M  <- current
                                                        (M has two parents: D and C)
```

### `git log --oneline --graph --all`

Not a merge command itself, but the command you'll run after every merge to actually see what happened. `--all` shows every branch, `--graph` draws the ASCII lines connecting them, `--oneline` keeps each commit to one line so the graph stays readable.

Fast-forward output looks like a single flat line:
```
* 1234567 feat: add login feature
* 89abcde chore: initialize project
```

A real merge output shows the branches splitting and rejoining:
```
*   4444444 Merge branch 'feature/login'
|\
| * 2222222 feat: add login feature
* | 1111111 docs: update main project
|/
* 3333333 chore: initialize project
```

## Rebase Commands

### `git rebase <branch>`

Run from the branch you want to move. Takes your current branch's commits, sets them aside, moves your branch's starting point to match the tip of `<branch>`, then re-applies your commits on top — each one getting a new hash.

```
Before:
        D  <- feature (you run: git rebase main, while ON feature)
       /
A --- B --- C  <- main

After:
A --- B --- C --- D'
                  ^
               feature
```

Resulting `git log --oneline --graph --all` is a straight line, no merge commit:
```
* 5555555 feat: add API feature
* 3333333 docs: update project
* 89abcde chore: initialize project
```

### `git rebase -i HEAD~N`

Interactive rebase. `N` is how many recent commits back you want to look at. Opens an editable list of those commits, each prefixed `pick`, that you can rewrite before Git replays them.

| Instruction | Effect |
|---|---|
| `pick` | Keep this commit unchanged |
| `reword` | Keep the changes, edit the commit message |
| `squash` | Fold this commit's changes into the commit above it — becomes one commit |
| `drop` | Delete this commit entirely |

Example transformation:

```
Before (in the editor):              After Git replays it:
pick a1 add deploy script            one combined commit:
squash b2 fix typo                   "add deployment script"
squash c3 fix another typo
squash d4 fix deploy script
```

## Quick Reference Table

| Command | Creates new commit hashes | Safe on shared branches | Typical use |
|---|---|---|---|
| `git merge <branch>` | Only for the merge commit itself (existing commits untouched) | Yes | Bringing a finished feature into main |
| `git rebase <branch>` | Yes, for every replayed commit | No | Updating your own local branch to build on the latest main |
| `git rebase -i HEAD~N` | Yes, for every rewritten commit | No | Cleaning up your own commit history before sharing it |
