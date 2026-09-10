# Session 1: Command Reference - Git Fundamentals

Quick reference for every command introduced this session. Try to explain each one in your own words before reading the description.

| Command | What it does |
|---|---|
| `git init` | Creates a new `.git/` directory, turning the current folder into a Git repository. |
| `git status` | Shows the current state of the working directory and staging area: untracked, modified, and staged files, plus branch ahead/behind info. Run this before anything else. |
| `git add <file>` | Stages a specific file - marks it to be included in the next commit. |
| `git add .` | Stages all changed and new files in the current directory and below. |
| `git commit -m "message"` | Saves staged changes as a new snapshot in the local repository, with a message describing the change. |
| `git log` | Shows full commit history: author, date, message, commit hash. |
| `git log --oneline` | Condensed one-line-per-commit history - easier to scan. |
| `git diff` | Shows line-by-line differences between the working directory and the last staged/committed version. |
| `git remote -v` | Lists the remote repositories configured for this repo (fetch and push URLs). |
| `git push` | Sends local commits to the remote repository (commonly `origin`). |
| `git fetch` | Downloads new commits/branches from the remote without merging them into your current branch. |
| `git pull` | Fetches remote changes and merges (or rebases) them into your current branch in one step. |

## Notes

- `git add` and `git commit` are local-only operations. Nothing leaves your machine until `git push`.
- `git status` and `git diff` are read-only inspection commands - safe to run at any time, they never change repository state.
- When debugging "why isn't my change showing up on GitHub," the fix is almost always: check `git status` first, then confirm whether the change was committed, then confirm whether it was pushed. Most of this confusion traces back to skipping one of those three steps.
