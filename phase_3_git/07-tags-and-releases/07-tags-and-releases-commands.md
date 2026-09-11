# Session 7: Command Reference - Git Tags & Releases

| Command | Description |
|---|---|
| `git tag v1.0.0` | Creates a lightweight tag on the current commit — just a pointer, no extra metadata. |
| `git tag -a v1.0.0 -m "message"` | Creates an annotated tag on the current commit — a real object with its own hash, storing the message, tagger, and date. Preferred for real releases. |
| `git tag -a v1.0.0 <commit-hash> -m "message"` | Creates an annotated tag on a specific past commit rather than the current one. |
| `git tag` | Lists all tag names. |
| `git tag -n` | Lists all tags along with their messages. |
| `git show v1.0.0` | Shows full details of a tag and the commit it points to. |
| `git rev-parse v1.0.0` | Resolves a tag name to its actual commit (or tag object) hash. |
| `git cat-file -t v1.0.0` | Shows the object type — `tag` for an annotated tag, or resolves straight to `commit` for a lightweight one. |
| `git log --oneline --decorate` | Shows commit history with tag names labeled next to the commits they point to. |
| `git push origin v1.0.0` | Pushes one specific tag to the remote. |
| `git push origin --tags` | Pushes every local tag to the remote at once. |
| `git tag -d v1.0.0` | Deletes a tag locally. |
| `git push origin --delete v1.0.0` | Deletes a tag on the remote (after it's already been pushed). |

## Notes

- Plain `git push` does not push tags — this is the most common tag-related mistake. Always push tags explicitly.
- Lightweight tags are fine for quick personal bookmarks; annotated tags are the standard for anything you'd call a real release.
- Deleting a tag that a CI/CD pipeline or teammate already relies on can cause real confusion — treat pushed tags with the same caution as shared branches.
