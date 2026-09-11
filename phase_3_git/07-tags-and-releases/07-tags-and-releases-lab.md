# Session 7: Hands-On Lab - Git Tags & Releases

Goal: create both kinds of tags, inspect what's actually different about them under the hood, and practice the full tag lifecycle including pushing and deleting.

## Setup

```bash
cd ~/Desktop
rm -rf git-tags-lab
mkdir git-tags-lab
cd git-tags-lab
git init
git branch -M main
```

## Step 1: A first commit worth tagging

```bash
echo "v1 of the app" > app.txt
git add app.txt
git commit -m "chore: initial stable version"
```

## Step 2: Tag it as a real release

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

## Step 3: Prove to yourself what an annotated tag actually is

```bash
git show v1.0.0
git cat-file -t v1.0.0
```

Expect `git cat-file -t` to print `tag` — a real object, exactly like the README's Session 2 callback described. Compare this to what a lightweight tag looks like:

```bash
git tag v1.0.0-lightweight
git cat-file -t v1.0.0-lightweight
```

This one should resolve straight through to `commit` — there's no separate tag object at all, unlike the annotated one above.

## Step 4: Keep developing, then tag the next version

```bash
echo "added a new feature" >> app.txt
git add app.txt
git commit -m "feat: add new capability"
git tag -a v1.1.0 -m "Add new capability"
```

## Step 5: List and compare your tags

```bash
git tag -n
git log --oneline --decorate
```

Confirm `v1.0.0` still points at the first commit and `v1.1.0` at the second — even though both commits exist in the same linear history.

## Step 6: Pushing tags (if you have a remote)

This lab repo has no remote, so `git push` commands here are for reference only — they'll error without one. Once you're comfortable with the mechanics above, do the real version in Section 7 below, where an actual `origin` already exists.

```bash
git push origin v1.0.0
git push origin --tags
```

## Step 7: Real-World Step — Tag Your Actual devops-journey Progress

This is genuinely useful, not just practice. Your `devops-journey` repo represents real, ongoing progress — tagging a milestone there is exactly what tags are for.

```bash
cd ~/Desktop/devops-journey
git log --oneline -1
git tag -a v0.1.0-git-phase -m "Completed Git phase sessions 1 through 6"
git push origin v0.1.0-git-phase
```

Then check your GitHub repository's Tags page and confirm it shows up there. This is the same mechanism as `v1.0.0` in a production app — just marking a real point in your own learning history instead.

## Challenge

Before Session 8, practice the deletion path deliberately, so the commands aren't unfamiliar the one time you'd actually need them under pressure:

1. In `git-tags-lab`, create a deliberately wrong tag: `git tag -a vTEST -m "wrong tag, practicing deletion"`.
2. Delete it locally: `git tag -d vTEST`. Confirm with `git tag` that it's gone.
3. Explain in your own words why deleting a tag that a CI/CD pipeline had already used to trigger a production deploy would be a bigger problem than deleting one nobody's used yet.

Question 3 has no command — it's checking whether the "treat pushed tags like shared branches" caution from the README actually landed.
