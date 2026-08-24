# Challenge — Break Dependency Resolution

**Goal:** Cause and diagnose a broken/conflicting dependency state, then recover, without guessing.

## Task
1. Try to install a package pinned to a version that doesn't exist:
   ```bash
   sudo apt-get install -y "curl=1.0.0-fake"
   ```
2. Check the system for a broken state:
   ```bash
   apt list --broken 2>/dev/null
   sudo apt-get check
   sudo dpkg --audit
   ```
3. Read apt's own suggested fix — but don't run it blind:
   ```bash
   sudo apt-get install -f
   ```

## Questions to answer before you look anything up
- What exact error did apt give you when the fake version was requested?
- Was this a *missing package*, a *version conflict*, or a *broken partial install*? How do you know from the error text alone?
- What would `apt-get install -f` have changed if you'd run it — read its dry-run/prompt output before confirming.

## Deliverable
Fill in `ChallengeAndAnswer.md` with your findings — the exact commands, the exact error text, and your diagnosis in your own words.
