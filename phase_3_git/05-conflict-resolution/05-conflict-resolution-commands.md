# Session 5: Command Reference - Conflict Resolution

| Command | Description |
|---|---|
| `git merge <branch>` | Attempts to combine `<branch>` into your current branch. If both sides changed the same lines, this is what triggers a conflict. |
| `git status` | During a conflict, lists which files are still unmerged (conflicted) versus already resolved. Run this constantly while resolving — it's how you know what's left. |
| `git diff` | During a conflict, shows the conflicted sections directly, same content you'd see by opening the file. |
| `git add <file>` | During a conflict, this does not just "stage a change" — it specifically tells Git "I've resolved this file, treat it as final." Required for every conflicted file before you can finish. |
| `git commit` | Finishes a conflict that came from `git merge`. Opens an editor with a default merge commit message you can normally accept as-is. |
| `git rebase --continue` | Finishes a conflict that came from `git rebase` (or `git pull --rebase`). Different command from `git commit` because a rebase and a merge are different operations underneath. |
| `git merge --abort` | Cancels an in-progress merge entirely, returning to exactly the state before you ran `git merge`. Use if a conflict is more than you want to resolve right now. |
| `git rebase --abort` | Same idea as above, but for a rebase in progress. |
| `git log --oneline --graph --all` | After resolving, shows the merge commit (or, for a rebase, the replayed commit) and how it connects to both original branches. |

## Notes

- `git add` during a conflict is doing a different job than usual — it's a resolution marker, not just "stage this edit."
- Whether you finish with `git commit` or `git rebase --continue` depends entirely on which command caused the conflict in the first place. Mixing them up is a common early mistake.
- Both `--abort` commands are fully safe — they don't leave partial state behind.
