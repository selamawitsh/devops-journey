# Session 2: Command Reference - Git Internals

| Command | What it does |
|---|---|
| `git rev-parse --git-dir` | Prints the path to the actual `.git/` directory Git is using, no matter which subfolder you're currently in. Removes the guesswork of "where does .git actually live." |
| `git hash-object <file>` | Computes the SHA-1 hash Git would use for that file's content. Does not store anything — read-only. |
| `git hash-object -w <file>` | Same as above, but `-w` actually writes the content into `.git/objects` as a blob. |
| `git cat-file -t <hash>` | Prints the **type** of the object at that hash: `blob`, `tree`, or `commit`. |
| `git cat-file -p <hash>` | **Pretty-prints** the contents of the object at that hash — file content for a blob, filename/hash listing for a tree, metadata for a commit. |
| `cat .git/HEAD` | Shows what `HEAD` currently points to — normally `ref: refs/heads/<branch>`. |
| `ls .git/objects` | Lists the raw object storage folders directly, bypassing Git's normal interface. Each object is split into a 2-character folder plus a 38-character filename, together forming its 40-character SHA-1 hash. |

## Porcelain vs Plumbing, at a Glance

| | Porcelain | Plumbing |
|---|---|---|
| Examples | `git add`, `git commit`, `git status`, `git log` | `git hash-object`, `git cat-file`, `git rev-parse` |
| Audience | Everyday use | Scripting, tooling, forensic recovery |
| What it does | Wraps plumbing commands in a friendly interface | Operates directly on objects and refs |

## Notes

- `git hash-object` (without `-w`) is safe to run as many times as you want — it never writes anything.
- `git cat-file -t` and `-p` never modify the repository. Use them freely to explore.
- These commands are not things you'll type daily once you're past this session — but understanding what `git add` and `git commit` are doing underneath (writing exactly these kinds of objects) is what makes later topics like merge conflicts and `reset` actually make sense instead of feeling like guesswork.
