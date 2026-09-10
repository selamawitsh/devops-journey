# Session 1: Git Fundamentals

## The Problem Git Actually Solves

Before Git, teams did this:

```
app-final.py
app-final-2.py
app-final-working.py
app-final-working-real.py
```

That is not exaggeration for effect — that is a real, common failure mode. Nobody knows which file is current. Nothing rolls back cleanly. Two people cannot touch the same file safely.

Git's answer: stop copying files, start recording snapshots.

```
Commit 1 -> Commit 2 -> Commit 3 -> Commit 4
```

Each commit is a full, addressable point in your project's history. That is the entire idea. Everything else in this session is just "how do I control what goes into a snapshot, and where does the snapshot live."

## Git vs GitHub — Get This Exactly Right

This distinction gets tested in interviews and misused constantly by beginners.

| | Git | GitHub |
|---|---|---|
| What it is | The version control tool itself | A platform that hosts Git repositories |
| Where it runs | Locally, on your machine, no internet required | On a remote server |
| Can you use one without the other | Yes — `git init`, `git add`, `git commit` all work fully offline | No — GitHub has nothing to host without Git |
| Alternatives | None — Git is the standard | GitLab, Bitbucket, Azure DevOps |

The one-line version: **Git is the tool. GitHub is a place other people also use the tool.** A company could ban GitHub tomorrow and switch to GitLab, and every `git` command you know would still work identically.

## The Three-Stage Model

This is the actual content of Session 1. Everything else is commentary on this diagram.

```
Working Directory  --git add-->  Staging Area  --git commit-->  Local Repository  --git push-->  GitHub
```

Walk through it as a diagnostic tool, not just a diagram — because in practice, this is exactly how you will debug "where did my change go":

**Working Directory** — the files as they sit on disk right now. The moment you save a change, Git notices, even though it is not tracking that change yet.

```bash
git status
```
```
Untracked files:
    notes.txt
```

**Staging Area** — a holding zone for exactly what you intend to put in the next commit.

```bash
git add notes.txt
git status
```
```
Changes to be committed:
    new file: notes.txt
```

**Local Repository** — permanent history, but only on your machine.

```bash
git commit -m "add notes"
git log --oneline
```
```
a82f31c add notes
```

Notice the pattern: at every stage, `git status` tells you exactly where a file currently sits. If you are ever confused about "did I save this, stage this, or commit this," the answer is always `git status` — not guessing.

## Why the Staging Area Exists (Not Just "Because Git Has One")

Say you touched three files, but one of them is half-finished debug code you do not want in this commit:

```bash
git add feature.py
git add feature_test.py
git commit -m "feat: add validation logic"
```

`debug_notes.txt` never gets committed, because you never staged it. This is the actual mechanism engineers rely on to keep commits clean and reviewable — not a formality.

**Common real mistake:** running `git add .` out of habit without checking `git status` first, and accidentally staging a `.env` file with credentials in it. This is a genuinely common way secrets leak into public repos. The staging step exists precisely so you have a checkpoint to catch that before it becomes a commit.

## Commit Is Not Push — The Most Common Beginner Bug

Here is the scenario you will hit in your first week at any job: you commit, then tell a teammate "I pushed the fix," and they say "I don't see it on GitHub."

What happened: `git commit` only writes to your **local** repository. Nothing has left your machine.

```
Working Directory -> git add -> Staging Area -> git commit -> Local Repository -> git push -> GitHub
```

`git push` is the only command in this chain that talks to the network. Until you run it, your commits are real, they exist, `git log` proves it — but they are invisible to everyone else. The debugging habit: if someone says your change isn't showing up remotely, the first question is always "did you push," not "did you commit."

## origin, fetch, and pull

```bash
git remote -v
```
```
origin  https://github.com/selamawitsh/devops-journey.git (fetch)
origin  https://github.com/selamawitsh/devops-journey.git (push)
```

`origin` is just a label — the conventional nickname for "the remote I normally sync with." Nothing magic about the word itself.

**fetch** — download what changed on the remote, without touching your current branch. It's a pure "check what's new" operation.

**pull** — fetch, then merge those changes into your current branch automatically.

```
git pull  =  git fetch  +  merge the changes in
```

If you only ever use `git pull`, you are fine for now. `git fetch` becomes more useful once you want to look at incoming changes before deciding how to integrate them — that comes later.

## The Habit That Actually Matters

`git status` before anything, always. `git diff` before staging, to see exactly what you're about to commit. `git log --oneline` to see your actual history. These three are read-only — they never change your repository state, so there is no reason not to run them constantly. Professional engineers run `git status` almost reflexively before every other Git command, specifically to avoid acting on a wrong assumption about repo state.

## Mental Model

```
   EDIT FILES
       |
       v
  Working Directory
       |
   git add
       v
   Staging Area
       |
   git commit
       v
  Local Repository
       |
   git push
       v
      GitHub
```

## Active Recall

1. What is the difference between Git and GitHub?
2. Fill in the blank: `??? -> git add -> ??? -> git commit -> ???`
3. What does `git add` actually do, and what does it *not* do?
4. Your teammate says they can't see your commit on GitHub. What's the first thing you check, and why?
5. What is the difference between `git fetch` and `git pull`?
6. What does `origin` refer to?
7. You just edited a file and want to see the exact change before staging it. Which command?
