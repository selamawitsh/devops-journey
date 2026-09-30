# Lesson 4 Exercise: Server Decision Logic

Goal: wire `if`/`else`, `switch`, and `for` into the functions from Lesson 3, so the program actually decides something instead of always printing the same result.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 04-control-flow
cd 04-control-flow
go mod init controlflow
```

Check: `go.mod` shows `module controlflow`.

## Step 2: Write the program yourself

Build on the Lesson 3 pattern. Write:

1. A slice of server names:

   ```go
   servers := []string{"web-01", "web-02", "db-01"}
   ```

2. A function `evaluateServer(serverName string, reachable bool, cpuUsage float64)` that:
   - If not reachable, prints `<name> -> DOWN` and returns immediately (no further checks).
   - Otherwise, uses an `else if` chain to print `<name> -> CRITICAL` if CPU is over 90, `<name> -> WARNING` if CPU is over 70, or `<name> -> healthy` otherwise. Check the most severe case first.

3. A `for range` loop over `servers` that calls `evaluateServer` for each one. Hardcode different `reachable` and `cpuUsage` values per server so you can see all three branches (DOWN, CRITICAL/WARNING, healthy) in one run. One server should be unreachable, to prove the early `return` works.

4. A `switch` (no value form) that converts an HTTP-style status code into a message, and call it at least once with a value like `503`.

Do not copy a finished solution. You already have everything needed from the notes:

- `if` / `else if` / `else`
- `switch` with no value
- classic `for`, condition-only `for`, `range`
- `continue` / `break`
- combining results with `&&` and `||`

Target output shape (your exact wording can vary):

```text
web-01 -> healthy
web-02 -> WARNING
db-01 -> DOWN
Server error
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./controlflow
```

Check: `go run` and `./controlflow` produce identical output, and all three severity branches appear across your servers.

## Step 4: Break it on purpose, then fix it

Temporarily reorder your `else if` chain so `cpuUsage > 70` is checked before `cpuUsage > 90`. Run it against a server with `cpuUsage := 95`. Write down what prints and why it is wrong, then put the chain back in the correct order.

## Step 5: Off-by-one, on purpose

Temporarily change your `for range` loop to a classic `for i := 0; i <= len(servers); i++` loop indexing into `servers[i]`. Run it and copy the exact panic message. Then fix it back to `i < len(servers)` or back to `range`.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go`, `go build`, `ls`, `./controlflow`
4. What printed in Step 4, and one sentence on why the order matters
5. The exact panic message from Step 5

## Completion checklist

- [ ] `go.mod` exists in `04-control-flow`
- [ ] `evaluateServer` returns early when not reachable
- [ ] `else if` chain checks CRITICAL before WARNING
- [ ] `for range` loop evaluates every server in the slice
- [ ] `switch` with no value handles at least two status ranges
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and `./controlflow` produce identical, correct output
- [ ] I reproduced and understood the ordering bug in Step 4
- [ ] I reproduced and understood the index-out-of-range panic in Step 5
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "controlflow" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): lesson 4 control flow, if/switch/for on server checks"
git push
```
