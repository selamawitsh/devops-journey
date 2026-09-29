# Lesson 3 Notes: Functions

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why a health checker needs functions

Your manager says: "Check all our servers." That is actually several separate jobs hiding inside one sentence:

```text
Check servers
     |
     +-- Check reachability
     +-- Check port
     +-- Check CPU
     +-- Check memory
     `-- Create report
```

Each job becomes its own function:

```text
main()
 |
 +-- checkReachability()
 +-- checkPort()
 +-- checkCPU()
 +-- checkMemory()
 `-- generateReport()
```

A function is a small worker with exactly one job:

```text
+--------------------------+
| checkCPU()               |
|                          |
| "Check CPU usage"        |
+--------------------------+
```

`main()` doesn't do the work itself — it tells each worker: "do your job," and collects the results.

---

## 2. What is a function?

A named block of code that performs a particular task, written once and reused anywhere it's needed.

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

Defining a function does not execute it. Go reads the definition and remembers it exists, but nothing runs until the function is actually called.

```go
func sayHello() {
    fmt.Println("Hello")
}
// nothing happens yet, even though Go has compiled this
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

Imagine 100 servers, and every server needs a connectivity check, a port check, and a CPU check. Without functions, that is one giant tangled block of code, where every check is copy-pasted and every bug fix has to be repeated in a dozen places.

```text
main()
 |
 +-- checkConnectivity()
 |
 +-- checkPort()
 |
 `-- checkCPU()
```

Each piece now has one clear responsibility, is easy to test on its own, and only needs to be fixed in one place. This matters even more as programs grow, which is exactly what happens through the rest of this roadmap.

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

`serverName` is a **parameter** — a named placeholder in the function's definition. `"api-server"` is the **argument** — the actual value supplied when the function is called.

```text
checkServer("api-server")
       |
       v
+--------------------+
| serverName         |
| "api-server"       |
+--------------------+
```

A function can take more than one parameter, separated by commas:

```go
func checkServer(serverName string, port int) {
    fmt.Println("Checking", serverName, "on port", port)
}

checkServer("api-server", 443)
```

---

## 7. Functions can return values

Ask: "is this server reachable?" A function can answer with `true` or `false` instead of just printing something.

```go
func isServerReachable() bool {
    return true
}
```

`bool` after the parentheses means "this function returns a boolean." `return true` sends that value back to whoever called the function.

```go
reachable := isServerReachable()
// reachable -> true
```

A function with no return type (like `sayHello` above) doesn't give anything back — it just does something, like printing. A function with a return type must always return a value of that exact type on every code path.

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

This already looks like the shape of a real automation program: give it information, get a result back.

---

## 9. Parameter vs argument vs call

A distinction worth locking in early, because the vocabulary matters once you start reading other people's Go code and documentation:

```text
func checkServer(name string) bool   <- "name" is a PARAMETER (a placeholder in the definition)

checkServer("api-server")            <- "api-server" is an ARGUMENT (the real value)
                                         and this whole line is a CALL (it actually runs the function)
```

Defining `func checkServer(name string) bool` teaches Go what the function looks like and what it needs. It does nothing by itself — no server is checked, nothing prints. Only `checkServer("api-server")`, the call, actually executes it.

---

## 10. A preview: functions can return more than one value

You'll use this constantly starting in Lesson 8, so it's worth seeing the shape now. Go lets a function return **two values at once**, separated by a comma:

```go
func checkServer(name string) (bool, string) {
    if name == "" {
        return false, "server name cannot be empty"
    }
    return true, "ok"
}

reachable, message := checkServer("api-server")
```

```text
func checkServer(name string) (bool, string)
                                |      |
                           first      second
                           return     return
                           value      value
```

Notice both the function's return type (`(bool, string)`) and the variables receiving the result (`reachable, message :=`) list two things, in the same order. This is how Go later lets a function return both a result **and** an error at the same time — the shape is identical, just with `error` as the second type instead of `string`. You don't need to use this for every function in this lesson's exercise, but recognize the shape when you see it.

---

## 11. Function naming conventions

```text
camelCase          checkServer, isServerReachable     NOT check_server, CheckServer (unless exported later)
verb first          checkCPU, generateReport           NOT cpuChecker, reportGenerator
descriptive         isServerReachable                  NOT check2, doThing
boolean-returning    isX, hasX, canX                    isHealthy, hasAccess, canConnect
```

A function name should describe the action it performs. Naming it after a verb (`checkServer`, not `serverCheck`) matches how functions read in a call: "check the server," not "the server check." Functions that return a `bool` conventionally start with `is`, `has`, or `can`, which makes an `if` statement read naturally: `if isServerReachable(name) { ... }` reads almost like English.

---

## 12. The DevOps mental model

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

Instead of one huge program, you build small workers with clear responsibilities, each one testable and reusable on its own. This is the shape every DevOps tool in this roadmap will keep following, just with more layers added on top: functions become methods on structs (Lesson 7), results become `(value, error)` pairs (Lesson 8), and related functions get grouped into packages (Module 02).

---

## 13. How engineers debug functions

| Symptom | Usual cause | First check |
|---|---|---|
| "I called the function but nothing happened" | the function was only defined, never actually called | search the file for the function name followed by `(` with real arguments, not just `func name(...)` |
| `not enough arguments in call to checkServer` | forgot to pass a required parameter | compare the function's signature to how it's being called |
| `checkServer(name string) bool` used, but the result looks wrong | confused a parameter (placeholder in the definition) with an argument (the real value passed in) | re-read the definition versus the call site side by side |
| Function returns the wrong type, or compiler complains about the return | the `return` statement doesn't match the declared return type, or a code path is missing a `return` entirely | check every branch of the function has a `return` matching the declared type |
| Two functions seem to do almost the same thing | a function was copy-pasted and modified slightly instead of adding a parameter to the original | consider whether a single function with an extra parameter replaces both |
