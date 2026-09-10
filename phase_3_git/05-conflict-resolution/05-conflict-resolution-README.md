# Session 5: Conflict Resolution

## Goal

By the end of this session you should be able to:

1. Explain exactly why Git raises a conflict, in terms of what it can and can't decide automatically
2. Read conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) without hesitation
3. Resolve a conflict by picking one side, combining both, or writing something new
4. Know how to safely back out of a merge entirely if needed
5. Explain why some branching strategies produce more conflicts than others

## You Already Had One

Before any lab — you already lived through exactly this, minutes ago. When you ran `git pull --rebase origin main`, Git tried to apply your local commit on top of `origin/main`, found that both sides had changed the same lines of `04-merge-and-rebase-lab.md` in different ways, and stopped with:

```
CONFLICT (add/add): Merge conflict in phase_3_git/04-merge-and-rebase/04-merge-and-rebase-lab.md
```

That was a real conflict, resolved for real. This session is about understanding exactly what was happening in that moment, so next time you don't need me to walk you through it line by line.

## 1. What Is a Merge Conflict, Precisely

Say a file starts as:

```
Hello
```

On `main`, someone changes it to:

```
Hello from main
```

On `feature/login`, someone else changes the *same line* to:

```
Hello from login
```

When these two branches come back together, Git compares each side against their shared ancestor. Here's the part most explanations skip: **if only one side had changed a given line, Git merges it automatically, silently, no conflict at all.** A conflict only happens when *both* sides changed the *same* line differently — because at that point Git has two equally valid-looking answers and no way to know which one you actually want.

```
        common ancestor: "Hello"
       /                        \
"Hello from main"          "Hello from login"
       \                        /
            Git: both sides changed this line differently
                         |
                    CONFLICT
```

This is exactly what happened to your lab file — both the old step-by-step version and the new narrative version existed on the same lines, and Git had no basis to prefer one over the other.

## 2. Conflicts Are Not Errors

Worth saying plainly: a conflict does not mean Git is broken, your repository is broken, or you need to start over. It means **Git found two changes it cannot safely combine automatically, and it's handing the decision to you** rather than guessing and possibly destroying someone's work. This is a safety feature, not a failure — the alternative would be Git silently picking one side and quietly losing the other, which would be far worse.

Every developer working on a team hits this regularly. It is routine, not exceptional.

## 3. Anatomy of Conflict Markers

When a conflict happens, Git doesn't ask you to guess — it writes **both versions directly into the file**, wrapped in markers, so you can see exactly what's disputed:

```
<<<<<<< HEAD
Database: MySQL
=======
Database: PostgreSQL
>>>>>>> feature/database
```

Reading this precisely:

- `<<<<<<< HEAD` opens the block, and everything down to the `=======` line is **your current branch's version** — recall from Session 2 that `HEAD` points at whatever branch you're currently on.
- `=======` is just the divider between the two versions — it means nothing on its own.
- Everything between `=======` and `>>>>>>> feature/database` is **the other branch's version** — the one you're merging in.
- `>>>>>>> feature/database` closes the block and names the source of that second version.

This is precisely what your actual conflict looked like too — one block per disputed section, `HEAD`'s version above the `=======`, the incoming commit's version below it.

## 4. The Decision Is Yours

Git cannot know whether you want MySQL, PostgreSQL, both, or something else entirely — that's a judgment call about your project, not something derivable from the text alone. Your job is to edit the file so it contains exactly what should actually be there, and remove every marker line (`<<<<<<<`, `=======`, `>>>>>>>`) completely. You have three real options, not just one:

- **Keep one side entirely** (what you did in your actual conflict — kept the new narrative version)
- **Keep both**, combined in some sensible order
- **Write something new** that supersedes both versions

## 5. The Full Workflow

```
git merge (or git pull --rebase, or git rebase)
      |
   CONFLICT
      |
  git status          <- shows which files are conflicted
      |
 open the conflicted file
      |
 decide the final content
      |
 remove <<<<<<< / ======= / >>>>>>>
      |
  git add <file>       <- marks this file as resolved
      |
  git commit            (or git rebase --continue, if you were rebasing)
      |
    DONE
```

Note the small but important difference: if the conflict came from `git merge`, you finish with `git commit`. If it came from `git rebase` (or `git pull --rebase`, which is a rebase underneath), you finish with `git rebase --continue` instead — that's exactly what you did earlier.

## 6. Bailing Out Safely

If a conflict ever looks messier than you want to deal with right now, you are not stuck. You can cancel the whole operation and return to exactly where you were before it started:

```bash
git merge --abort
```

or, if you were rebasing:

```bash
git rebase --abort
```

Both fully undo the in-progress operation — no half-resolved files left behind, no partial state. Knowing this exists is genuinely useful: it means you can attempt a conflict resolution, decide you got it wrong, and cleanly start over instead of trying to manually reverse your own edits.

## 7. Real-World Notes

- The actual editing — deleting markers, choosing content — is normally done in an IDE (VS Code, IntelliJ) which highlights conflict blocks and often offers one-click "accept current / accept incoming / accept both" buttons, or directly in GitHub's own web conflict editor for simple cases. `nano` works too, as you've now done, but is rarely how professional teams actually resolve these day to day.
- How often you hit conflicts is directly connected to Session 3's branching strategies. Long-lived branches (Git Flow's `develop`, or a feature branch left open for weeks) drift further from `main` the longer they exist, so the same lines are more likely to have been touched by someone else by the time you merge. Short-lived branches merged frequently — the GitHub Flow and trunk-based approaches this course is using — keep divergence small, which is a direct, practical reason those strategies are popular beyond just "cleaner history."

## Active Recall

1. Precisely, under what condition does Git raise a conflict instead of merging automatically?
2. In a conflict block, which version does the top half (above `=======`) represent, and how do you know?
3. What are the three real options you have when resolving a conflict?
4. What command finishes a conflict that came from `git merge`? What finishes one from `git rebase`?
5. What does `git merge --abort` actually undo?
6. Why do long-lived branches tend to produce more conflicts than short-lived ones?
7. Is a merge conflict a sign that something is broken? Why or why not?
