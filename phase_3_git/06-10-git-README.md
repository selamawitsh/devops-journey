# Git Study README (06–10)

This README covers the second half of the Git phase:

- Git Hooks
- Tags and Releases
- GitHub Workflow
- Undoing and Recovering
- Git Mastery Project

## Core Concepts

### 1. What is a Git hook?
A Git hook is a script that runs automatically during Git events such as commit, push, or receive.

### 2. Main Git hooks
```bash
pre-commit
pre-push
post-commit
post-receive
```

### 3. Why use hooks?
Hooks enforce quality checks, formatting rules, tests, and team standards before code is committed or pushed.

### 4. What is a tag?
A tag marks a specific point in history, often used for releases.

### 5. What is a release?
A release is a version of software that is packaged and shared, often tagged with a version number.

### 6. What is a Pull Request?
A Pull Request is a proposal to merge one branch into another, usually through GitHub.

### 7. What is GitHub Flow?
GitHub Flow is a common branch-based workflow:

```bash
create branch -> make changes -> commit -> push -> open PR -> review -> merge
```

## Active Recall Questions

### Quick questions
1. What is a Git hook?
2. Where are Git hooks stored?
3. What is a `pre-commit` hook used for?
4. What is a `pre-push` hook used for?
5. Why are hooks useful in a team project?
6. What is a tag in Git?
7. What is the difference between a lightweight tag and an annotated tag?
8. What is a release?
9. Why do teams use version numbers?
10. What is a Pull Request?

### Intermediate questions
11. What is the difference between `git pull` and a Pull Request?
12. What is GitHub Flow?
13. What is the purpose of branch protection?
14. Why is it better to run checks on a pull request instead of directly on `main`?
15. What is `git revert` used for?
16. What is `git reset` used for?
17. When would you use `git restore`?
18. What is `git reflog` used for?
19. What is the difference between undoing and recovering in Git?
20. How can you recover a lost commit?

### Mastery project questions
21. What is the ideal Git workflow for a team project?
22. How do you make sure code is reviewed before merging?
23. How do you protect the main branch?
24. Why is clean commit history important?
25. How do hooks help prevent bad code from being pushed?
26. How do tags help with software release management?
27. What are the steps to safely merge a feature branch?
28. Why do teams prefer small, meaningful commits?
29. How can you explain the full Git flow from local repo to remote GitHub repo?
30. What command would you use to inspect recent actions in a repo?

## Common Practices
- Keep commits small and meaningful
- Always review the diff before committing
- Use descriptive commit messages
- Protect `main` and require review
- Use tags for release points
- Use hooks to automate checks

## One-Line Summary
This phase focuses on using Git in real-world professional workflows: automation, collaboration, safe recovery, and release discipline.
