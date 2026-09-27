# Lesson 1 Notes: What Go Is and How a Go Program Starts

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `lesson-1-recall.md` (revision questions) and `lesson-1-exercise.md` (hands-on task).

---

## 1. What is Go?

Go is a programming language developed at Google.

In this roadmap, Phase 5 is "Go: Automation and Scripting". We use Go to build DevOps tools: APIs, AWS automation, configuration handling, system commands, concurrency, CLI tools, testing and compiled binaries.

---

## 2. Why Go for DevOps?

Imagine you are a DevOps engineer and your company has:

```text
50 AWS EC2 instances
20 S3 buckets
10 servers
many configuration files
many repetitive tasks
```

You could check everything by hand, but that is slow and error-prone. Instead you write one automation tool:

```text
             Go automation tool
                    |
     +--------------+--------------+
     |              |              |
  AWS API     server commands   health checks
     |              |              |
     +--------------+--------------+
                    |
                    v
      ./aws-auditor   or   ./health-checker
```

---

## 3. Source code to executable

```text
   main.go
      |
      |  Go compiler
      v
 executable binary
      |
      v
   ./program
      |
      v
  automation
```

Precise wording to remember:

> Go can compile a program into a single executable binary that generally does not require Go to be installed on the target machine.

Why this matters for DevOps:

```text
Your laptop
    |
    |  go build
    v
aws-auditor          <- one executable file
    |
    |  copy
    v
AWS server
    |
    +-- ./aws-auditor     (runs without Go installed)
```

---

## 4. package main

```go
package main
```

Meaning: "this file belongs to the `main` package."

Every Go file belongs to a package. An executable program uses the `main` package. A project can have many packages:

```text
project
 |
 +-- main      <- the executable
 +-- aws       <- AWS helper functions
 +-- config    <- config handling
 +-- logger    <- logging
 `-- health    <- health checks
```

Example of a function in a different package:

```go
package aws

func ListInstances() {
    // ...
}
```

`ListInstances` belongs to the `aws` package, not to `main`.

Reception analogy:

```text
            COMPANY
               |
          package main        <- the company's front door
               |
         +-----------+
         | Reception |
         |  main()   |        <- where work starts
         +-----------+
               |
         start working
```

---

## 5. func main()

```go
func main() {
    fmt.Println("Hello, Go!")
}
```

`main()` is the starting point of an executable Go program. When the program runs, execution starts here.

```text
        APPLICATION
             |
             v
        func main()
             |
        "start here"
             |
     +-------+-------+
     v       v       v
   task    task    task
```

Rule: `package main` plus `func main()` together make an executable program.

---

## 6. import

```go
import "fmt"
```

Meaning: "I want to use functionality from the `fmt` package." `fmt` is part of Go's standard library and provides formatting and printing.

```go
fmt.Println("Hello, Go!")
```

Read it as: from the package `fmt`, use the function `Println`. You do not have to build printing functionality yourself.

---

## 7. go.mod

A Go project normally has a module definition:

```text
hello-go/
 |-- go.mod
 `-- main.go
```

Example `go.mod`:

```text
module hello-go

go 1.22.5
```

A Go module is a collection of Go code managed together as one project. `go.mod` tells Go: "this is a module, here is its name and Go version." Later it also records dependencies.

Rough analogy:

```text
Node.js project  ->  package.json
Go project       ->  go.mod
```

The two are not identical, but the analogy is a useful beginner model.

---

## 8. go run vs go build

### go run

```bash
go run main.go
```

Compiles and runs the program. Uses a temporary executable.

```text
source code -> compile -> run
```

### go build

```bash
go build
```

Compiles the program and creates an executable in the current directory. If your module is `hello-go`, the executable is named `hello-go`.

```text
source code -> compile -> binary
```

Then run the binary:

```bash
./hello-go
```

---

## 9. The complete picture

Project structure for the first lab:

```text
01-hello-go/
 |
 |-- go.mod
 |
 `-- main.go
        |
        |-- package main
        |-- import "fmt"
        `-- func main()
                 |
                 v
           fmt.Println(...)
                 |
                 v
              terminal
```

Mental model of the whole flow:

```text
                 GO PROJECT
                     |
                     v
                  go.mod
            "What is this project?"
                     |
                     v
                package main
            "This is an executable"
                     |
                     v
                func main()
            "Start execution here"
                     |
                     v
              Go instructions
                     |
                     v
                 compiler
                     |
             +-------+-------+
             v               v
          go run          go build
             |               |
             v               v
          run it       create binary
                             |
                             v
                         ./program
```

From the DevOps perspective:

```text
            DEVOPS ENGINEER
                   |
          write Go program
                   |
             compile it
                   |
        single executable file
                   |
        +----------+----------+
        v          v          v
       AWS      servers     APIs
        |          |          |
        +----------+----------+
                   |
                   v
             AUTOMATION
```

---

## 10. Common misconceptions

| Wrong idea | Correct idea |
|---|---|
| Every function belongs to `main` | Every Go file belongs to a package. Executables use `main`, but functions can live in other packages such as `aws`. |
| `go build` downloads dependencies | `go build` compiles and produces an executable. Dependency management is a separate concept. |
| `main.go` is the entry point | The entry point is `func main()` in the `main` package. `main.go` is just the conventional file name. |
| Go has no dependencies at all | Go can compile to a single executable that generally does not need Go installed on the target machine. |
| A module is "a container of code" | A module is a collection of Go code managed together as one project, defined by `go.mod`. |

---

## 11. Where this is heading

```text
Go
 |
 |-- fundamentals
 |-- packages
 |-- APIs
 |-- AWS SDK
 |-- config files
 |-- system commands
 |-- concurrency
 |-- CLI tools
 `-- testing
        |
        v
  DevOps automation
```
