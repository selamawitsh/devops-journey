# Session 10 — Git Mastery Project

Detailed notes. This is the last session of Phase 3 — not a new command, but everything from Sessions 1–9 combined into one realistic, end-to-end workflow.

---

## 1. The shift in this session

```
Sessions 1–9              Session 10
─────────────             ─────────────────────────
one new concept    ──►    combine everything into
at a time                 a single real workflow
```

Every earlier session taught one tool in isolation (branching, merge vs rebase, hooks, tags, GitHub Actions, reflog). This session is where you prove you can chain them together the way an actual job would require.

---

## 2. The full combined workflow

```
Branching
   │
Feature development
   │
Commits
   │
Rebase / sync with main
   │
Pull Request
   │
GitHub Actions
   │
Review
   │
Merge
   │
Tag / Release
   │
(Recovery skills held in reserve, from Session 9)
```

---

## 3. The scenario you're practicing

> "We have a DevOps learning repository. Add a small deployment-documentation feature, follow our Git workflow, and make sure GitHub automatically checks it."

```
feature/git-mastery
        │
   documentation added
        │
      commit
        │
      push
        │
  Pull Request ──► GitHub Actions runs
        │
      review
        │
      merge
        │
   tag release (v1.0.0)
```

This is deliberately the same shape as a real feature ticket at a company — small, documented, checked by CI, reviewed, merged, versioned.

---

## 4. Project structure

```
devops-journey/
├── phase_3_git/
│   ├── 01-git-fundamentals/
│   ├── 02-git-internals/
│   ├── 03-branching-strategies/
│   ├── 04-merge-and-rebase/
│   ├── 05-conflict-resolution/
│   ├── 06-git-hooks/
│   ├── 07-tags-and-releases/
│   ├── 08-github-workflow/
│   ├── 09-undoing-and-recovering/
│   └── 10-git-mastery-project/
│       ├── README.md            ← project overview
│       ├── CONTRIBUTING.md      ← workflow rules for this "team"
│       ├── deployment.md        ← the feature you're shipping
│       ├── lessons-learned.md   ← written in your own words
│       └── screenshots/
└── .github/
    ├── workflows/
    └── pull_request_template.md
```

---

## 5. Why meaningful commits matter here

```
Fake activity                    Real activity
──────────────                   ─────────────
empty commits just to            each commit represents an
turn the GitHub graph            actual, describable unit
green                            of work you can explain
                                  in an interview
```

A hiring manager looking at this repo should be able to read the commit history and PR description and understand exactly what you did and why — that's the actual point of this project, more than the specific markdown content.

---

## 6. Why this is the foundation of the whole roadmap

```
Git
 │
GitHub
 │
CI/CD
 │
Docker
 │
AWS
 │
Terraform
 │
Kubernetes
 │
Monitoring
 │
Production
```

Every later phase assumes you can already do what this session practices: branch, commit meaningfully, open a PR, let CI check it, merge, and tag a release. Phase 3 isn't "Git trivia" — it's the mechanical foundation the rest of the DevOps pipeline sits on top of.

---

## 7. What "done" looks like

- [ ] `10-git-mastery-project/` exists with README, CONTRIBUTING, deployment docs, and lessons learned
- [ ] Work was done on `feature/git-mastery`, not directly on `main`
- [ ] At least two meaningful, separately-described commits
- [ ] A real Pull Request with a filled-out description
- [ ] GitHub Actions check passing on that PR before merge
- [ ] Merged into `main`
- [ ] Tagged as `v1.0.0`
- [ ] Final active-recall questions answered from memory (see `lab.md`)
