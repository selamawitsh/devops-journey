# Session 7: Git Tags & Releases

## Goal

By the end of this session you should be able to:

1. Explain what a tag is and how it's fundamentally different from a branch
2. Create both lightweight and annotated tags, and know when to use each
3. Explain what an annotated tag actually is under the hood (this closes a loop from Session 2)
4. Explain Semantic Versioning (`MAJOR.MINOR.PATCH`)
5. Explain how tags connect to GitHub Releases and to CI/CD pipelines

## 1. What Is a Tag

A tag is a human-readable name attached permanently to one specific commit.

```
A ---- B ---- C ---- D
              ^
            v1.0.0
```

Instead of remembering `a83f91c...`, you can say `v1.0.0`. That's the entire concept — everything else in this session is refinement on top of that one idea.

## 2. Why Tags Exist

In a real project, "deploy whatever's currently on main" is a dangerous thing to say — main keeps moving, so that sentence means something different every day. "Deploy `v1.0.0`" means the exact same thing forever. Tags exist to let you freeze a name to a moment in history that both you and your team can refer to with total precision, indefinitely.

## 3. Tag vs Branch — the Critical Distinction

This is worth being airtight on, because it's the single most tested distinction in this session.

```
Before:
main
 |
A ---- B ---- C ---- D
                     ^
                   v1.0.0

After one more commit on main:
main
 |
A ---- B ---- C ---- D ---- E
                     ^
                   v1.0.0
```

`main` moved from `D` to `E`, because that's what branches do — they track the latest commit as work continues. `v1.0.0` did not move. It still points at `D`, forever, unless someone deliberately deletes or recreates it.

```
Branch = a pointer that moves as you commit
Tag    = a pointer that stays put
```

## 4. Lightweight vs Annotated Tags — and What's Actually Happening Underneath

Two kinds exist, and the difference isn't just cosmetic.

**Lightweight tag** — just a reference, mechanically identical to how a branch works internally (recall Session 2: a small file containing a commit hash), except it's never meant to move.

```bash
git tag v1.0.0
```

**Annotated tag** — creates an actual new object in `.git/objects`, with its own hash, containing the tag name, message, tagger, and date, which *then* points at the commit:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

This is worth connecting directly to Session 2's object model, because Session 2 specifically said `tag` would come back here as the fourth object type. Prove it to yourself:

```bash
git rev-parse v1.0.0
git cat-file -t v1.0.0
```

For an annotated tag, `git cat-file -t` prints `tag` — a real object type, distinct from `commit`. For a lightweight tag, there's no such object; it's purely a ref, same as `refs/heads/main` was in Session 3. This is the actual technical reason annotated tags are recommended for releases — they carry real metadata (who tagged it, when, why) as a permanent, hashed part of your repository's history, not just a label.

## 5. Creating Tags

Lightweight, on your current commit:

```bash
git tag v1.0.0
```

Annotated, with a message (the standard choice for real releases):

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

## 6. Inspecting Tags

```bash
git show v1.0.0
```

Prints the tag's own metadata (for annotated tags) plus the commit it points to — everything you'd need to know exactly what `v1.0.0` represents.

```bash
git tag
git tag -n
```

`git tag` lists tag names. `git tag -n` lists tags with their messages alongside, which is far more useful once you have more than a couple.

## 7. Tagging an Older Commit

Tags don't have to point at your current position. Find the hash first:

```bash
git log --oneline
```

Then tag it directly:

```bash
git tag -a v1.0.0 <commit-hash> -m "First stable release"
```

Useful for the realistic case where you realize *after the fact* that an earlier commit was actually the real release point.

## 8. Pushing Tags — the Common Gotcha

This trips people up constantly: **plain `git push` does not push your tags.** Tags are a separate thing from commits and branches as far as `push` is concerned.

Push one specific tag:

```bash
git push origin v1.0.0
```

Push every local tag at once:

```bash
git push origin --tags
```

## 9. GitHub Releases

GitHub Releases are a feature built *on top of* tags — not a separate concept. The relationship:

```
Git commit -> Git tag -> GitHub Release
```

A tag is the technical marker; a GitHub Release wraps that tag in a page with release notes, a description, and optionally downloadable assets (compiled binaries, packaged files, etc.) — the human-facing version of the same underlying pointer.

| | Git tag | GitHub Release |
|---|---|---|
| What it is | A Git feature — a named pointer to a commit | A GitHub feature, built around a tag |
| Audience | Technical — Git itself, scripts, CI/CD | Human-facing — a readable page for users |

## 10. Semantic Versioning

The `vMAJOR.MINOR.PATCH` convention behind version numbers like `v1.4.2`:

```
1 . 4 . 2
|   |   |
|   |   +-- PATCH: bug fixes only, nothing new, nothing broken
|   +------ MINOR: new functionality added, old functionality still works
+---------- MAJOR: breaking changes — old usage may no longer work
```

Concretely:

```
v1.0.0 -> v1.0.1   bug fix (PATCH)
v1.0.1 -> v1.1.0   new feature, backward-compatible (MINOR)
v1.1.0 -> v2.0.0   breaking change (MAJOR)
```

## 11. A Realistic DevOps Scenario

```
A -- B -- C -- D -- E -- F -- G -- H
          ^         ^    ^    ^
        v1.0.0    v1.1.0 v1.1.1 v2.0.0
```

Say production is running `v1.4.0` and a new deploy of `v1.5.0` breaks something. Because both versions are tagged to exact commits, rolling back isn't guesswork — it's:

```
Production running v1.5.0 (broken)
        |
   roll back to
        |
Production running v1.4.0 (known good)
```

Without tags, "known good" would mean scrolling through commit messages trying to guess which hash was actually running in production at the time. With tags, it's an exact, named answer.

## 12. Tags and CI/CD

This is where tags plug directly into DevOps automation. A CI/CD pipeline can be configured to trigger specifically on a tag push, separately from ordinary commits:

```
push to main         -> run tests only
push a tag (v1.x.x)  -> build production image -> deploy to production
```

```
Developer
   |
git tag v1.2.0
   |
git push origin v1.2.0
   |
GitHub
   |
CI/CD pipeline triggers
   |
build -> test -> deploy
```

This pattern — ordinary commits just get tested, but a tag push triggers an actual production deployment — is extremely common in real pipelines, and is the reason tags matter for DevOps specifically, not just for bookkeeping.

## 13. Deleting Tags

```bash
git tag -d v1.0.0
```

Deletes it locally only. If it was already pushed:

```bash
git push origin --delete v1.0.0
```

Be careful here — deleting a tag other people (or a CI/CD pipeline) already rely on can cause real confusion, similar in spirit to the "don't rebase shared history" rule from Session 4.

## The Big Picture

```
                    Git History

A --- B --- C --- D --- E --- F
            ^             ^
          v1.0.0        v1.1.0

main keeps moving: A -> B -> C -> D -> E -> F
v1.0.0 stays fixed at C, forever, regardless of what main does next.
```

## Active Recall

1. What is a Git tag, in one precise sentence?
2. What's the core difference in behavior between a branch and a tag as new commits happen?
3. What's the actual, underlying difference between a lightweight tag and an annotated tag — not just "one has a message," but what object exists in `.git/objects` for each?
4. Why does plain `git push` not push your tags, and what command actually does?
5. What's the relationship between a Git tag and a GitHub Release?
6. In `v2.3.1`, which number is MAJOR, which is MINOR, which is PATCH — and what does incrementing each one signal?
7. Why are tags specifically useful for a production rollback scenario?
8. Give one realistic example of a CI/CD pipeline behaving differently for a tag push versus an ordinary commit push.
