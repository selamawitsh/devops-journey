# Lesson 8 Notes: Error Handling

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why Go handles errors differently

In many languages, when something goes wrong, the program throws an exception that jumps somewhere else, often invisibly:

```text
Python / Java style
--------------------
try:
    checkServer("db-01")
except Exception as e:
    print("something broke:", e)
```

You can call a function and have no idea, just by reading the line, whether it can fail. The failure gets hidden until it explodes at runtime.

Go rejects that. If a function can fail, it says so right in its return type, and you are forced to look at it:

```go
result, err := checkServer("db-01")
if err != nil {
    fmt.Println("something broke:", err)
    return
}
```

```text
Exceptions: failure is invisible until it jumps          Go: failure is a value, sitting right there
-----------------------------------------------          -----------------------------------------
checkServer("db-01")   <- looks safe, might not be        result, err := checkServer("db-01")
   (hope for the best)                                    if err != nil { ... }   <- you MUST look
```

Think of it like a delivery with a signature required. An exception is a package thrown over the fence — you don't know it arrived until it's already in your yard, possibly broken. A Go error is a package the courier hands to you directly, and you have to sign and check the contents before you do anything else.

This is exactly why Go tools are trusted in infrastructure: a script that silently swallows "server unreachable" and keeps going is dangerous. Go makes that mistake hard to write by accident.

---

## 2. The error type

`error` is a built-in interface. Any value of type `error` can be compared to `nil`, and it has a method that gives you a human-readable message.

```go
var err error
fmt.Println(err)          // <nil>
fmt.Println(err == nil)   // true
```

`nil` means: **no error happened; the function succeeded.** This is the value you check for everywhere. It does not mean "empty" — it specifically signals "nothing went wrong."

---

## 3. The core pattern: return (result, error)

Almost every function that can fail in Go follows this shape:

```go
func pingServer(name string) (bool, error) {
    if name == "" {
        return false, errors.New("server name cannot be empty")
    }
    return true, nil
}
```

```text
func pingServer(name string) (bool, error)
                               |     |
                          the real   the error, or nil
                          result     if everything went fine
```

Calling it:

```go
reachable, err := pingServer("web-01")
if err != nil {
    fmt.Println("ping failed:", err)
    return
}
fmt.Println("reachable:", reachable)
```

The rule you'll write constantly: **call the function, immediately check `if err != nil`, handle it or return, and only then trust the result.**

```text
call function
     |
     v
err != nil?
     |
  +--+--+
  |     |
 YES    NO
  |     |
handle  use the
error   result
 (or return)
```

Note: Go's built-in type is `string` (lowercase). Capitalized names are reserved for types you define yourself or exported names from packages.

---

## 4. Creating your own errors

### errors.New: a simple, fixed message

```go
import "errors"

func checkPort(port int) error {
    if port < 1 || port > 65535 {
        return errors.New("port out of valid range")
    }
    return nil
}
```

### fmt.Errorf: a message with dynamic values baked in

```go
import "fmt"

func checkPort(port int) error {
    if port < 1 || port > 65535 {
        return fmt.Errorf("invalid port: %d", port)
    }
    return nil
}
```

`%d` inserts the integer `port` into the message. This is the one you'll reach for almost always in real code — "port out of valid range" is far less useful at 2am than "invalid port: 99999".

---

## 5. Wrapping errors: keeping the original cause

Sometimes a function fails because a function it called failed. You don't want to lose that original error — you want to add context while keeping it.

```go
func checkServer(name string) error {
    err := pingHost(name)
    if err != nil {
        return fmt.Errorf("checkServer failed for %s: %w", name, err)
    }
    return nil
}
```

```text
pingHost fails: "connection refused"
        |
        v  wrapped by checkServer
"checkServer failed for db-01: connection refused"
```

`%w` specifically **wraps** the original error — Go keeps it reachable inside the new one, unlike `%v`, which just turns it into flat text with no way back to the original. Tools like `errors.Is` and `errors.As` can later unwrap it to check what the underlying error actually was. For now: default to `%w` whenever wrapping an error from another function call.

---

## 6. panic: Go's "something is seriously broken" tool

`error` is for expected, recoverable problems: a server is down, a file is missing, input is invalid. `panic` is for bugs — situations that should never happen if the code is correct.

```go
func mustDivide(a, b int) int {
    if b == 0 {
        panic("division by zero")
    }
    return a / b
}
```

```text
error   -> expected, recoverable, part of normal operation ("server down" is not surprising)
panic   -> unexpected, usually a bug, stops the program (or crashes it) unless recovered
```

"Index out of range" from Lesson 5 was a panic the whole time. Rule of thumb: **default to returning an error. Reach for panic only for situations that should genuinely never happen if the code is correct** — not for normal, expected outcomes like "the server didn't respond."

---

## 7. DevOps example: the shape you'll actually write

```go
func checkServer(name string) (bool, error) {
    if name == "" {
        return false, errors.New("server name cannot be empty")
    }

    reachable := pingHost(name) // imagine this does the real network check

    if !reachable {
        return false, fmt.Errorf("server %s is not reachable", name)
    }

    return true, nil
}

for _, name := range servers {
    ok, err := checkServer(name)
    if err != nil {
        fmt.Println("ALERT:", err)
        continue
    }
    fmt.Println(name, "is healthy:", ok)
}
```

`continue` (from Lesson 4) skips to the next server after logging the problem, instead of crashing the whole health check over one bad server.

---

## 8. How engineers debug error handling

| Symptom | Usual cause | First check |
|---|---|---|
| Program crashes with a panic you didn't expect | an actual bug (nil pointer, index out of range), not a normal error case | read the panic message and stack trace; this is not something to silently "handle away" |
| Error message is unhelpful ("something went wrong") | used a bare `errors.New` instead of `fmt.Errorf` with specifics | add the relevant variable into the message with `%s`/`%d`/`%w` |
| Function fails silently, nothing printed | the returned `error` was never checked with `if err != nil` | grep the code for calls that ignore their second return value |
| Original cause of an error is lost after several function calls | used `%v` or string concatenation instead of `%w` when wrapping | switch to `fmt.Errorf("context: %w", err)` |
| One bad server crashes the whole health-check loop | used `panic` for an expected failure like "unreachable," or forgot `continue` | return an `error` instead of panicking, and `continue` past it in the loop |
