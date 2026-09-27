# Lesson 3 Notes: Functions

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why a health checker needs functions

Your manager says: "Check all our servers." That is actually several jobs:

```text
Check servers
     |
     +-- Check reachability
     +-- Check port
     +-- Check CPU
     +-- Check memory
     `-- Create report
```

Each job becomes a function:

```text
main()
 |
 +-- checkReachability()
 +-- checkPort()
 +-- checkCPU()
 +-- checkMemory()
 `-- generateReport()
```

A function is a small worker with one job:

```text
+--------------------------+
| checkCPU()               |
|                          |
| "Check CPU usage"        |
+--------------------------+
```

`main()` tells that worker: "do your job."

---

## 2. What is a function?

A named block of code that performs a particular task.

```go
func sayHello() {
    fmt.Println("Hello")
}
```

Calling it:

```go
sayHello()
```

Flow:

```text
main()
  |
  | call
  v
sayHello()
  |
  v
"Hello"
```

---

## 3. Function anatomy

```go
func sayHello() {
    fmt.Println("Hello")
}
```

```text
func        ->  tells Go we're defining a function
sayHello    ->  function name
()          ->  parameters go here
{ }         ->  function body
```

```text
func
 |
 v
function declaration
 |
 v
name
 |
 v
parameters
 |
 v
body
```

---

## 4. Calling a function

Defining a function does not execute it.

```go
func sayHello() {
    fmt.Println("Hello")
}
// nothing happens yet
```

You must call it:

```go
sayHello()
```

Full example:

```go
package main

import "fmt"

func sayHello() {
    fmt.Println("Hello")
}

func main() {
    sayHello()
}
```

Flow:

```text
program starts
      |
      v
   main()
      |
      v
 sayHello()
      |
      v
 print "Hello"
```

---

## 5. Why functions matter in DevOps

Imagine 100 servers, and every server needs a connectivity check, a port check, and a CPU check. Without functions, that is one giant tangled block of code.

```text
main()
 |
 +-- checkConnectivity()
 |
 +-- checkPort()
 |
 `-- checkCPU()
```

Each piece now has one clear responsibility. This matters even more once programs grow larger, which is exactly what will happen through the rest of this roadmap.

---

## 6. Functions can receive information: parameters

```go
func checkServer(serverName string) {
    fmt.Println("Checking:", serverName)
}
```

Call it:

```go
checkServer("api-server")
// Checking: api-server
```

`serverName` is a **parameter**. `"api-server"` is the **argument**, the value passed in.

```text
checkServer("api-server")
       |
       v
+--------------------+
| serverName         |
| "api-server"       |
+--------------------+
```

---

## 7. Functions can return values

Ask: "is this server reachable?" A function can answer with `true` or `false`.

```go
func isServerReachable() bool {
    return true
}
```

`bool` after the parentheses means "this function returns a boolean." `return true` gives the result back.

```go
reachable := isServerReachable()
// reachable -> true
```

---

## 8. Function with parameter and return value together

```go
func isServerReachable(serverName string) bool {
    fmt.Println("Checking:", serverName)
    return true
}

reachable := isServerReachable("api-server")
```

Flow:

```text
main()
 |
 | "api-server"
 v
isServerReachable()
 |
 +-- serverName = "api-server"
 |
 `-- return true
        |
        v
reachable = true
```

This already looks like the shape of a real automation program.

---

## 9. Parameter vs argument vs call

A distinction worth locking in early:

```text
func checkServer(name string) bool   <- "name" is a PARAMETER (a placeholder in the definition)

checkServer("api-server")            <- "api-server" is an ARGUMENT (the real value)
                                         and this whole line is a CALL (it actually runs the function)
```

Defining `func checkServer(name string) bool` teaches Go what the function looks like. It does nothing by itself. Only `checkServer("api-server")` executes it.

---

## 10. The DevOps mental model

```text
                  main()
                    |
          +---------+---------+
          v         v         v
     checkServer  checkCPU  checkPort
          |         |         |
          v         v         v
       result     result     result
          |         |         |
          +---------+---------+
                    v
                 report
```

Instead of one huge program, you build small workers with clear responsibilities, each one testable and reusable on its own.
