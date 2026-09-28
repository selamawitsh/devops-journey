# Lesson 7 Exercise: Server Structs and Methods

Goal: replace parallel slices with a slice of `Server` structs, add methods, and prove the value-vs-pointer rule to yourself by breaking it on purpose.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 07-structs
cd 07-structs
go mod init structs
```

Check: `go.mod` shows `module structs`.

## Step 2: Write the program yourself

Build:

1. A `Server` struct type with `Name` (string), `Reachable` (bool), `CPUUsage` (float64).
2. A slice of at least four `Server` instances, using named-field literals, covering a mix of reachable/unreachable and low/high CPU.
3. A value-receiver method `IsHealthy() bool` on `Server` that returns `true` only if `Reachable` is `true` and `CPUUsage` is under `80`.
4. A pointer-receiver method `MarkDown()` on `*Server` that sets `Reachable` to `false`.
5. A loop over the slice (using `for i := range servers`, not `for _, s := range`) that prints `<name> needs attention` for every server where `IsHealthy()` returns `false`.
6. A call to `MarkDown()` on one specific server in the slice (by index, e.g. `servers[1].MarkDown()`), then print that server's `Reachable` field afterward to confirm it actually changed.
7. Append one more `Server` to the slice using `append`, and run the health check loop again to confirm it picks up the new server too.

Do not copy a finished solution. You already have everything needed from the notes:

- struct type definition
- named-field literals
- dot notation for reading and writing fields
- value receiver vs pointer receiver
- `for i := range` for structs you need to modify

Target output shape (your exact server names and values can differ):

```text
web-02 needs attention
db-01 needs attention
web-01 reachable before MarkDown: true
web-01 reachable after MarkDown: false
cache-01 needs attention
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./structs
```

Check: `go run` and `./structs` produce identical output, and the `MarkDown` call visibly changes the field.

## Step 4: Break the value-copy rule on purpose, then fix it

Temporarily change `MarkDown` to a value receiver instead of a pointer receiver:

```go
func (s Server) MarkDown() {
    s.Reachable = false
}
```

Run the program again and confirm, with your own eyes, that `Reachable` no longer changes — even though the function runs without any error. Write down what you observe. Then change it back to a pointer receiver.

## Step 5: Break the range-copy rule on purpose, then fix it

Temporarily rewrite your health-check loop as:

```go
for _, s := range servers {
    if !s.IsHealthy() {
        s.Reachable = false // trying to mark it down here
    }
}
```

Run it and confirm the original slice's `Reachable` values did not actually change (print them afterward to check). Then rewrite it correctly using `for i := range servers` and `servers[i].Reachable = false`, and confirm it works this time.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go`, `go build`, `ls`, `./structs`
4. What you observed in Step 4 (value-receiver `MarkDown` failing silently)
5. What you observed in Step 5 (range-copy failing to mutate), and your corrected version's output

## Completion checklist

- [ ] `go.mod` exists in `07-structs`
- [ ] `Server` struct defined with three fields
- [ ] Slice of at least 4 `Server` instances, named-field literals
- [ ] `IsHealthy()` value-receiver method implemented correctly
- [ ] `MarkDown()` pointer-receiver method implemented correctly
- [ ] Health-check loop uses `for i := range servers`
- [ ] `append` used to add a server after the initial slice
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and `./structs` produce identical, correct output
- [ ] I reproduced the value-receiver `MarkDown` bug and understood why it fails
- [ ] I reproduced the range-copy mutation bug and understood why it fails
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "structs" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): lesson 7 structs and methods, value vs pointer receivers"
git push
```
