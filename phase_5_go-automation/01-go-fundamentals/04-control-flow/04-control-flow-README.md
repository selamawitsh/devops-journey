# Lesson 4 Notes: Control Flow

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: from functions to decisions

Lesson 3's functions always did the same thing: `checkCPU()` always returned `true`. A real health checker needs to **decide** based on what it finds.

```text
Is the server reachable?
        |
       YES --------------------------> continue checking
        |
        NO ---------------------------> stop, mark server DOWN

Is CPU > 80%?
        |
       YES ---------> send an alert
        |
        NO ----------> mark healthy
```

`if`/`else` gives you the decision. `for` gives you the repetition across many servers.

```text
main()
  |
  +-- for each server in the list        <- loop
  |     |
  |     +-- if not reachable             <- decision
  |     |     mark DOWN, skip the rest
  |     |
  |     +-- if CPU > 80                  <- decision
  |           alert
  |
  `-- generateReport()
```

---

## 2. if / else: one decision

```go
reachable := true

if reachable {
    fmt.Println("Server is up")
} else {
    fmt.Println("Server is down")
}
```

```text
if <condition> {
    // runs when condition is true
} else {
    // runs when condition is false
}
```

No parentheses needed around the condition. Braces `{ }` are always required, even for a one-line body. (In C-family languages, parentheses disambiguate the condition from the next statement; Go's braces already do that job, so the parentheses are unnecessary.)

### Comparison operators

```text
==   equal to
!=   not equal to
>    greater than
<    less than
>=   greater than or equal to
<=   less than or equal to
```

```go
cpuUsage := 92.5

if cpuUsage > 80 {
    fmt.Println("ALERT: high CPU")
} else {
    fmt.Println("CPU normal")
}
```

### else if: multiple branches

```go
if cpuUsage > 90 {
    fmt.Println("CRITICAL")
} else if cpuUsage > 70 {
    fmt.Println("WARNING")
} else {
    fmt.Println("OK")
}
```

Go checks top to bottom and runs the **first** condition that matches, then stops. Order matters: check the most severe condition first. If `> 70` were checked before `> 90`, a CPU of 95 would incorrectly stop at "WARNING" and never reach "CRITICAL."

### Logical operators

```text
&&   AND — both sides must be true
||   OR  — at least one side must be true
!    NOT — flips true to false, false to true
```

```go
reachable := true
cpuOK := false

if reachable && cpuOK {
    fmt.Println("Fully healthy")
} else {
    fmt.Println("Needs attention")
}
```

This is how you combine results from `checkReachability`, `checkCPU`, and `checkMemory` into one decision.

### = vs ==

```go
if reachable = true {   // compile error
```

Go's compiler rejects this, because `if` requires a `bool` expression and `=` is assignment, not comparison. Some languages (C, older JavaScript) let this slip through as a silent bug. Go catches it for you, but knowing the difference matters everywhere you write conditions.

---

## 3. switch: many branches on one value

Cleaner than a long `else if` chain checking the same variable.

```go
status := "warning"

switch status {
case "ok":
    fmt.Println("All good")
case "warning":
    fmt.Println("Keep an eye on it")
case "critical":
    fmt.Println("Page someone now")
default:
    fmt.Println("Unknown status")
}
```

Go does **not** fall through to the next case automatically. Once a case matches, it stops. (C and Java require an explicit `break` per case, or execution falls into the next one, a well-known source of bugs.)

### switch with no value: each case is its own condition

```go
statusCode := 503

switch {
case statusCode >= 500:
    fmt.Println("Server error")
case statusCode >= 400:
    fmt.Println("Client error")
default:
    fmt.Println("OK")
}
```

This form is common in real Go code, and behaves like an `else if` chain but reads more cleanly.

---

## 4. for: Go's only loop keyword

Go has one loop keyword. It covers what other languages split into `for`, `while`, and `do-while`.

### Classic form: loop N times

```go
for i := 0; i < 5; i++ {
    fmt.Println("Checking server", i)
}
```

```text
i := 0        <- runs once, before the loop starts
i < 5         <- checked before every run; loop stops when false
i++           <- runs after every iteration
```

The three parts are separated by semicolons, not commas or spaces alone.

### Condition-only form: Go's "while"

```go
attempts := 0
for attempts < 3 {
    fmt.Println("Retry attempt", attempts)
    attempts++
}
```

### Infinite loop with break

```go
for {
    fmt.Println("Polling server...")
    break // stop the loop
}
```

Real DevOps pattern: retry a connection until it succeeds or a max attempt count is hit, then `break`.

### range: looping over a collection

```go
servers := []string{"web-01", "web-02", "db-01"}

for index, name := range servers {
    fmt.Println(index, name)
}
```

Output:

```text
0 web-01
1 web-02
2 db-01
```

Discard the index with `_` if you don't need it:

```go
for _, name := range servers {
    fmt.Println("Checking:", name)
}
```

### continue: skip to the next iteration

```go
for _, name := range servers {
    if name == "db-01" {
        continue // skip this one, move to the next server
    }
    fmt.Println("Checking:", name)
}
```

`continue` skips the rest of the current iteration only. `break` exits the loop entirely.

---

## 5. Putting it together

```go
func evaluateServer(serverName string, reachable bool, cpuUsage float64) {
    if !reachable {
        fmt.Println(serverName, "-> DOWN")
        return
    }

    if cpuUsage > 80 {
        fmt.Println(serverName, "-> ALERT: high CPU")
    } else {
        fmt.Println(serverName, "-> healthy")
    }
}
```

`return` with no value just stops the function early. Common real-world pattern: check the worst case first, bail out immediately, and only check the next condition if still going.

---

## 6. How engineers debug control flow

| Symptom | Usual cause | First check |
|---|---|---|
| Wrong branch runs | conditions checked in the wrong order | read top to bottom, find the first one that could match too early |
| Loop never ends | condition never becomes false, or forgot `i++` | print the loop variable each iteration |
| Loop runs one time too many or too few | off-by-one in the condition (`<=` vs `<`) | manually trace `i` for the first and last iteration |
| `index out of range` panic | looping past the end of a slice | check the loop bound is `< len(slice)`, not `<= len(slice)` |
| `switch` does the wrong thing | forgetting Go doesn't fall through, or missing a `default` | check each case is mutually exclusive |
| Data leaks between iterations | reused variable name shadowing in nested loops | rename loop variables to be unmistakable, e.g. `i`, `j` |
