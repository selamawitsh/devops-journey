# Module 03 Lesson Notes: Files and System

Phase 5, Go for DevOps automation.

Related files: `02-active-recall.md` (revision questions) and `03-practical-lab.md` (hands-on labs).

---

## 1. Big picture: why a DevOps tool touches files and the OS

Every lesson so far hardcoded data directly into `main.go`. Real tools don't work that way.

```text
Hardcoded (what you've done so far)        Real tool (what you need now)
------------------------------------       -----------------------------
servers := []string{"web-01", "db-01"}     servers.txt  (on disk, editable
(change the list? edit the .go file,        without touching code, by anyone
 recompile, redeploy)                       on the team, no Go knowledge needed)
```

Think of your program as an employee, and a file as a memo someone left on their desk. The employee doesn't know what's in the memo until they pick it up and read it.

```text
servers.txt (sitting on disk)
      |
      |  your Go program opens it
      v
  read the content
      |
      v
  use it (loop over servers, parse a config, etc.)
```

And once that employee has done the work, they write their own memo back: a report, a log entry. They also sometimes need to know things about the building they're standing in — which office, which floor — which is what system info gives your program about the machine it's running on.

---

## 2. Reading files

### The simplest way: os.ReadFile

```go
import "os"

data, err := os.ReadFile("servers.txt")
if err != nil {
    fmt.Println("could not read file:", err)
    return
}

fmt.Println(string(data))
```

`os.ReadFile` returns `([]byte, error)` — the same `(result, error)` shape from Lesson 8. Every file operation can fail (missing file, no permission, disk problem), so Go forces you to check `err`.

```text
os.ReadFile("servers.txt")
          |
   +------+------+
   |             |
 data          err
([]byte)     (nil or an error)
```

It returns raw bytes, not text, because Go doesn't assume a file is text — it could be an image or any binary. `string(data)` converts those bytes into a readable Go string.

### Reading line by line: bufio.Scanner

`os.ReadFile` gives you the whole file as one blob. Often you want to process it one line at a time:

```text
servers.txt
------------
web-01
web-02
db-01
```

```go
import (
    "bufio"
    "fmt"
    "os"
)

file, err := os.Open("servers.txt")
if err != nil {
    fmt.Println("could not open file:", err)
    return
}
defer file.Close()

scanner := bufio.NewScanner(file)
for scanner.Scan() {
    line := scanner.Text()
    fmt.Println("Server:", line)
}
```

```text
os.Open("servers.txt")    -> opens the file, gives you a *os.File (a handle to it)
defer file.Close()        -> "close this file when the surrounding function ends"
bufio.NewScanner(file)    -> wraps the file so you can read it piece by piece
scanner.Scan()            -> advances to the next line; returns false when there are no more
scanner.Text()            -> gives you the current line as a string
```

### defer: schedule cleanup immediately

```go
file, err := os.Open("servers.txt")
defer file.Close()
```

`defer` schedules a function call to run right before the surrounding function returns, no matter how it returns — normally, via an early `return`, or even after a `panic`. Writing `defer file.Close()` immediately after a successful `os.Open` means you cannot forget to close the file — cleanup is handled before you've even written the code that uses it.

```text
os.Open()
    |
defer file.Close()   <- scheduled now, runs LATER, automatically
    |
... do work with the file ...
    |
function returns  ---->  file.Close() runs automatically here
```

### Checking if a file exists before reading it

```go
if _, err := os.Stat("servers.txt"); os.IsNotExist(err) {
    fmt.Println("servers.txt does not exist")
    return
}
```

`os.Stat` gets information about a file. `os.IsNotExist(err)` checks specifically "was this error because the file doesn't exist?" — not every file error means missing; it could be a permissions problem instead, which you'd want to handle differently.

---

## 3. Writing files

### The simplest way: os.WriteFile

```go
content := []byte("web-01: healthy\nweb-02: warning\n")
err := os.WriteFile("report.txt", content, 0644)
if err != nil {
    fmt.Println("could not write file:", err)
    return
}
```

```text
os.WriteFile(path, data, permissions)
                           |
                 who can read/write this file
                 (covered in the next section)
```

`os.WriteFile` **overwrites** the whole file if it already exists, or creates it if it doesn't. This is the right tool when you want a fresh report every run.

### Appending instead of overwriting: os.OpenFile

If you want to add a line to a log file without erasing what's already there:

```go
file, err := os.OpenFile("health.log", os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
if err != nil {
    fmt.Println("could not open log file:", err)
    return
}
defer file.Close()

file.WriteString("web-02 marked down\n")
```

```text
os.O_APPEND    -> write at the end, don't erase existing content
os.O_CREATE    -> create the file if it doesn't exist yet
os.O_WRONLY    -> open it for writing only
```

These are combined with `|` (bitwise OR) because they're flags being stacked together, not separate arguments. This exact pattern, append plus create plus write-only, is the standard shape for a log file that grows over time instead of being replaced on every run.

### Buffered writing: bufio.Writer

For writing many lines efficiently (rather than one slow disk write per line):

```go
file, err := os.Create("report.txt")
if err != nil {
    fmt.Println("could not create file:", err)
    return
}
defer file.Close()

writer := bufio.NewWriter(file)
defer writer.Flush()

writer.WriteString("web-01: healthy\n")
writer.WriteString("web-02: warning\n")
```

`writer.Flush()` is critical: a `bufio.Writer` holds data in memory temporarily before actually writing it to disk, as a performance optimization. If you forget to `Flush()`, some or all of your data may never actually reach the file. `defer writer.Flush()` is the same immediate-cleanup habit as `defer file.Close()` — write it right after creating the writer, before you forget.

---

## 4. File permissions

That `0644` from the write examples isn't arbitrary. It's a permission setting, written in octal, describing who can read, write, or execute the file.

```text
 0   6        4        4
 |   |        |        |
 |  owner   group    others
 |  (you)  (your team) (everyone else)

Each digit is a sum of:
  4 = read
  2 = write
  1 = execute

6 = 4 + 2 = read + write
4 = 4     = read only
```

```text
0644  ->  owner: read+write   group: read only   others: read only
0755  ->  owner: read+write+execute   group: read+execute   others: read+execute
```

`0644` is the standard permission for a regular file like a report or config — you can edit it, everyone else can only view it. `0755` is the standard permission for something that needs to be executed, like a compiled binary or a shell script — everyone can run it, only you can change it.

### Checking a file's permissions

```go
info, err := os.Stat("report.txt")
if err != nil {
    fmt.Println("could not stat file:", err)
    return
}
fmt.Println("Permissions:", info.Mode())
```

### Checking for a permission error specifically

```go
_, err := os.ReadFile("/root/secret.txt")
if os.IsPermission(err) {
    fmt.Println("not allowed to read this file")
}
```

This is the permission-specific sibling of `os.IsNotExist` from the reading section — same idea, different question being asked of the error.

---

## 5. Directories

### Creating a directory

```go
err := os.Mkdir("logs", 0755)
```

`os.Mkdir` creates one directory. It fails if the parent directory doesn't exist yet.

```go
err := os.MkdirAll("logs/2026/october", 0755)
```

`os.MkdirAll` creates every missing directory along the path, like `mkdir -p` on the command line. This is almost always the one you want in real code, since you rarely know in advance whether the parent already exists.

### Listing what's inside a directory

```go
entries, err := os.ReadDir("logs")
if err != nil {
    fmt.Println("could not read directory:", err)
    return
}

for _, entry := range entries {
    fmt.Println(entry.Name(), entry.IsDir())
}
```

`os.ReadDir` returns a slice of directory entries. `entry.IsDir()` tells you whether each one is itself a folder or a regular file — useful when a logs folder might contain both files and dated subfolders.

### Building paths safely: filepath.Join

```go
import "path/filepath"

path := filepath.Join("logs", "2026", "report.txt")
// "logs/2026/report.txt" on Linux/Mac, "logs\2026\report.txt" on Windows
```

Never build a path by concatenating strings with `+` and a hardcoded `/`. `filepath.Join` handles the separator correctly for whatever operating system the program is actually running on — directly relevant since your tools may run on a Linux server even if you develop on something else.

---

## 6. System information

### Hostname

```go
hostname, err := os.Hostname()
if err != nil {
    fmt.Println("could not get hostname:", err)
    return
}
fmt.Println("Running on:", hostname)
```

### OS and architecture

```go
import "runtime"

fmt.Println("OS:", runtime.GOOS)
fmt.Println("Arch:", runtime.GOARCH)
```

Same `GOOS`/`GOARCH` values from Lesson 1's build targets, but read here at runtime instead of set at compile time — useful for a tool that logs what kind of machine it actually ran on.

### Environment variables

```go
value := os.Getenv("AWS_REGION")
fmt.Println(value)   // "" if not set, no error
```

`os.Getenv` has the exact same silent-zero-value trap as a missing map key from Lesson 6: if the variable isn't set, you get `""` with no indication anything was wrong. The safer version:

```go
value, exists := os.LookupEnv("AWS_REGION")
if !exists {
    fmt.Println("AWS_REGION is not set")
}
```

This is comma-ok again, same idiom, different source. For listing everything currently set:

```go
for _, env := range os.Environ() {
    fmt.Println(env)
}
```

`os.Environ()` returns every environment variable as `"KEY=value"` strings.

---

## 7. DevOps example: the shape you'll actually write

```go
func writeReport(servers []string, path string) error {
    hostname, _ := os.Hostname()

    var lines []string
    lines = append(lines, fmt.Sprintf("Report generated on: %s", hostname))
    lines = append(lines, fmt.Sprintf("OS: %s", runtime.GOOS))

    for _, s := range servers {
        lines = append(lines, fmt.Sprintf("Checked: %s", s))
    }

    content := []byte(strings.Join(lines, "\n"))
    return os.WriteFile(path, content, 0644)
}
```

This single function pulls together file reading's counterpart (writing), permissions (`0644`), and system info (`os.Hostname`, `runtime.GOOS`) into exactly the kind of report-writing function a real health checker needs.

---

## 8. How engineers debug file and system operations

| Symptom | Usual cause | First check |
|---|---|---|
| `open servers.txt: no such file or directory` | wrong path, or running the program from a different folder than expected | print the working directory, or use an absolute path temporarily |
| File handle "leaks" / odd behavior with many files | forgot `defer file.Close()` | add it immediately after a successful `os.Open` or `os.Create`, every time |
| Wrote to a file but it's empty or incomplete | used `bufio.Writer` and forgot `writer.Flush()` | add `defer writer.Flush()` right after creating the writer |
| File gets overwritten when you meant to append | used `os.WriteFile` or `os.Create` instead of `os.OpenFile` with `O_APPEND` | switch to `os.OpenFile(path, os.O_APPEND\|os.O_CREATE\|os.O_WRONLY, perm)` |
| `permission denied` | the file or directory's permission bits don't allow the operation for the current user | check with `os.Stat(...).Mode()`, or `os.IsPermission(err)` |
| `os.Mkdir` fails but `os.MkdirAll` would succeed | parent directory in the path doesn't exist yet | use `os.MkdirAll` unless you specifically need to fail on a missing parent |
| Path works on your machine, breaks on a teammate's or on a server | path built with hardcoded `/` or `\` instead of `filepath.Join` | rebuild the path using `filepath.Join` |
| `os.Getenv` returns `""` but you expected a real value | the environment variable isn't actually set, and `Getenv` doesn't distinguish "unset" from "set to empty" | switch to `os.LookupEnv` and check the second return value |
