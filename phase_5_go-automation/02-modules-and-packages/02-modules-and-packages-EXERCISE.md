# Module 02 Exercise: Splitting Into Real Packages

Goal: take the error-handling health-check logic from Lesson 8 and split it into a proper multi-package project, exactly the shape `devopsctl` will eventually take.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the module

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation
mkdir 02-modules-and-packages
cd 02-modules-and-packages
go mod init github.com/selamawit/devopsctl-lesson
```

Check: `go.mod` shows `module github.com/selamawit/devopsctl-lesson`. Use your own GitHub username in place of `selamawit` if you prefer, but be consistent for the rest of the exercise.

## Step 2: Build the folder structure

```bash
mkdir health
touch main.go health/health.go
```

You should have:

```text
02-modules-and-packages/
 |-- go.mod
 |-- main.go
 `-- health/
      `-- health.go
```

## Step 3: Write the health package

In `health/health.go`, write `package health` (not `main`) containing:

1. A `Server` struct (from Lesson 7): `Name`, `Reachable`, `CPUUsage`.
2. An exported function `CheckServer(s Server) (bool, error)` — the same logic as Lesson 8's `checkServer`: error on empty name, error on unreachable, error on CPU over 90, otherwise `true, nil`. Capitalize it so `main` can call it.
3. An unexported helper function, lowercase, that `CheckServer` calls internally — for example a `formatCPUError(name string, cpu float64) error` that builds the "CPU too high" error message using `fmt.Errorf`. This demonstrates keeping an implementation detail private while exposing the main function.

Do not put any of this in `main.go`. It belongs entirely inside `package health`.

## Step 4: Write main.go

In `main.go`, write `package main` that:

1. Imports `fmt` and your `health` package using its full module path, e.g. `"github.com/selamawit/devopsctl-lesson/health"`.
2. Builds a slice of `health.Server` (note the `health.` prefix — you're using the exported type from another package now).
3. Loops over the slice, calls `health.CheckServer(s)` for each one, and prints `ALERT: <err>` or `<name> is healthy`, using `continue` on error, exactly like Lesson 8.

Do not copy a finished solution. You already have everything needed from the notes:

- package declarations
- the module path as an import prefix
- exported vs unexported naming
- calling into an imported package with a `.` prefix

## Step 5: Prove the private helper is actually private

In `main.go`, temporarily try to call your unexported helper directly, e.g. `health.formatCPUError("test", 95.0)`. Run `go build` and copy the exact compiler error. Then remove that line — it was only there to prove the rule.

## Step 6: Run go mod tidy

```bash
go mod tidy
go fmt ./...
go run main.go
go build
ls
./devopsctl-lesson
```

Check: `go run` and the built binary produce identical, correct output, and `go mod tidy` runs without needing to add anything (since you're not using any external dependencies yet — that's expected).

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your `main.go` and `health/health.go`
3. Output of `go run main.go`, `go build`, `ls`, `./devopsctl-lesson`
4. The exact compiler error from Step 5, and one sentence on why Go rejected it

## Completion checklist

- [ ] `go.mod` exists with a real module path
- [ ] `health/health.go` declares `package health`, not `main`
- [ ] `Server` struct and `CheckServer` are both capitalized (exported)
- [ ] At least one unexported helper function exists inside `package health`
- [ ] `main.go` imports `health` using the full module path
- [ ] `main.go` calls `health.CheckServer` and `health.Server`, using the `health.` prefix
- [ ] `go mod tidy` runs cleanly
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and the built binary produce identical, correct output
- [ ] I reproduced and understood the "not exported" compiler error
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "devopsctl-lesson" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): module 02, split health check logic into its own package"
git push
```
