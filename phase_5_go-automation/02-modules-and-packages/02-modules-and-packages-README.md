# Module 02 Notes: Go Modules and Packages

Phase 5, Go for DevOps automation.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why split code into packages

Every exercise so far lived in one `main.go`. That's fine for 50 lines. It falls apart once a real tool like `devopsctl` grows into thousands of lines with AWS logic, config parsing, logging, and health checks all tangled together.

```text
One giant main.go                          Split into packages
-------------------                        --------------------
main.go (2000 lines)                       main.go        (just wires things together)
  - AWS functions                          aws/           (EC2, S3 functions)
  - config parsing                         config/        (YAML/JSON parsing)
  - logging helpers                        logger/        (structured logging)
  - health check logic                     health/        (server checks)
  - main()
(good luck finding anything,               (each department has its own room,
 or letting two people work on it)          two people can work in different rooms at once)
```

A package is like a department in a company. The `aws` department only deals with AWS things. The `logger` department only deals with logging. `main` is the front office — it doesn't do the actual work, it calls into the departments and coordinates them.

```text
                    main (front office)
                          |
          +---------------+---------------+
          v               v               v
      aws dept        config dept     logger dept
   (EC2, S3 work)    (parse files)   (write logs)
```

---

## 2. What a package actually is

`package main` isn't special syntax reserved for executables — every Go file belongs to a package, declared on its first line.

```go
package aws

func ListInstances() {
    // ...
}
```

```text
package main    ->  this folder produces an executable program
package aws     ->  this folder is a reusable library, not runnable on its own
```

A package that isn't `main` can't be run directly with `go run` — it exists to be imported by other code.

---

## 3. The rule: one folder = one package

Every `.go` file in the same folder must declare the same package name (with the exception of `_test.go` files, covered later in the testing module).

```text
project/
 |-- main.go            package main
 |
 |-- aws/
 |    |-- instances.go  package aws
 |    `-- buckets.go    package aws       <- same package, different files, both OK
 |
 `-- config/
      `-- parser.go     package config
```

Files within the same package can call each other's functions directly, no import needed — `instances.go` can call a function defined in `buckets.go` with zero setup, because they're already in the same package.

---

## 4. Creating and importing your own package

### Step 1: the module path (from go.mod)

```text
module github.com/selamawit/devopsctl

go 1.22
```

The module path is the full address of your project. Every package inside your project is imported using this path as a prefix.

### Step 2: create the package folder

```text
devopsctl/
 |-- go.mod                     module github.com/selamawit/devopsctl
 |-- main.go                    package main
 `-- aws/
      `-- instances.go          package aws
```

```go
// aws/instances.go
package aws

func ListInstances() []string {
    return []string{"i-123456", "i-789012"}
}
```

### Step 3: import it by its full path

```go
// main.go
package main

import (
    "fmt"
    "github.com/selamawit/devopsctl/aws"
)

func main() {
    instances := aws.ListInstances()
    fmt.Println(instances)
}
```

```text
import "github.com/selamawit/devopsctl/aws"
                                        |
                              module path + folder name

aws.ListInstances()
 |        |
package  the exported function inside it
name
```

The folder name (`aws`) becomes the name used to call into it (`aws.ListInstances()`), which is why package names should match their folder name.

---

## 5. Exported vs unexported: capitalization is the access control

Same rule seen with struct fields in Lesson 7, applied to everything at the package level: functions, types, variables, constants.

```go
package aws

func ListInstances() []string {   // capitalized -> exported, visible outside "aws"
    return fetchFromAPI()
}

func fetchFromAPI() []string {    // lowercase -> unexported, private to "aws"
    return []string{"i-123456"}
}
```

```text
ListInstances   -> capital L -> can be called from main, or anywhere that imports "aws"
fetchFromAPI    -> lowercase f -> can ONLY be called from inside package aws itself
```

`aws.fetchFromAPI()` from `main.go` is a compile error: `fetchFromAPI is not exported`. There's no `private`/`public` keyword in Go — just the capital letter.

Real-world reasoning: an `aws` package might use a helper internally to format API requests. Keeping it lowercase prevents other packages from depending on it directly, so only the handful of functions meant to be a stable public interface are exposed.

---

## 6. go.mod and go mod tidy

```bash
go mod tidy
```

This command:
- Adds any missing dependencies your code actually imports.
- Removes dependencies listed in `go.mod` that your code no longer uses.
- Updates `go.mod` and `go.sum` accordingly.

Run it after adding or removing any import — the same habit as `go fmt`, not a one-time setup step.

---

## 7. Package naming conventions

```text
short           aws, config, logger        NOT awsHelperFunctions
lowercase       config                      NOT Config or CONFIG
no underscores  configparser                NOT config_parser
match folder    folder "aws/" -> package aws
avoid "utils"   health, aws, config        NOT utils, helpers, common
```

A package called `utils` or `helpers` is a warning sign — it usually means the code wasn't organized by what it actually does, and becomes a place where unrelated functions get mixed together. Real Go codebases (Docker, Kubernetes) name packages after the thing they handle: `aws`, `config`, `logger`, not vague catch-alls.

---

## 8. How engineers debug packages and modules

| Symptom | Usual cause | First check |
|---|---|---|
| `found packages aws (instances.go) and config (parser.go) in ...` | two different `package` declarations in the same folder | make sure every file in a folder declares the same package name |
| `undefined: aws.ListInstances` | function is lowercase (unexported), or typo'd, or not actually in that package | check capitalization and spelling exactly |
| `no required module provides package ...` | import path doesn't match the actual module path in `go.mod`, or `go mod tidy` hasn't been run | compare the import string to the `module` line in `go.mod` |
| `import cycle not allowed` | package A imports package B, and B imports A back | redesign so one of them doesn't depend on the other, often by extracting shared code into a third package |
| Package works from `main` but not from another package | tried to call an unexported (lowercase) function or field from outside its package | capitalize it if it's meant to be used elsewhere, or move the caller into the same package |
