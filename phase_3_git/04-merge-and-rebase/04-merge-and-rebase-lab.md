# Session 4: Hands-On Lab - Merge vs Rebase

Two separate labs, using throwaway practice repos outside `devops-journey` so nothing here touches your real project history. Do Lab A completely before starting Lab B — they use different folders on purpose, so you can compare the two outcomes side by side afterward.

---

## Lab A: Merge

The point of this lab isn't the commands themselves — it's watching divergence happen on purpose, then watching Git resolve it by combining both sides into a new commit.

Start by creating a disposable repo, so you're free to experiment without any risk to real work:

```bash
cd ~/Desktop
mkdir git-merge-rebase-lab
cd git-merge-rebase-lab
git init
git branch -M main
```

Give it one starting commit — this is the shared ancestor both branches will later be compared against:

```bash
echo "Project starts here." > app.txt
git add app.txt
git commit -m "chore: initialize project"
```

Now branch off and make a change there. This represents "your work" — isolated, not yet part of `main`:

```bash
git switch -c feature/login
echo "Login feature" >> app.txt
git add app.txt
git commit -m "feat: add login feature"
```

Here's the important part: go back to `main` and change it too, independently. This is what actually causes divergence — without this step, merging later would just be a trivial fast-forward, and you wouldn't see a real merge commit at all:

```bash
git switch main
echo "Main branch update" >> app.txt
git add app.txt
git commit -m "docs: update main project"
```

Run `git log --oneline --graph --all` here before merging anything. You should see the history visibly split into two separate lines. Sit with that for a second — that split *is* divergence, made real instead of theoretical. Both branches share the same starting commit, but neither one contains the other's change.

Now merge:

```bash
git merge feature/login
```

Because both sides had actually changed, Git can't just fast-forward — it creates a new merge commit whose entire purpose is holding both changes at once. Run `git log --oneline --graph --all` again and notice the graph now shows the two lines rejoining at that new commit.

Confirm it for real, not just in the graph:

```bash
cat app.txt
```

Both the "Login feature" line and the "Main branch update" line should be present in the file. That's the concrete proof that the merge commit did its job — nothing was lost from either side.

---

## Lab B: Rebase

Same starting problem as Lab A — divergence — but this time you'll resolve it by rewriting your branch's commits instead of combining them.

Use a fresh folder, not Lab A's — that repo has already been merged, and mixing the two would muddy what you're trying to observe:

```bash
cd ~/Desktop
mkdir git-rebase-lab
cd git-rebase-lab
git init
git branch -M main
echo "Project starts here." > app.txt
git add app.txt
git commit -m "chore: initialize project"
```

Branch and commit, same as before:

```bash
git switch -c feature/api
echo "API feature" >> app.txt
git add app.txt
git commit -m "feat: add API feature"
```

Move `main` forward independently, same as before — this recreates the exact same kind of divergence you caused in Lab A:

```bash
git switch main
echo "Main update" >> app.txt
git add app.txt
git commit -m "docs: update project"
```

This time, instead of merging, go back to your feature branch and rebase it onto `main`:

```bash
git switch feature/api
git rebase main
```

Run `git log --oneline --graph --all`. You should see a single straight line this time — no merge commit, no visible branching at all. That's not because nothing happened; it's because Git replayed your feature commit on top of the new `main`, giving it a new hash in the process. If you compare the hash shown now to what it was before the rebase, it will be different. That's the "rewrites history" idea from the README, made observable instead of abstract.

Once both labs are done, look at them side by side:

```bash
cd ~/Desktop/git-merge-rebase-lab
git log --oneline --graph --all
cd ~/Desktop/git-rebase-lab
git log --oneline --graph --all
```

Same starting problem, two different resolutions: one preserved the branch structure with a merge commit, the other erased it in favor of a clean line built from brand-new commits.

---

## Challenge

Still inside `git-rebase-lab`, work through this without step-by-step instructions:

1. Make two more small commits on `feature/api` — anything, even trivial one-line edits.
2. Use `git rebase -i HEAD~2` to squash the second commit into the first, so they become one.
3. Confirm with `git log --oneline` that you now have one combined commit instead of two.
4. In your own words, explain what would have gone wrong here if `feature/api` had already been pushed and a teammate had pulled it before you ran this rebase.

Question 4 doesn't have a command to run. It's there to check whether the shared-history rule from the README actually landed as understanding, not just as something you can operate around mechanically.
