# Lesson 3 Exercise: Server Check Functions

Goal: split a health-check program into small functions, some with parameters, some with return values, matching the shape a real automation tool uses.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 03-functions
cd 03-functions
go mod init functions
```

Check: `go.mod` shows `module functions`.

## Step 2: Write the program yourself

Open `main.go` and build a small server-check program with these functions:

1. `checkReachability(serverName string) bool` — prints `Checking reachability: <name>` and returns `true`.
2. `checkCPU(serverName string) bool` — prints `Checking CPU: <name>` and returns `true` if you imagine CPU usage is under a threshold, otherwise `false`. You can hardcode the result for now.
3. `checkMemory(serverName string) bool` — same idea as `checkCPU`, for memory.
4. `generateReport(serverName string, reachable bool, cpuOK bool, memoryOK bool)` — takes no return value, just prints a summary line combining all three results.

In `main()`, call the three check functions for a server named `"api-server"`, store each result in its own variable, then call `generateReport` with all four values.

Do not copy a finished solution. You already have everything needed from the notes:

- function declaration syntax
- parameters
- return values
- calling a function and storing its result

Target output shape:

```text
Checking reachability: api-server
Checking CPU: api-server
Checking Memory: api-server
Report for api-server -> Reachable: true, CPU OK: true, Memory OK: true
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./functions
```

Check: both `go run` and `./functions` print the same four lines.

## Step 4: Extend it

Add a second server, for example `"db-01"`, and run all four functions for it too, right after the first server's report. This is the same pattern the real health checker will use when it loops over many servers later in the roadmap.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go`, `go build`, `ls`, `./functions`
4. One sentence: what would break if `generateReport` tried to also `return` a value but you never assigned it to anything?

## Completion checklist

- [ ] `go.mod` exists in `03-functions`
- [ ] Four functions defined: reachability, CPU, memory, report
- [ ] At least two functions take a parameter
- [ ] At least two functions return a `bool`
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` prints correct output for at least one server
- [ ] `go build` and `./functions` produce the same output
- [ ] Second server added and checked
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "functions" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): lesson 3 functions with parameters and return values"
git push
```
