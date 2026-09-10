# Session 5: Hands-On Lab - Conflict Resolution

Goal: cause a real conflict on purpose, in a throwaway repo, and resolve it deliberately and calmly — the same thing that just happened to you for real, but this time you're driving instead of reacting.

## Setup

```bash
cd ~/Desktop
rm -rf git-conflict-lab
mkdir git-conflict-lab
cd git-conflict-lab
git init
git branch -M main
```

## Step 1: A starting file both branches will edit

```bash
echo "Application configuration" > config.txt
git add config.txt
git commit -m "initial application configuration"
```

This commit is the shared ancestor — the common starting point both branches will diverge from, same role `B` played in every diagram in the README.

## Step 2: Change it on a feature branch

```bash
git switch -c feature/database
echo "Database: PostgreSQL" >> config.txt
git add config.txt
git commit -m "add PostgreSQL configuration"
```

## Step 3: Change the same area on main — this is what will cause the conflict

```bash
git switch main
echo "Database: MySQL" >> config.txt
git add config.txt
git commit -m "add MySQL configuration"
```

Both branches now have a "Database:" line, but with different content, on the same relative line of the file. That's deliberately set up to collide.

## Step 4: Trigger the conflict

```bash
git merge feature/database
```

Expect exactly this shape of message — not an error, just Git telling you it needs a decision:

```
Auto-merging config.txt
CONFLICT (content): Merge conflict in config.txt
Automatic merge failed; fix conflicts and then commit the result.
```

## Step 5: Read the conflict before touching anything

```bash
cat config.txt
```

You should see:

```
Application configuration
<<<<<<< HEAD
Database: MySQL
=======
Database: PostgreSQL
>>>>>>> feature/database
```

Confirm you can identify each part before moving on: the `HEAD` section is `main`'s version (MySQL), the section below `=======` is `feature/database`'s version (PostgreSQL). Also check:

```bash
git status
```

It should explicitly list `config.txt` as unmerged.

## Step 6: Resolve it — pick a side

For this run, decide the project uses PostgreSQL. Edit the file so it reads:

```bash
cat > config.txt << 'EOF'
Application configuration
Database: PostgreSQL
EOF
```

No markers left, no MySQL line — a clean, decided file.

## Step 7: Mark it resolved and finish

```bash
git add config.txt
git status
```

Expect: `All conflicts fixed but you are still merging.` That's the normal in-between state, not an error.

```bash
git commit
```

Accept the default merge commit message. Then confirm:

```bash
git status
git log --oneline --graph --all
```

`git status` should report a clean working tree. The graph should show a merge commit joining both branches, exactly like the diagram in the README.

## Challenge

Two parts — do both before Session 6.

**Part 1 — Combine instead of picking a side.** Create a second conflict the same way (branch off, change the same line differently on both sides, merge). This time, instead of choosing MySQL or PostgreSQL, resolve it by writing a new line that keeps both, e.g. `Database: PostgreSQL (primary), MySQL (legacy)`. This is the "write something new" option from the README, not just "pick A or B."

**Part 2 — Practice backing out.** Set up a third conflict, get as far as seeing the conflict markers in the file, and then instead of resolving it, run:

```bash
git merge --abort
git status
```

Confirm the merge is fully cancelled and your working tree is clean again, as if you'd never run `git merge` at all. This is the safety net from Section 6 of the README, made real instead of theoretical.
