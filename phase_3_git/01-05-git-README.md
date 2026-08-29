# Git Study README (01–05)

This README covers the first half of the Git phase:

- Git Fundamentals
- Git Internals
- Branching Strategies
- Merge and Rebase
- Conflict Resolution

## Core Concepts

### 1. What is Git?
Git is a distributed version control system used to track changes in files and coordinate work among developers.

### 2. What is a repository?
A repository is a Git project folder that stores the full history of your code.

### 3. The Git lifecycle
```bash
working directory -> git add -> staging area -> git commit -> local repository
```

### 4. Main Git commands
```bash
git init
git clone
git status
git add
git commit
git log
git diff
git branch
git checkout / git switch
git merge
git rebase
```

## Active Recall Questions

### Quick questions
1. What is the difference between Git and GitHub?
2. What does `git status` show?
3. What is the purpose of `git add`?
4. What is the purpose of `git commit`?
5. What is the difference between the working directory and the staging area?
6. What is a commit in Git?
7. Why is the staging area useful?
8. What is a branch?
9. Why do developers use branches?
10. What is the difference between `git merge` and `git rebase`?

### Intermediate questions
11. What does `git log` help you see?
12. What is the difference between a local branch and a remote branch?
13. What is the purpose of `git diff`?
14. What happens when Git detects a merge conflict?
15. How do you resolve a merge conflict?
16. What is a fast-forward merge?
17. What is a three-way merge?
18. When would you use a branch strategy in a real team?
19. What is the difference between `git checkout` and `git switch`?
20. Why should you check `git status` before committing?

### Git internals questions
21. What is a blob in Git?
22. What is a tree in Git?
23. What is a commit object?
24. How does Git store file history?
25. Why is Git called a content-addressed system?
26. What is the HEAD reference?
27. What is the purpose of the `.git` directory?
28. What is the relationship between commits and parent commits?

## Common Mistakes to Remember
- Committing without checking `git status`
- Forgetting to pull before pushing changes
- Using `git add .` without reviewing the diff
- Resolving conflicts without understanding both versions
- Mixing feature work with unrelated fixes

## One-Line Summary
Git helps you record, track, and manage versions of your project safely across time and across multiple contributors.
