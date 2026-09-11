# Session 8 — GitHub Workflow

Detailed notes with diagrams. This is the "why" and "how it fits together" file for this session.

---

## 1. Git vs GitHub — two different layers

```
         LOCAL MACHINE                    GITHUB (hosted platform)
   ┌───────────────────────┐        ┌────────────────────────────┐
   │  git add               │        │  Pull Requests               │
   │  git commit             │  push  │  Issues                     │
   │  git branch             │ ─────► │  GitHub Actions              │
   │  git merge / rebase     │        │  Branch protection           │
   └───────────────────────┘        │  CODEOWNERS / PR templates   │
                                     └────────────────────────────┘
```

**Git** = version control, runs on your laptop, works with zero internet connection.
**GitHub** = a hosting + collaboration + automation layer built *on top of* Git.

You can use Git your whole career without ever touching GitHub. GitHub is what turns solo version control into a *team workflow*.

---

## 2. Why you don't commit straight to `main`

```
   Without branches                    With branches

   main ──●──●──●──✕(bug)              main ──●──●──●───────────►
           everyone is                         │
           affected                            └── feature/x ──●──●
                                                        │
                                                        └── PR reviewed,
                                                            checks pass,
                                                            THEN merged
```

A mistake on a feature branch only affects that branch. A mistake on `main` affects everyone pulling from it — including any automation deploying from it.

---

## 3. What a Pull Request actually is

A PR is **a proposal to merge one branch into another**, with a review surface attached:

```
feature/add-monitoring
        │
        ▼
   ┌─────────────────────────────┐
   │  Pull Request                │
   │  ─────────────────           │
   │  • diff of every changed file │
   │  • full commit history        │
   │  • comment threads            │
   │  • automated check results    │
   │  • mergeable / blocked status │
   └─────────────────────────────┘
        │
        ▼
      main
```

You're saying: *"here's finished work, reviewed and check-passed — bring it into main."*

### PR ≠ `git pull` — common early confusion

| | `git pull` | Pull Request |
|---|---|---|
| Where | Local Git command | GitHub feature |
| What it does | Fetches + merges remote changes into your current local branch | Proposes merging one branch into another, with review attached |
| Runs where | Your terminal | GitHub's servers/UI |

---

## 4. GitHub Flow — the workflow to internalize

```
 1. branch off main
         │
 2. make changes ──► 3. commit
                            │
                     4. push branch
                            │
                     5. open Pull Request
                            │
                6. review ─┴─ GitHub Actions run
                            │
                     7. merge into main
                            │
                     8. deploy
```

This is the loop you repeat for essentially every change, forever, at every company that uses GitHub seriously.

---

## 5. GitHub Actions — automation triggered by repo events

```
  developer            GitHub                 Actions runner
      │                    │                        │
      │── git push ───────►│                        │
      │                    │── trigger workflow ───►│
      │                    │                        │── checkout code
      │                    │                        │── run tests
      │                    │                        │── build
      │                    │                        │── security scan
      │                    │◄── pass/fail ──────────│
```

Workflow files live at the **repo root**:

```
devops-journey/
├── .github/
│   └── workflows/
│       └── test.yml
├── phase_1_linux_adminstration/
├── phase_2_networking/
├── phase_3_git/
└── ...
```
Not nested inside `phase_3_git/08-github-workflow/` — GitHub only looks for workflows at `.github/workflows/` at the repository's top level.

### Anatomy of a workflow file

```yaml
name: Test              # ← workflow name shown in the Actions tab

on:                      # ← TRIGGER: when does this run?
  pull_request:
    branches: [main]

jobs:                    # ← the work to perform
  test:
    runs-on: ubuntu-latest   # ← RUNNER: the VM this executes on

    steps:                   # ← STEPS: the actual commands
      - uses: actions/checkout@v4
      - run: echo "Running tests..."
```

```
 name  →  what shows in the UI
 on    →  trigger (push? pull_request? schedule?)
 jobs  →  units of work
 runs-on → which machine image runs the job
 steps →  the ordered commands inside a job
```

### Why trigger on `pull_request`, not just `push`

```
   push-only trigger                pull_request trigger

   feature branch                   feature branch
        │                                │
      commit ×5                        commit ×5
        │                                │
     (no checks run)                  PR opened
        │                                │
      merge to main                  Actions run: test / lint / build
        │                                │
   checks run AFTER                  ❌ fails → fix before merge
   the damage is already             ✅ passes → safe to merge
   in main
```

Running checks **on the PR** catches problems before they ever reach `main`. This is what "Continuous Integration" means in practice.

---

## 6. Branch protection

```
        main 🔒
          ▲
          │  merge only allowed if:
          │  ✔ PR required (no direct push)
          │  ✔ status checks passing
          │  ✔ required approvals given
          │  ✔ conversations resolved
          │
       Pull Request
          ▲
      feature/*
```

Branch protection is what turns "please don't push broken code to main" from a social norm into something GitHub actually enforces.

---

## 7. CODEOWNERS — who reviews what

File: `.github/CODEOWNERS`

```
.github/workflows/   @devops-team
terraform/           @infrastructure-team
```

```
   file/directory  changed  ──►  GitHub auto-requests review from the owner
```

Matters once more than one person touches a repo — not critical for a solo learning repo, but worth knowing.

---

## 8. Pull Request templates

File: `.github/pull_request_template.md` — GitHub auto-loads this into the PR description box every time a PR is opened.

```
## What changed?

## Why?

## Testing

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No secrets committed
```

Standardizes what every PR description contains, instead of everyone writing something different.

---

## 9. CI vs CD

```
   CI (Continuous Integration)        CD (Continuous Delivery/Deployment)
   ──────────────────────────         ────────────────────────────────
   push / PR                          CI passes
      │                                   │
   build ─► test ─► lint ─► scan       build image ─► push image ─► deploy
      │
   "is this change safe?"             "get this change to users"
```

**CI verifies. CD delivers.** CI is what you're building this session; CD comes later in the roadmap once there's an actual deployment target.

---

## 10. The full picture

```
   Developer
      │
      ▼
   feature branch ──► commit ──► push ──► Pull Request
                                              │
                              ┌───────────────┴───────────────┐
                              ▼                                ▼
                          Review                        GitHub Actions
                                                          (test / lint / build)
                              │                                │
                              └───────────────┬────────────────┘
                                               ▼
                                          all pass ✅
                                               │
                                               ▼
                                            Merge
                                               │
                                               ▼
                                             main 🔒
```

**Takeaway:** Git manages the code history. GitHub provides the collaboration and automation layer wrapped around that history — and Pull Requests are the hinge everything else (review, CI, branch protection) attaches to.
