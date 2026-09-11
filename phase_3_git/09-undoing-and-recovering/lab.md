# Session 9 — Practical Lab: Break Something, Then Recover It

⚠️ Do this entire lab in a throwaway folder — **not** inside `devops-journey`. We want to practice `reset --hard` somewhere safe.

---

## Part 1 — Set up the lab repo

```bash
cd ~/Desktop
rm -rf git-recovery-lab
mkdir git-recovery-lab
cd git-recovery-lab
git init
git branch -M main
```

## Part 2 — Build up four commits

```bash
echo "Project starts here" > app.txt
git add app.txt
git commit -m "initial project"

echo "Login feature" >> app.txt
git add app.txt
git commit -m "add login feature"

echo "Database feature" >> app.txt
git add app.txt
git commit -m "add database feature"

echo "Monitoring feature" >> app.txt
git add app.txt
git commit -m "add monitoring feature"
```

Confirm:
```bash
git log --oneline
```
You should see 4 commits, newest first.

## Part 3 — Make the mistake, on purpose

```bash
git reset --hard HEAD~1
```

Check the damage:
```bash
git log --oneline     # "add monitoring feature" is gone
cat app.txt            # the monitoring line is gone too
```

## Part 4 — Find the lost commit

```bash
git reflog
```

Locate the line like:
```
def5678 HEAD@{1}: commit: add monitoring feature
```
Note that hash.

## Part 5 — Recover it

```bash
git reset --hard <the-hash-you-found>
```

Confirm:
```bash
git log --oneline     # monitoring commit is back
cat app.txt            # monitoring line is back
```

---

## Part 6 — Document it in your real repo

Back in `devops-journey`, create the notes for this session (not the lab repo itself — just your write-up of what you did):

```bash
cd ~/Desktop/devops-journey/phase_3_git
mkdir -p 09-undoing-and-recovering/screenshots
```

Write up in your own words:
- what you broke and how
- the exact reflog output that showed you the lost commit
- the command you used to recover it

Take a screenshot of the `git reflog` output showing the recovered hash, and one of `git log --oneline` before vs after recovery — save both to `09-undoing-and-recovering/screenshots/`.

Commit this documentation through the normal branch → PR → merge flow from Session 8.

---

## Self-check (answer these in your notes before moving on)

1. You need to undo a commit that's already been pushed and pulled by teammates, without rewriting shared history — `reset` or `revert`?
2. In one sentence: what does `git reset --hard HEAD~1` actually do to your commit, staging area, and working directory?
3. You just ran a reset and a commit seems to have vanished — do you check `git log` or `git reflog` first, and why?
4. In one sentence each: what's the core difference between `reset` and `revert`?

## Completion checklist

- [ ] Recovery lab completed in an isolated folder (not `devops-journey`)
- [ ] Successfully broke and recovered a commit using `git reflog`
- [ ] Self-check questions answered in your own notes
- [ ] `09-undoing-and-recovering/` write-up committed via a feature branch + PR
- [ ] Screenshots of reflog output and before/after log saved
