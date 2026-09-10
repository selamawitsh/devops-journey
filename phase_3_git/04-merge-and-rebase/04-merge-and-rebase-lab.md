# Session 4: Hands-On Lab - Merge vs Rebase

Two separate labs, using throwaway practice repos outside `devops-journey` so nothing here touches your real project history. Do Lab A completely before starting Lab B — they use different folders on purpose.

---

## Lab A: Merge

Goal: cause a real three-way merge, on purpose, and watch the graph before and after.

### Step 1: Create the practice repo

```bash
cd ~/Desktop
mkdir git-merge-rebase-lab
cd git-merge-rebase-lab
git init
git branch -M main
```

### Step 2: First commit on main

```bash
echo "Project starts here." > app.txt
git add app.txt
git commit -m "chore: initialize project"
```

State so far:
```
A  <- main
```

### Step 3: Branch off and commit on the branch

```bash
git switch -c feature/login
echo "Login feature" >> app.txt
git add app.txt
git commit -m "feat: add login feature"
```

State so far:
```
A --- D
      ^
   feature/login (main is still at A)
```

### Step 4: Move main independently — this is what causes divergence

```bash
git switch main
echo "Main branch update" >> app.txt
git add app.txt
git commit -m "docs: update main project"
git log --oneline --graph --all
```

Expected graph — two separate lines, this is divergence made real:
```
* 1111111 docs: update main project
| * 2222222 feat: add login feature
|/
* 3333333 chore: initialize project
```

### Step 5: Merge

```bash
git merge feature/login
git log --oneline --graph --all
```

Expected — a merge commit joining both lines:
```
*   4444444 Merge branch 'feature/login'
|\
| * 2222222 feat: add login feature
* | 1111111 docs: update main project
|/
* 3333333 chore: initialize project
```

Check the file itself:

```bash
cat app.txt
```

Expected: all three lines present — both edits survived, combined into one file. That's the merge commit's entire job, made visible.

---

## Lab B: Rebase

Goal: cause the same kind of divergence, but resolve it with rebase instead, and see the difference in the resulting graph.

### Step 1: Create a separate, clean practice repo

Do not reuse Lab A's folder — it's already merged.

```bash
cd ~/Desktop
mkdir git-rebase-lab
cd git-rebase-lab
git init
git branch -M main
```

### Step 2: First commit

```bash
echo "Project starts here." > app.txt
git add app.txt
git commit -m "chore: initialize project"
```

### Step 3: Branch and commit

```bash
git switch -c feature/api
echo "API feature" >> app.txt
git add app.txt
git commit -m "feat: add API feature"
```

### Step 4: Move main independently

```bash
git switch main
echo "Main update" >> app.txt
git add app.txt
git commit -m "docs: update project"
git log --oneline --graph --all
```

Expected — same shape as Lab A at this point, two diverged lines:
```
* main commit
| * feature commit
|/
* initial commit
```

### Step 5: Rebase the feature branch onto main

```bash
git switch feature/api
git rebase main
git log --oneline --graph --all
```

Expected — a single straight line, no merge commit:
```
* 5555555 feat: add API feature
* 3333333 docs: update project
* 89abcde chore: initialize project
```

Note that the feature commit's hash is different from what it was before the rebase — that's the "new commit" Section 3 of the README described, not the original one moved.

### Step 6: Compare the two labs side by side

```bash
cd ~/Desktop/git-merge-rebase-lab
git log --oneline --graph --all
cd ~/Desktop/git-rebase-lab
git log --oneline --graph --all
```

Same starting problem in both — one shows the branch structure (merge), the other shows a clean line with rewritten commits (rebase).

---

## Challenge

Before moving to Session 5, do this without instructions, still inside `git-rebase-lab`:

1. Make two more small commits on `feature/api` — anything, even one-line changes to `app.txt`.
2. Run `git rebase -i HEAD~2` and squash the second commit into the first.
3. Run `git log --oneline` and confirm you now have one combined commit instead of two.
4. Write, in your own words, what would have gone wrong if `feature/api` had already been pushed and someone else had pulled it before you ran this rebase.

Question 4 has no command to run — it's checking whether the shared-history rule from the README actually landed, not just the mechanics.
