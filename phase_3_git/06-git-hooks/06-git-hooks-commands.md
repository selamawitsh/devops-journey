# Session 6: Command Reference - Git Hooks

| Command | Description |
|---|---|
| `ls -la .git/hooks/` | Lists the hooks folder, including the default `.sample` files every repo starts with. |
| `nano .git/hooks/pre-commit` | Creates or edits the `pre-commit` hook script directly. |
| `chmod +x .git/hooks/pre-commit` | Marks the hook file as executable — required, or Git will see the file but be unable to run it. |
| `ls -l .git/hooks/pre-commit` | Confirms the permission bits, e.g. `-rwxr-xr-x`, so you can see the execute (`x`) flag is actually set. |
| `git status` | After a blocked commit, confirms the file is still staged and nothing was lost. |
| `git commit -m "..."` | Triggers `pre-commit` automatically as part of creating the commit. |
| `git commit --no-verify` | Skips client-side hooks (`pre-commit`, `commit-msg`) entirely. Useful to know exists, not something to reach for by default. |
| `git config core.hooksPath .githooks` | Points Git at a different, project-tracked folder for hooks, so they can be committed and shared with a team instead of staying local-only. |

## Notes

- `.sample` files never run — Git only executes a file with the exact hook name (`pre-commit`, not `pre-commit.sample`) and the executable bit set.
- Hooks in the default `.git/hooks/` location are never committed or pushed — that's why real teams use `core.hooksPath` instead once they want shared checks.
- `--no-verify` is the reason local hooks are a convenience layer, not a security guarantee — anyone can bypass them on their own machine.
