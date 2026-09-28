# Lesson 6 Exercise: Server Status Map

Goal: track server status by name using a map, safely check for servers that may not be monitored yet, and alert on the ones that are down.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 06-maps
cd 06-maps
go mod init maps
```

Check: `go.mod` shows `module maps`.

## Step 2: Write the program yourself

Build:

1. A map literal called `serverStatus` with at least 5 entries, `map[string]string`, mixing statuses like `"healthy"`, `"warning"`, and `"down"`.
2. A loop over `serverStatus` that prints `ALERT: <name> is down` for every server whose status is `"down"`, and prints nothing for the others.
3. A comma-ok check for a server name that is **not** in your map (something you never added, like `"cache-01"`). Print its status if found, or `<name> not being monitored yet` if not found.
4. A comma-ok check for a server name that **is** in your map, to show the contrast with step 3.
5. Add a new server to the map after it's created, using assignment (`serverStatus["new-name"] = "healthy"`), then print `len(serverStatus)` before and after adding it.
6. Delete one server from the map with `delete()`, then print `len(serverStatus)` again to confirm it decreased.
7. Attempt to delete a server name that was never in the map, and confirm nothing breaks.

Do not copy a finished solution. You already have everything needed from the notes:

- map literal syntax
- reading and writing a key
- comma-ok
- `delete()`
- `range` over a map
- `len()` on a map

Target output shape (your exact server names can differ, and the alert order may vary since map order isn't guaranteed):

```text
ALERT: db-01 is down
ALERT: api-02 is down
cache-01 not being monitored yet
web-01 status: healthy
Count before adding: 5
Count after adding: 6
Count after deleting: 5
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./maps
```

Check: run it two or three times in a row. Confirm the alert lines can appear in a different order between runs, but the same set of servers is always alerted.

## Step 4: Break it on purpose, then fix it

Temporarily replace one of your comma-ok checks with a direct read, no comma-ok:

```go
value := serverStatus["some-missing-server"]
fmt.Println(value)
```

Run it and observe: no crash, just an empty string printed with no indication anything was missing. Write down, in your own words, why this is a real bug risk in production code (think: what would a monitoring dashboard show if it silently treated a missing server the same as an empty status?). Then restore the comma-ok version.

## Step 5: Trigger the nil map panic

In a **separate small test**, temporarily add this before your main map logic:

```go
var brokenMap map[string]string
brokenMap["test"] = "value"
```

Run it, copy the exact panic message, then delete these two lines — you don't need them in your final program.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go` run twice in a row (to show alert order can vary)
4. Output of `go build`, `ls`, `./maps`
5. Your explanation from Step 4
6. The exact panic message from Step 5

## Completion checklist

- [ ] `go.mod` exists in `06-maps`
- [ ] `serverStatus` map declared with at least 5 entries
- [ ] Loop alerts on every `"down"` server, using `range`
- [ ] Comma-ok used for a missing key and for an existing key
- [ ] `len()` printed before and after `append`-equivalent (map assignment) and after `delete`
- [ ] `delete()` on a missing key confirmed safe
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and `./maps` produce correct output
- [ ] I reproduced the silent-missing-key risk without comma-ok
- [ ] I reproduced the nil map panic
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "maps" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): lesson 6 maps, server status lookup with comma-ok"
git push
```
