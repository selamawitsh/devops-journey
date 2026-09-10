# Session 2: Git Internals

## Goal

By the end of this session you should be able to explain, without notes:

- What `.git/` actually contains
- The three core Git object types: blob, tree, commit
- The difference between porcelain and plumbing commands
- How a commit actually connects to your files (commit -> tree -> blob)
- What `HEAD` is
- Why a branch is not a folder

This is the session that makes everything else stop feeling like magic. Detached HEAD, "why did my merge do that," recovering a commit you thought was gone — all of it comes back to the model in this file.

## 1. Git Is a Key-Value Database, Not a File Tracker

The most common wrong mental model coming in: that Git tracks *files* and *diffs between versions*, like a smarter version of manually copying `file-v2.py`. That is not what's happening underneath.

Git is a **content-addressable object store**. Every piece of content you commit — file contents, directory structure, commit metadata — is stored as an object, and that object's name is the SHA-1 hash of its own content. Not the filename. The content itself.

Why this matters in practice:

- **Deduplication for free** — two files with identical content, even under different names, hash to the same object and get stored once.
- **Tamper detection** — since an object's name *is* a hash of its content, changing the content changes the name. This is why a commit's hash changes the instant you edit even just the commit message.
- **Forensic recovery** — this is the same mechanism that lets you recover a commit after a bad `reset` or `rebase`, weeks later, using nothing but a hash. We'll use exactly that idea in Session 9.

## 2. Anatomy of `.git`

`.git/` lives **once**, at the root of your repository — not inside every subfolder. This trips people up constantly, so let's be precise about it now.

```bash
cd ~/Desktop/devops-journey
ls -la
```

This is where you'll see `.git` in the listing. If you `cd` into a subfolder like `phase_3_git/01-git-fundamentals/lab` and run `ls -la` there, you will **not** see a `.git/` folder — and that's correct, not a problem. Git commands still work from inside that subfolder because Git walks up the directory tree looking for the nearest `.git/`. If you ever want to know exactly where it found it, without guessing:

```bash
git rev-parse --git-dir
```

Inside the real `.git/` folder, the four entries that matter for this session:

| Entry | What it is |
|---|---|
| `HEAD` | A pointer to where you currently are (which branch, which commit) |
| `objects/` | The actual object database — every blob, tree, and commit ever created |
| `refs/` | Branch and tag pointers — small files that just contain a commit hash |
| `index` | The staging area, in file form |

## 3. The Object Types

Git has four object types. We're focused on the first three today; `tag` comes back in Session 7.

| Object | Stores |
|---|---|
| Blob | Raw file content — nothing else, not even the filename |
| Tree | A directory listing — maps filenames to blob (or sub-tree) hashes |
| Commit | A snapshot pointer: one tree, one or more parent commits, author, message |

```
                 Commit
                    |
                    v
                  Tree
                 /    \
                v      v
             Blob    Blob
           notes.txt other.txt
```

## 4. Porcelain vs Plumbing

Commands you use daily — `git add`, `git commit`, `git status`, `git log` — are called **porcelain**: user-friendly, high-level.

Underneath, Git has **plumbing** commands that operate directly on objects. Porcelain commands are literally implemented on top of plumbing commands — `git commit` is, underneath, creating a tree object and a commit object using the same mechanism you're about to use by hand.

Why plumbing commands matter beyond curiosity: they're what tooling and Git hooks are built on, and they're your only option when something has gone wrong enough that porcelain commands won't show you what you need — e.g. finding a commit that no branch points to anymore.

## 5. Blob: Building One By Hand

If you haven't already got a committed file to work with, set one up:

```bash
cd ~/Desktop/devops-journey/phase_3_git/01-git-fundamentals/lab
echo "Git is a version control system." > notes.txt
git add notes.txt
git commit -m "lab: add Git fundamentals notes"
```

Now inspect the content itself:

```bash
cat notes.txt
git hash-object notes.txt
```

That second command returns a SHA-1 hash of the file's content — but it hasn't stored anything yet, it has only computed what the hash *would* be. To actually write it into the object database:

```bash
git hash-object -w notes.txt
```

`-w` means "write this object into `.git/objects`." Copy the hash it prints — you'll use it in the next two commands. To confirm what type of object you just created:

```bash
git cat-file -t <hash>
```

Expected output: `blob`

And to see what's actually inside it:

```bash
git cat-file -p <hash>
```

Expected output: your file's exact content. Notice the blob has no idea the file is called `notes.txt` — it is purely content. Filenames are the tree's job, covered next.

## 6. Tree: Where the Filename Actually Lives

A tree object maps filenames to blob hashes (or to other trees, for subdirectories). This is the missing piece from Section 5 — the blob had content but no name; the tree is what says "this hash is called `notes.txt`."

## 7. Commit: Tying It Together

A commit object points to exactly one tree (the full snapshot at that point) plus:

```
Commit
├── tree     -> the project snapshot
├── parent   -> the previous commit (if any)
├── author
├── committer
└── message
```

This parent pointer is the entire reason `git log` can show you a linear history — each commit literally contains the hash of the commit before it.

```
Commit C  --parent-->  Commit B  --parent-->  Commit A
```

## 8. Inspect Your Own Commit End-to-End

This is the exercise that makes the diagram above stop being abstract.

```bash
git log --oneline
```

Copy the latest commit hash, then:

```bash
git cat-file -t <commit-hash>
```
Expected: `commit`

```bash
git cat-file -p <commit-hash>
```

You'll see something like:

```
tree 4f8abc...
parent 2b7d9e1...
author Selamawit <...>
committer Selamawit <...>

lab: add Git fundamentals notes
```

Copy the `tree` hash from that output, then follow it:

```bash
git cat-file -t <tree-hash>
```
Expected: `tree`

```bash
git cat-file -p <tree-hash>
```

You'll see something like:

```
100644 blob abc123...    notes.txt
```

Read that line carefully: `100644` is the file mode (a regular, non-executable file), `blob abc123...` is the object it points to, and `notes.txt` is the name the tree assigns to that blob. You've now walked the full chain by hand:

```
                 COMMIT
                    |
                  tree
                    v
                  TREE
                    |
                notes.txt
                    v
                  BLOB
                    |
                    v
        "Git is a version control system."
```

## 9. HEAD

```bash
cat .git/HEAD
```

Typical output:

```
ref: refs/heads/main
```

`HEAD` doesn't point at a commit directly — it points at a branch, and the branch points at a commit:

```
HEAD -> main -> latest commit -> tree -> blobs
```

## 10. A Branch Is Not a Folder

This is the fact that unlocks branching in Session 3, so get it settled now: a branch is a small text file under `refs/heads/` containing nothing but a commit hash. That's it.

```
main     -> Commit C -> Commit B -> Commit A
feature  -> Commit D -> Commit C
```

Creating a branch means writing one new line to one small file — it does not copy your codebase. This is exactly why `git branch` is instant even on massive repositories, and why Git branching is described as "cheap" compared to version control systems that do copy the whole tree.

## Active Recall

Answer from memory, no looking back:

1. What is the `.git` directory, and where does it live relative to your project's subfolders?
2. What does a blob store — and what does it deliberately *not* know about the file?
3. What does a tree represent?
4. What four things does a commit object point to or contain?
5. What does `git cat-file -t <hash>` tell you?
6. What does `git cat-file -p <hash>` do differently from `-t`?
7. Fill in the blank: `Commit -> ??? -> Blob`
8. Is a Git branch a folder, or a reference to something? What exactly does it contain?
9. Why does creating a new branch not slow down as your repository grows?
