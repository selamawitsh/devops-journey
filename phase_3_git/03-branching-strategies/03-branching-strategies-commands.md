# Session 3: Command Reference - Branching Strategies

| Command | What it does |
|---|---|
| `git branch` | Lists local branches; `*` marks the current one. |
| `git branch <name>` | Creates a new branch pointing at the current commit. Does not switch to it. |
| `git switch <name>` | Switches your working directory to the given branch. |
| `git switch -c <name>` | Creates a new branch and switches to it in one step. |
| `git checkout <name>` | Older command that also switches branches. Still works and still common in the wild, but historically overloaded with file-restoring duties too — `switch` is the clearer modern equivalent for this specific job. |
| `git merge <name>` | Merges the named branch's changes into your current branch. |
| `git branch -d <name>` | Deletes a branch, but only if it has already been merged — Git refuses otherwise as a safeguard. |
| `git branch -D <name>` | Force-deletes a branch even if it has not been merged. Use deliberately, not by habit. |
| `git log --oneline --all --decorate` | Shows commits across every branch, with branch/tag names labeled next to each commit. |
| `git log --oneline --decorate --graph --all` | Same as above, plus an ASCII graph showing how branches diverged and merged. |

## Notes

- `git branch <name>` and `git switch <name>` are two separate actions on purpose — you can create a branch for someone else, or prepare several branches, without hopping into each one.
- `-d` vs `-D` is a genuinely common real-world mistake source. If Git refuses your `-d`, that is Git telling you the branch has unmerged work — read that as a warning, not an obstacle to force past by default.
- `--graph` becomes genuinely useful (not just decorative) once you have more than two branches in play, which happens fast on a real team.
