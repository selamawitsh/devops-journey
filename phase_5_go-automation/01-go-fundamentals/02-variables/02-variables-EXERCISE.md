# Lesson 2 Exercise: Server Information Program

Goal: declare variables of each basic type and print them, mirroring the shape of data a real DevOps tool works with.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up the lab

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/01-go-fundamentals
mkdir 02-variables
cd 02-variables
go mod init variables
```

Check: `go.mod` shows `module variables`.

## Step 2: Write the program yourself

Open `main.go`:

```bash
nano main.go
```

Write a small server information program with variables for:

```text
server name
IP address
port
CPU usage
whether the server is reachable
```

Then print all five.

Target output shape:

```text
Server Name: api-server
IP Address: 10.0.1.50
Port: 8080
CPU Usage: 65.4
Reachable: true
```

Do not copy a finished solution. You already have everything needed from the notes:

- `var` and `:=`
- `string`, `int`, `float64`, `bool`
- `fmt.Println()`

Use whichever declaration style you prefer for each variable, but be ready to explain the choice.

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
ls
./variables
```

Check: both `go run` and `./variables` print the same five lines.

## Step 4: Break it on purpose, then fix it

Temporarily add this line anywhere after `port` is declared:

```go
port = "ssh"
```

Run:

```bash
go run main.go
```

Read the compiler error carefully, write down what it says, then delete that line so the program compiles again.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of `go run main.go`, `go build`, `ls`, `./variables`
4. The exact compiler error from Step 4, and one sentence on why it happened

## Completion checklist

- [ ] `go.mod` exists in `02-variables`
- [ ] Five variables declared, covering `string`, `int`, `float64`, `bool`
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` prints all five values correctly
- [ ] `go build` and `./variables` produce the same output
- [ ] I triggered and read a real type-mismatch compiler error
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "variables" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
git add .
git commit -m "feat(go): lesson 2 variables and basic data types"
git push
```
