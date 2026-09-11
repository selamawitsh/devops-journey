# Session 6: Hands-On Lab - Git Hooks

Goal: write a real `pre-commit` hook from scratch, watch it pass a clean commit and block a bad one, then confirm nothing gets lost when a commit is blocked.

## Setup

Use a throwaway repo so you're free to break things:

```bash
cd ~/Desktop
rm -rf git-hooks-lab
mkdir git-hooks-lab
cd git-hooks-lab
git init
git branch -M main
```

## Step 1: Look at what's already there

```bash
ls -la .git/hooks/
```

You should see a set of `.sample` files. None of them run — that's expected, and exactly why the next step is necessary.

## Step 2: Write the hook

```bash
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "Running pre-commit check..."

if grep -R "password=" . --exclude-dir=.git; then
    echo "Possible password found. Commit blocked."
    exit 1
fi

echo "Pre-commit check passed."
exit 0
EOF
```

## Step 3: Make it executable

```bash
chmod +x .git/hooks/pre-commit
ls -l .git/hooks/pre-commit
```

Confirm you see the `x` flags in the permission string before moving on — without this step, the hook file exists but Git can't execute it.

## Step 4: Test a clean commit

```bash
echo "Application is running" > app.txt
git add app.txt
git commit -m "add application status"
```

Expect to see the hook's own output (`Running pre-commit check...`, `Pre-commit check passed.`) printed right before Git's normal commit confirmation. The check ran — it just found nothing wrong.

## Step 5: Test a blocked commit

```bash
echo "password=secret123" > bad-config.txt
git add bad-config.txt
git commit -m "add configuration"
```

Expect the hook to print the matching line it found, then block the commit entirely — no `[main ...]` confirmation line this time, because no commit was created.

## Step 6: Confirm nothing was lost

```bash
git status
```

`bad-config.txt` should still be listed under staged changes. Fix the actual problem:

```bash
rm bad-config.txt
git status
```

The problematic file is gone and the hook's job is done — if you commit again now, it'll pass.

## Challenge

Extend the hook to match the real-world scenario from the README (AWS credentials, not just `password=`), and prove it catches them.

1. Edit `.git/hooks/pre-commit` so the `grep` pattern also matches `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, in addition to `password=`. (Hint: `grep -E` supports multiple patterns separated by `|`.)
2. Create a file containing a fake AWS key, e.g. `AWS_ACCESS_KEY_ID=ABC123`, and confirm the updated hook blocks it.
3. Confirm a genuinely clean file still commits successfully — you're checking you haven't accidentally made the hook block everything.
4. In your own words: if a teammate cloned this repo right now, would they get your updated hook? Why or why not — and what command from the README would actually fix that?

Question 4 has no command to run for the fix itself — it's checking whether Section 9 and 10 of the README actually landed.
