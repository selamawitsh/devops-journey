# Session 6: Git Hooks

## Goal

By the end of this session you should be able to:

1. Explain precisely what a Git hook is and when it runs
2. Locate and inspect the hooks already sitting in any repository
3. Write a working `pre-commit` hook from scratch, understanding every line
4. Explain the difference between `pre-commit` and `pre-push`
5. Explain why Git hooks are local by default, and how teams work around that
6. Explain the actual difference between Git hooks and CI/CD, and why both exist

## 1. What Is a Git Hook, Precisely

A Git hook is a script that Git automatically runs when a specific Git event happens — no manual step, no reminder, no relying on a developer to remember. You wire the check into the tool itself.

```
git commit
    |
pre-commit hook runs automatically
    |
  checks run
    |
  +---------+---------+
  |                   |
 pass                fail
  |                   |
commit continues   commit is blocked
```

Recall Session 2's tour of `.git/` — `HEAD`, `objects/`, `refs/`, `index`. There's a fifth entry that matters now: `hooks/`. It was sitting there the whole time; this session is about what actually goes in it.

## 2. Why This Matters in DevOps

DevOps as a discipline is largely about replacing "please remember to do X" with "the system enforces X automatically." Git hooks are one of the earliest, smallest examples of that idea — running right at the point where a developer is about to create a commit, before that change goes anywhere else.

Things a hook can automatically catch before they ever become part of your history:

- code formatting issues
- failing tests
- hardcoded passwords or API keys
- linter violations
- disallowed filenames
- commits aimed at a protected branch
- malformed configuration files

```
Developer
    |
 git commit
    |
 Git Hook
    |
 automated checks
    |
  +------+------+
  |             |
 pass          fail
  |             |
commit        commit
succeeds      blocked
```

## 3. Where Hooks Live

Every Git repository has a `hooks/` folder inside `.git/`, created automatically by `git init`:

```bash
ls -la .git/hooks/
```

You'll see a set of files like `pre-commit.sample`, `pre-push.sample`, `commit-msg.sample`, `pre-rebase.sample`. The `.sample` suffix is deliberate — Git ships example scripts for reference, but will not execute a file unless it's named *exactly* the hook's real name (no `.sample`) and is marked executable. This is why nothing happens by default even though these files already exist — you have to explicitly create or activate one.

## 4. The Hook Catalog

| Hook | Runs when | Where it runs | Example use |
|---|---|---|---|
| `pre-commit` | Before a commit is created | Developer's machine | Run linter, check formatting, scan for secrets |
| `commit-msg` | After the commit message is entered | Developer's machine | Enforce a commit message format |
| `pre-push` | Before pushing to a remote | Developer's machine | Run the full test suite |
| `pre-rebase` | Before a rebase begins | Developer's machine | Block rebasing certain branches |
| `post-commit` | Right after a commit is created | Developer's machine | Trigger a local notification |
| `post-merge` | After a merge completes | Developer's machine | Reinstall dependencies if a lockfile changed |
| `pre-receive` | On the remote server, before accepting a push | Server (e.g. GitHub's infrastructure) | Server-side policy enforcement |
| `update` | On the remote server, before updating a specific ref | Server | Control which branches can be updated |

Worth noticing the split: everything down to `post-merge` runs on **your own machine** — these are called client-side hooks. `pre-receive` and `update` run on the **server** receiving the push — server-side hooks, which you don't control on a platform like GitHub (GitHub's own server-side checks, like branch protection rules, are effectively doing this job for you). Our lab today is entirely client-side, focused on `pre-commit`.

## 5. Deep Dive: pre-commit

```
git add
   |
git commit
   |
pre-commit hook fires
   |
checks run
   |
pass -> commit is created
fail -> commit never happens
```

`pre-commit` is the natural place to catch problems, because it runs at the earliest possible moment — before the commit object even exists, meaning a blocked commit leaves absolutely nothing behind in your history to clean up later.

## 6. Building a pre-commit Hook, Line by Line

```bash
nano .git/hooks/pre-commit
```

```bash
#!/bin/bash

echo "Running pre-commit check..."

if grep -R "password=" . --exclude-dir=.git; then
    echo "Possible password found. Commit blocked."
    exit 1
fi

echo "Pre-commit check passed."
exit 0
```

Breaking down every piece:

**`#!/bin/bash`** — the shebang line. It tells the operating system which interpreter should execute this file when it's run directly, rather than you having to type `bash pre-commit` yourself. Without it, Git wouldn't know how to run the script.

**`echo "Running pre-commit check..."`** — just prints that text to the terminal, purely so you can see the hook actually fired.

**`grep -R "password=" . --exclude-dir=.git`** — the actual check. `grep` searches text; `-R` means recursive (search every file in every subfolder, not just the current directory); `"password="` is the pattern being searched for; `.` means "start searching from the current directory"; `--exclude-dir=.git` skips Git's own internal files, since searching those would be pointless noise. If this pattern is found anywhere, `grep` exits successfully (meaning "yes, I found something"), which is what makes the `if` condition true.

**`exit 1`** — this is the entire mechanism that actually blocks the commit. Git watches the hook script's exit code specifically.

**`exit 0`** at the bottom — reached only if `grep` found nothing, meaning the check passed.

### Exit Codes, Precisely

```
exit 0  -->  "everything is fine"   -->  Git lets the operation continue
exit 1  -->  "something is wrong"   -->  Git stops the operation
```

This 0-means-success, non-zero-means-failure convention isn't unique to Git hooks — it's a general Unix/Linux scripting convention, the same one behind `$?` after any command you've run in your Linux fundamentals work. Git hooks are simply one more consumer of that same convention.

### Making It Executable

```bash
chmod +x .git/hooks/pre-commit
```

Recall permission bits from your Linux fundamentals work: `chmod +x` adds execute permission. Check it:

```bash
ls -l .git/hooks/pre-commit
```

Expect something like `-rwxr-xr-x` — read `rwx` (owner: read, write, execute), `r-x` (group: read, execute), `r-x` (others: read, execute). Without that `x`, Git would find the file but be unable to actually run it as a program.

## 7. Testing It

**A clean commit — the hook passes silently through:**

```bash
echo "Application is running" > app.txt
git add app.txt
git commit -m "add application status"
```

```
Running pre-commit check...
Pre-commit check passed.
[main abc1234] add application status
```

**A commit containing a password — the hook stops it:**

```bash
echo "password=secret123" > bad-config.txt
git add bad-config.txt
git commit -m "add configuration"
```

```
Running pre-commit check...
./bad-config.txt:password=secret123
Possible password found. Commit blocked.
```

No commit gets created. Conceptually:

```
git commit
    |
pre-commit
    |
finds "password="
    |
exit 1
    |
commit blocked
```

## 8. What Happens After a Blocked Commit

Nothing is lost. The file is still exactly where it was — staged, in the staging area — because the commit itself was never created; only the attempt was rejected.

```bash
git status
```

You'll see `bad-config.txt` still listed under "Changes to be committed." Fix the actual problem (e.g. remove the password, or delete the file entirely), then try committing again. The hook re-runs from scratch every time.

## 9. Git Hooks Are Local by Default

Important limitation: a hook you create at `.git/hooks/pre-commit` is **not** version-controlled, because `.git/` itself is never part of what gets committed — it's Git's own internal data, not your project's tracked content. If you push your work to GitHub right now, your teammate cloning the repo gets none of this — no hook, no protection.

```
You:                          Teammate (after cloning):
.git/hooks/pre-commit    -->  .git/hooks/  (default samples only,
(your custom script)          your script never arrived)
```

This is a real, common surprise for people encountering hooks for the first time — the check feels like part of the project, but by default it isn't shared with the project at all.

## 10. Sharing Hooks Across a Team

The fix: don't rely on the default `.git/hooks/` location for anything you want shared. Instead, keep hook scripts inside the actual project folder (which *is* tracked and committed), then point Git at that folder:

```bash
git config core.hooksPath .githooks
```

```
project/
├── .githooks/
│   ├── pre-commit
│   └── pre-push
├── src/
└── README.md
```

Now the hook files live in your committed history like any other file, and every teammate who clones the repo and runs that one `git config` command gets identical checks. We won't build this today — worth knowing it exists, and that it's the real-world answer to Section 9's problem.

## 11. pre-commit vs pre-push

```
pre-commit                        pre-push
    |                                 |
git commit                       git push
    |                                 |
runs locally, per-commit          runs locally, before leaving
    |                                 the machine entirely
fast checks: lint, format,            |
secret scanning                   slower checks: full test suite,
                                   integration checks
```

The practical reasoning: `pre-commit` runs constantly, every single commit, so it needs to be fast — a full test suite there would make every commit painfully slow. `pre-push` runs far less often (once per push, not once per commit), so it can afford to run something heavier.

## 12. Git Hooks vs CI/CD

Easy to conflate these — they're not the same layer.

```
Git Hook                          CI/CD
    |                                |
runs on YOUR machine             runs on a CI/CD SERVER
    |                                |
Developer -> git commit          Developer -> git push -> GitHub
           -> hook checks                  -> CI/CD triggers
                                            -> tests, build,
                                               security scan, deploy
```

### Why Hooks Alone Aren't Enough

A developer can simply skip a local hook:

```bash
git commit --no-verify
```

This flag deliberately bypasses client-side hooks. Since it's entirely optional and entirely under the developer's own control, a team cannot treat local hooks as an actual security or quality guarantee — only as an early, convenient warning. CI/CD, running on infrastructure the developer doesn't control, is what provides the real, unavoidable check.

```
Developer
   |
local Git hook (skippable)
   |
GitHub
   |
CI/CD pipeline (not skippable)
   |
tests, security scan, deploy
```

## 13. A Realistic DevOps Scenario

Imagine a file accidentally contains:

```
AWS_ACCESS_KEY_ID=ABC123
AWS_SECRET_ACCESS_KEY=XYZ456
```

A `pre-commit` hook checking for patterns like `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `password=`, or `api_key=` could catch this before it's ever committed — let alone pushed publicly. This meaningfully reduces (not eliminates) the chance of credentials ending up in your Git history, which matters because once a secret is committed, it's effectively in that repository's history forever unless you go through active, disruptive history-rewriting to remove it.

Worth being honest about the limits here: in real production environments, teams generally use dedicated, purpose-built secret-scanning tools rather than a hand-written `grep` pattern — a simple `grep` will miss plenty of secret formats and produce false negatives. Today's hook is teaching the underlying automation mechanism, not shipping something production-grade.

## The Big Picture

```
                    git add
                       |
                 Staging Area
                       |
                   git commit
                       |
               pre-commit hook
                       |
              +--------+--------+
              |                 |
            PASS              FAIL
              |                 |
           Commit            Stop
              |
           git push
              |
            GitHub
              |
            CI/CD
              |
   tests / build / security / deploy
```

Git hooks are the earliest layer in this chain — fast, local, skippable. CI/CD is the layer that actually enforces things for real.

## Active Recall

1. What is a Git hook, in one precise sentence?
2. Why doesn't Git run `pre-commit.sample` automatically?
3. What does `grep -R "password=" . --exclude-dir=.git` actually search, and why exclude `.git`?
4. What do `exit 0` and `exit 1` each tell Git to do?
5. If a commit gets blocked by a hook, what happens to the file you tried to commit?
6. Why don't hooks placed in `.git/hooks/` get shared with teammates automatically, and what's the real fix?
7. What's the practical difference in when `pre-commit` and `pre-push` run, and why does that affect how heavy each check can be?
8. Why can't a team rely on local Git hooks alone for security enforcement?
