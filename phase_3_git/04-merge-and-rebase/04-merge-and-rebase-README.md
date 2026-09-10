# Session 4: Merge vs Rebase

## Goal

By the end of this session you should be able to explain, without notes:

1. Why branches diverge in the first place
2. What a fast-forward merge is, and how it's different from a real merge commit
3. What `git rebase` actually does to your commits
4. Why rebase is described as "rewriting history"
5. When rebase is safe, and when it genuinely isn't
6. What interactive rebase (`squash`, `reword`, `drop`) is for

(The hands-on practice for all of this lives in `lab.md`. This file is the concepts only.)

## 1. The Core Problem: Two Versions of the Same Thing

Before any Git syntax, here's the whole problem in plain terms.

Imagine you and a coworker both copy the same document to your own laptops so you can edit it separately. You add a pricing paragraph. Meanwhile, your coworker — working from their own copy — fixes a typo in the intro. Now there are two versions that started identical and grew apart. Neither has what the other has.

In Git terms: `main` was the original document. Your branch is your own copy. Someone else changed `main` while you worked. Now your branch and `main` disagree — they've **diverged**.

```
        D  <- your branch (has the pricing paragraph)
       /
A --- B --- C  <- main (has the typo fix)
```

Everything in this session is about answering one question: **how do we turn these two versions back into one?** There are two different answers — merge and rebase — and they make fundamentally different tradeoffs.

## 2. Merge: Make One Combined Version

Merging means exactly what it sounds like: produce a final version that has both sets of changes. There are two different outcomes depending on the situation.

### Fast-Forward — Nothing to Actually Combine

If nobody touched `main` while you were working, then your branch already contains everything `main` has, plus your new work. There's no real conflict to resolve — Git just moves `main`'s pointer forward to where your branch already is.

```
Before:                          After (fast-forward):
A --- B --- C                    A --- B --- C --- D
            ^                                      ^
           main                              main, feature
             \
              D
              ^
           feature
```

No new commit is created. `main` simply catches up.

### Three-Way Merge — Both Sides Actually Changed

If `main` *did* move (your coworker's typo fix landed on it) while you worked, Git can't just fast-forward — the two histories genuinely disagree. Git creates a brand-new commit with **two parents**, one from each side, containing both changes combined:

```
        D  <- feature (pricing paragraph)
       /    \
A --- B --- C --- E     <- main moved on (typo fix)
                    \   /
                     M  <- new merge commit, has both changes
                     ^
                    main
```

This is called a **three-way merge** because Git looks at three points to figure out the combination: your branch's tip, `main`'s tip, and their shared ancestor (`B`).

## 3. Rebase: Pretend You Started Later

Rebase solves the same divergence problem with a completely different strategy. Going back to the document analogy: instead of creating one new combined document, rebase says **"pretend I started my edits after the typo fix was already made."**

Concretely: Git takes the changes you made on your branch, temporarily sets them aside, moves your branch's starting point to match the latest `main`, and then re-applies your changes on top.

```
Before:
        D  <- feature
       /
A --- B --- C  <- main

After rebase:
A --- B --- C --- D'
                  ^
               feature
```

Notice it's `D'`, not `D`. This is the critical detail: **rebase does not move your original commit — it creates a brand-new one** with the same changes but a different parent, which means a different hash. The old `D` still technically exists for a short while but nothing points to it anymore, so it becomes unreachable. This is exactly why we say **rebase rewrites history** — the commit you thought you had is gone, replaced by a lookalike with a new identity.

### Merge vs Rebase, Side by Side

```
MERGE result:              REBASE result:
A---B---C---E               A---B---C---D'
     \      \                (straight line, feature commit replayed)
      D------M
```

Merge preserves exactly what happened, branch structure included. Rebase throws away the branch structure and tells a cleaner, linear story — at the cost of the commits literally being different objects than the ones you originally made.

## 4. The Big Rule: Don't Rebase Shared History

This is the single most interview-tested rule in this session.

If you rebase a branch that other people have already pulled and built work on top of, you create `D'` while their work still references the old `D`. Now there are effectively two different versions of "the same" commit floating around, and reconciling that mess is exactly the kind of painful, confusing problem Git is supposed to prevent.

The practical rule:

- **Safe to rebase**: a local feature branch that only you are working on, before you've pushed it or opened a Pull Request.
- **Do not casually rebase**: `main`, `develop`, or any shared branch other people are actively pulling from.

Think of it as: rebase is a private editing tool for cleaning up your own work-in-progress before you show it to anyone. Once it's shared, treat the history as fixed.

## 5. Interactive Rebase

Beyond replaying commits onto a new base, rebase can also let you edit your own recent commit history directly, using `git rebase -i HEAD~N`, where `N` is how many recent commits you want to review. This opens an editable list of those commits, each one changeable:

| Instruction | Effect |
|---|---|
| `pick` | Keep the commit as-is |
| `reword` | Keep the changes, but let you rewrite the commit message |
| `squash` | Merge this commit's changes into the one above it, combining them into one commit |
| `drop` | Remove the commit entirely |

### A Realistic Example

Say your actual commit history for a deploy script looks like this:

```
commit 1: add deploy script
commit 2: fix typo
commit 3: fix another typo
commit 4: fix deploy script
```

That's a completely normal way work actually happens, but it's noisy history to leave behind. Marking commits 2-4 as `squash` before opening a Pull Request would collapse all four into:

```
commit: add deployment script
```

One clean commit representing the finished feature, instead of four commits documenting your debugging process. This is exactly why interactive rebase is a real, everyday tool — not just a curiosity — for anyone who wants their Pull Requests to read cleanly. Same rule as before applies: only do this before pushing/sharing the branch.

## 6. Merge vs Rebase — Summary Table

| | Merge | Rebase |
|---|---|---|
| Preserves original history | Yes | No — creates new commits |
| Creates a merge commit | Sometimes (not on fast-forward) | Never |
| Resulting history shape | Can show branching | Linear |
| Safe on shared/public branches | Yes | No |
| Best used for | Bringing a finished feature into main | Cleaning up your own branch before sharing it |

## Mental Model

```
MERGE:
branch A ----+
             +-- new merge commit (keeps both histories)
branch B ----+

REBASE:
branch B's commits
       |
   replayed
       |
on top of branch A's latest tip
       |
new commits, old ones abandoned
```

**Merge combines histories. Rebase replaces your commits with new ones that tell a cleaner story.**

## Active Recall

1. What does it mean for two branches to "diverge"?
2. What's the difference between a fast-forward merge and a three-way merge — what determines which one happens?
3. When `git rebase main` runs on your feature branch, what actually happens to your original commits?
4. Why do people say "rebase rewrites history" — what specifically gets rewritten?
5. What's the rule about rebasing `main` or any branch other people are pulling from, and why does breaking that rule cause real problems?
6. In `git rebase -i HEAD~3`, what does changing `pick` to `squash` do?
7. Give one realistic reason a developer would use interactive rebase before opening a Pull Request.
8. Complete this: Merge is best for ___, rebase is best for ___.
