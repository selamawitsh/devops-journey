# Lesson 8 Exercise: Real Errors Instead of Print Statements

Goal: rework your Lesson 7 server structs so that failures come back as proper `error` values instead of just being printed inline, and the health-check loop handles them the right way.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 08-error-handling
cd 08-error-handling
go mod init errorhandling
```

Check: `go.mod` shows `module errorhandling`.

## Step 2: Write the program yourself

Bring in the `Server` struct from Lesson 7:

```go
type Server struct {
    Name      string
    Reachable bool
    CPUUsage  float64
}
```

Now build:

1. A function `checkServer(s Server) (bool, error)` that:
   - Returns `false` and an `errors.New` error if `s.Name` is empty.
   - Returns `false` and a `fmt.Errorf` error (including the server name) if `s.Reachable` is `false`.
   - Returns `false` and a `fmt.Errorf` error (including the server name and the CPU value) if `s.CPUUsage` is over `90`.
   - Otherwise returns `true` and `nil`.
2. A function `checkAllServers(servers []Server)` that loops over the slice, calls `checkServer` on each one, and:
   - If `err != nil`, prints `ALERT: <the error>` and uses `continue` to move to the next server.
   - If `err == nil`, prints `<name> is healthy`.
3. A slice of at least 5 `Server` instances covering all four cases: empty name, unreachable, high CPU, and healthy.
4. A separate small function `divide(a, b int) (int, error)` that returns an error (not a panic) if `b == 0`, otherwise returns `a / b` and `nil`. Call it once with `b = 0` and confirm you get an error back, not a crash.

Do not copy a finished solution. You already have everything needed from the notes:

- `(result, error)` return pattern
- `errors.New` and `fmt.Errorf`
- `%w` for wrapping (use it in at least one place, wrapping the result of `divide` inside a message from another function)
- `if err != nil` checks
- `continue` to skip a bad entry without stopping the loop

Target output shape (your exact wording and server names can differ):

```text
ALERT: server name cannot be empty
web-01 is healthy
ALERT: server db-01 is not reachable
ALERT: server web-02 CPU too high: 95.0
divide result: 5
divide error test: division by zero (or your wrapped version)
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./errorhandling
```

Check: `go run` and `./errorhandling` produce identical output, and the loop does not stop early when it hits a bad server.

## Step 4: Prove panic is the wrong tool here, then don't ship it

Temporarily rewrite `checkServer` to `panic` instead of returning an error when a server is unreachable:

```go
if !s.Reachable {
    panic("server not reachable: " + s.Name)
}
```

Run the program and observe: the entire program crashes and stops at the first unreachable server, instead of continuing to check the rest. Copy the panic output. Then revert back to returning a proper error.

## Step 5: Wrap an error and trace it back

In `checkAllServers`, when you print an error from `divide`, wrap it with `fmt.Errorf` and a bit of context (e.g. `"health check math failed: %w"`), and print the wrapped message. Confirm the original message ("division by zero") is still visible inside the wrapped one.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go`, `go build`, `ls`, `./errorhandling`
4. The panic output from Step 4, and one sentence on why `panic` was the wrong choice there
5. The wrapped error message from Step 5

## Completion checklist

- [ ] `go.mod` exists in `08-error-handling`
- [ ] `checkServer` returns `(bool, error)`, covering all four cases (empty name, unreachable, high CPU, healthy)
- [ ] `checkAllServers` checks `err != nil` and uses `continue`, never stops the loop early
- [ ] `errors.New` used at least once, `fmt.Errorf` used at least twice
- [ ] `%w` used at least once to wrap an error
- [ ] `divide` returns an error for division by zero instead of panicking
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and `./errorhandling` produce identical, correct output
- [ ] I reproduced the panic-stops-everything problem and understood why it's wrong here
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "errorhandling" > .gitignore
git status
```

