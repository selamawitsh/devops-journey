# Module 03 Practical Lab: Files and System

Three labs, done in order: `file-reader`, `file-writer`, `system-info`. Each builds on the last — `file-writer` reuses `file-reader`'s server list, and `system-info` feeds into the report `file-writer` produces.

Read `01-lesson-notes.md` first. Revise with `02-active-recall.md` between labs.

---

## Lab 1: file-reader

Goal: read a real `servers.txt` file into your program, line by line, with proper error handling.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/03-files-and-system
mkdir file-reader
cd file-reader
go mod init filereader
```

### Step 2: Create the input file

```bash
cat > servers.txt << 'EOF'
web-01
web-02
db-01
cache-01
EOF
```

### Step 3: Write the program yourself

Build `main.go`:

1. Use `os.Stat` and `os.IsNotExist` to check `servers.txt` exists before trying to read it. Print a clear message and return if it doesn't.
2. Use `os.Open` plus `bufio.Scanner` to read the file line by line, with `defer file.Close()` immediately after the open succeeds.
3. Skip any blank lines.
4. Print each server name prefixed with `"Server: "`.
5. After the loop, print how many servers were loaded.

Do not copy a finished solution. You already have everything needed from the notes:

- `os.Open`, `defer`, `bufio.Scanner`
- `os.Stat` / `os.IsNotExist`
- a slice to collect the lines if you want to count them

Target output:

```text
Server: web-01
Server: web-02
Server: db-01
Server: cache-01
Loaded 4 servers
```

### Step 4: Run and build

```bash
go fmt ./...
go run main.go
go build
./filereader
```

### Step 5: Break it on purpose, then fix it

Temporarily rename `servers.txt` to something else, run the program, and copy the exact behavior: does it print your "does not exist" message, or does it crash? Confirm your `os.IsNotExist` check actually catches it before any read is attempted. Then rename the file back.

---

## Lab 2: file-writer

Goal: write a report to a file, both overwriting and appending, using the server list from Lab 1.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/03-files-and-system
mkdir file-writer
cd file-writer
go mod init filewriter
```

Copy your `servers.txt` from Lab 1 into this folder too (or reuse the reading logic you already wrote).

### Step 2: Write the program yourself

Build `main.go`:

1. Read `servers.txt` the same way as Lab 1.
2. Write a function `writeReport(servers []string, path string) error` that builds a report (one line per server, e.g. `"Checked: web-01"`) and writes it with `os.WriteFile` at permission `0644`. Return any error, don't panic.
3. Call it once, writing to `report.txt`. Confirm the file was created by printing its contents back with `os.ReadFile`.
4. Separately, use `os.OpenFile` with `O_APPEND|O_CREATE|O_WRONLY` to append one additional line to a file called `health.log`, e.g. `"run completed\n"`. Run the program twice in a row and confirm `health.log` has two lines, not one, while `report.txt` stays at a fixed size each run.

Do not copy a finished solution. You already have everything needed from the notes:

- `os.WriteFile` with a permission value
- `os.OpenFile` with the append/create/write-only flags
- `defer file.Close()` on the appended file

Target behavior:

```text
report.txt     -> same content every run (overwritten)
health.log     -> grows by one line every run (appended)
```

### Step 3: Run and build

```bash
go fmt ./...
go run main.go
go run main.go
cat report.txt
cat health.log
go build
./filewriter
```

### Step 4: Break it on purpose, then fix it

Temporarily switch the `health.log` logic to use `os.WriteFile` instead of `os.OpenFile` with append flags. Run the program twice and confirm the log now only has one line, proving it got overwritten instead of appended. Then switch it back.

---

## Lab 3: system-info

Goal: gather basic information about the machine running the program, and fold it into a report header.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/03-files-and-system
mkdir system-info
cd system-info
go mod init systeminfo
```

### Step 2: Write the program yourself

Build `main.go`:

1. Print the hostname using `os.Hostname()`, handling its error.
2. Print the OS and architecture using `runtime.GOOS` and `runtime.GOARCH`.
3. Use `os.LookupEnv` to check for an environment variable called `DEVOPS_ENV`. If it's not set, print `"DEVOPS_ENV not set"`. If it is set, print its value.
4. Print every environment variable currently set using `os.Environ()` — just the count of how many there are, not the full list (it can be long).
5. Combine everything into a single `buildSystemHeader() string` function that returns a multi-line string like:
   ```text
   Host: your-machine-name
   OS: linux
   Arch: amd64
   Env: production (or "not set")
   ```
   and print it.

Do not copy a finished solution. You already have everything needed from the notes:

- `os.Hostname`
- `runtime.GOOS`, `runtime.GOARCH`
- `os.LookupEnv` (comma-ok)
- `os.Environ`
- `fmt.Sprintf` to build the multi-line string

### Step 3: Run and build

```bash
go fmt ./...
go run main.go
DEVOPS_ENV=production go run main.go
go build
./systeminfo
```

Check: the second run (with `DEVOPS_ENV=production` set inline) should show a different result than the first for that specific line.

### Step 4: Break it on purpose, then fix it

Temporarily replace `os.LookupEnv("DEVOPS_ENV")` with plain `os.Getenv("DEVOPS_ENV")`, run it without the environment variable set, and confirm you can no longer tell "it's unset" apart from "it's set to an empty string" just by looking at the output. Then switch it back to `LookupEnv`.

---

## What to send for review (all three labs together)

1. Your answers to the recall questions in `02-active-recall.md`
2. `main.go` for `file-reader`, `file-writer`, and `system-info`
3. Output of each lab's run/build steps
4. The three "break it on purpose" results (missing file, overwritten log, Getenv vs LookupEnv)

## Completion checklist

- [ ] `file-reader`: reads `servers.txt` line by line, handles a missing file cleanly
- [ ] `file-writer`: overwrites `report.txt`, appends to `health.log` correctly
- [ ] `system-info`: reports hostname, OS, arch, and an environment variable with comma-ok
- [ ] All three use `defer` for any opened file
- [ ] All three `go fmt ./...` cleanly
- [ ] All three recall drills attempted without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

Do this per lab, so each has its own history:

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/03-files-and-system/file-reader
echo "filereader" > .gitignore

cd ../file-writer
echo "filewriter" > .gitignore
echo "report.txt" >> .gitignore
echo "health.log" >> .gitignore

cd ../system-info
echo "systeminfo" > .gitignore
```

```bash
cd ~/Desktop/devops-journey
git add phase_5_go/go-automation/03-files-and-system/file-reader
git commit -m "feat(go): module 03, file-reader reads servers.txt with error handling"

git add phase_5_go/go-automation/03-files-and-system/file-writer
git commit -m "feat(go): module 03, file-writer overwrites reports and appends logs"

git add phase_5_go/go-automation/03-files-and-system/system-info
git commit -m "feat(go): module 03, system-info reports hostname, OS, arch, and env vars"

git push
```
