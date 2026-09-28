# Lesson 5 Exercise: A Real Server List

Goal: replace hardcoded, one-at-a-time server checks with a slice, and run every server in it through Lesson 4's `evaluateServer` function.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 05-arrays-slices
cd 05-arrays-slices
go mod init arraysslices
```

Check: `go.mod` shows `module arraysslices`.

## Step 2: Write the program yourself

Bring in the `evaluateServer` function from Lesson 4 (copy it in, you don't need to reinvent it):

```go
func evaluateServer(serverName string, reachable bool, cpuUsage float64) {
    if !reachable {
        fmt.Println(serverName, "-> DOWN")
        return
    }

    if cpuUsage > 90 {
        fmt.Println(serverName, "-> CRITICAL")
    } else if cpuUsage > 70 {
        fmt.Println(serverName, "-> WARNING")
    } else {
        fmt.Println(serverName, "-> healthy")
    }
}
```

Now build:

1. A slice of at least four server names.
2. A parallel slice of `reachable` values (`bool`) and a slice of `cpuUsage` values (`float64`), one entry per server, so you can loop over all three together by index.
3. A `for` loop (classic form, using `len()`, not a hardcoded number) that calls `evaluateServer` for every server using the matching reachable and cpuUsage values at that index.
4. After the loop, use `append` to add one more server, with its own reachable and cpuUsage values added to the parallel slices, then evaluate just that new one.
5. Print `len(servers)` before and after the `append`, so you can see the count change.
6. Use slicing (`[0:2]` or similar) to print just the first two servers' names, labeled clearly, e.g. `First two servers: [...]`.

Do not copy a finished solution. You already have everything needed from the notes:

- slice literals
- `len()`
- `append()` with reassignment
- classic `for` with an index
- slicing with `[start:end]`

Target output shape (your exact server names and values can differ):

```text
Server count before append: 4
web-01 -> healthy
web-02 -> WARNING
db-01 -> DOWN
cache-01 -> CRITICAL
Server count after append: 5
new-server -> healthy
First two servers: [web-01 web-02]
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./arraysslices
```

Check: `go run` and `./arraysslices` produce identical output.

## Step 4: Break it on purpose, then fix it

Temporarily replace your `len(servers)` loop bound with a hardcoded number matching the *original* count, then run the program again after the `append` step has already grown the slice. Confirm the newly appended server never gets evaluated in the main loop (it may still be silently missing from output, not necessarily a panic). Then push the hardcoded number one past the actual slice length, so it reads past the end, and copy the exact panic message. Fix the loop back to `len(servers)` afterward.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go`, `go build`, `ls`, `./arraysslices`
4. What happened with the hardcoded-but-correct-at-the-time bound (the silently skipped server), and the exact panic message from the too-large bound

## Completion checklist

- [ ] `go.mod` exists in `05-arrays-slices`
- [ ] Slice of servers declared with at least 4 entries
- [ ] Loop bound uses `len()`, not a hardcoded number
- [ ] `append` used and reassigned correctly
- [ ] Slice count printed before and after `append`
- [ ] A sub-slice (`[start:end]`) is created and printed
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and `./arraysslices` produce identical, correct output
- [ ] I reproduced the silently-skipped-item bug from a stale hardcoded bound
- [ ] I reproduced and understood the index-out-of-range panic
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "arraysslices" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): lesson 5 arrays and slices, server list with append and slicing"
git push
```
