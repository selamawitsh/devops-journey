# Lesson 7 Notes: Structs

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why you need structs

Lesson 5 built three parallel slices:

```go
servers := []string{"web-01", "web-02", "db-01"}
reachable := []bool{true, true, false}
cpuUsage := []float64{45.0, 92.5, 0.0}
```

This works, but it's fragile. Nothing stops these three slices from drifting out of sync:

```text
servers[0]   = "web-01"        reachable[0]   = true         cpuUsage[0]   = 45.0
servers[1]   = "web-02"        reachable[1]   = true         cpuUsage[1]   = 92.5
servers[2]   = "db-01"         reachable[2]   = false        cpuUsage[2]   = 0.0

If you append to "servers" and forget to append to "reachable" too...
servers[3]   = "cache-01"      reachable[?]   = ???          <- index mismatch, silent bug
```

What you want is one record per server, holding all its fields together. That's a struct.

```text
Instead of three separate lists that must stay in sync...              ...one bundle per server:

servers   reachable   cpuUsage                                +------------------+
web-01    true        45.0                                    | Server           |
web-02    true        92.5                                    |  Name: web-01    |
db-01     false       0.0                                     |  Reachable: true |
                                                                |  CPUUsage: 45.0  |
                                                                +------------------+
```

Think of a struct like an ID card or a form: name, port, CPU usage, reachable — all fields that belong to one server, printed on one card, so they can never accidentally get separated.

```text
+---------------------------+
|        SERVER CARD        |
+---------------------------+
| Name:      web-01         |
| Reachable: true           |
| CPUUsage:  45.0           |
+---------------------------+
```

---

## 2. Defining a struct type vs creating an instance

These are two separate steps, and mixing them up is the most common early mistake.

```go
// Step 1: define the type -- happens once, describes the shape
type Server struct {
    Name      string
    Reachable bool
    CPUUsage  float64
}
```

```text
type       -> tells Go we're defining a new type
Server     -> the name of the new type
struct     -> this type is a struct (a bundle of fields)
{ }        -> the fields go here, one per line
```

```go
// Step 2: create an instance -- happens every time you need one
webServer := Server{
    Name:      "web-01",
    Reachable: true,
    CPUUsage:  45.0,
}
```

By convention, the type name is capitalized (`Server`), and a variable holding an instance is lowercase (`webServer`). `Server` is now a real type, just like `string` or `int`, except you defined its shape yourself.

---

## 3. Creating an instance

### Named-field literal (always prefer this)

```go
webServer := Server{
    Name:      "web-01",
    Reachable: true,
    CPUUsage:  45.0,
}
```

Naming fields explicitly means the order doesn't matter and the code documents itself.

### Positional literal (avoid this)

```go
webServer := Server{"web-01", true, 45.0}
```

Works, but if the struct's field order changes later, this line silently breaks — values land in the wrong fields with no compiler error. Avoid it once a struct has more than one or two fields.

### Zero value

```go
var s Server
fmt.Println(s)   // {  false 0}
```

An uninitialized struct isn't an error. Every field gets its own zero value (`""` for `Name`, `false` for `Reachable`, `0` for `CPUUsage`), the same rule seen with maps.

---

## 4. Accessing and modifying fields: dot notation

```go
fmt.Println(webServer.Name)        // web-01
fmt.Println(webServer.CPUUsage)    // 45

webServer.CPUUsage = 92.5          // update a field
fmt.Println(webServer.CPUUsage)    // 92.5
```

```text
webServer
   |
   +-- .Name       -> "web-01"
   +-- .Reachable  -> true
   `-- .CPUUsage   -> 92.5
```

Dot notation works the same way for reading and for writing — the only difference is which side of `=` it's on.

---

## 5. Slices of structs: replacing the parallel-slice mess

```go
servers := []Server{
    {Name: "web-01", Reachable: true, CPUUsage: 45.0},
    {Name: "web-02", Reachable: true, CPUUsage: 92.5},
    {Name: "db-01", Reachable: false, CPUUsage: 0.0},
}

for _, s := range servers {
    fmt.Println(s.Name, s.Reachable, s.CPUUsage)
}
```

Every server's data now travels together. Appending a new server means appending one struct:

```go
servers = append(servers, Server{Name: "cache-01", Reachable: true, CPUUsage: 12.0})
```

---

## 6. The value-copy gotcha

The single biggest surprise coming from other languages.

```go
func markDown(s Server) {
    s.Reachable = false
}

webServer := Server{Name: "web-01", Reachable: true}
markDown(webServer)
fmt.Println(webServer.Reachable)   // still true!
```

```text
webServer (original)              s (inside markDown, a COPY)
+------------------+              +------------------+
| Reachable: true   |   passed    | Reachable: true  |
+------------------+  --copy-->   +------------------+
        |                                 |
   unaffected                    s.Reachable = false
        |                                 |
   still true                       only the copy changes
```

Passing a struct to a function passes a copy. Changing a field inside the function changes the copy only.

Fix: pass a pointer instead.

```go
func markDown(s *Server) {
    s.Reachable = false
}

markDown(&webServer)
fmt.Println(webServer.Reachable)   // false, now it worked
```

`&webServer` means "the address of `webServer`." `*Server` in the function signature means "a pointer to a `Server`." Go lets you write `s.Reachable` even though `s` is a pointer — no manual dereferencing needed, unlike C. Rule of thumb: **if a function needs to actually change a struct, it needs a pointer.**

---

## 7. Methods: functions attached to a struct

A method is a function tied to a specific type, written with a receiver.

```go
func (s Server) Describe() string {
    return s.Name + " - reachable: " + fmt.Sprintf("%v", s.Reachable)
}
```

```text
func (s Server) Describe() string
      |    |        |         |
      |    |        |         +-- return type
      |    |        +-- method name
      |    +-- the type this method belongs to
      +-- the receiver: "s" is a Server, just like a parameter
```

Calling it:

```go
webServer := Server{Name: "web-01", Reachable: true}
fmt.Println(webServer.Describe())
// web-01 - reachable: true
```

### Value receiver vs pointer receiver

Same rule as functions: a value receiver `(s Server)` gets a copy and cannot change the original. A pointer receiver `(s *Server)` can.

```go
func (s *Server) MarkDown() {
    s.Reachable = false
}

webServer.MarkDown()
fmt.Println(webServer.Reachable)   // false
```

You call it as `webServer.MarkDown()`, not `(&webServer).MarkDown()` — Go handles that conversion automatically. Rule of thumb: **if a method changes the struct, use a pointer receiver. If it only reads, a value receiver is fine.**

---

## 8. DevOps example: the shape you'll actually write

```go
type Server struct {
    Name      string
    Reachable bool
    CPUUsage  float64
}

func (s Server) IsHealthy() bool {
    return s.Reachable && s.CPUUsage < 80
}

func (s *Server) MarkDown() {
    s.Reachable = false
}

servers := []Server{
    {Name: "web-01", Reachable: true, CPUUsage: 45.0},
    {Name: "web-02", Reachable: true, CPUUsage: 92.5},
}

for i := range servers {
    if !servers[i].IsHealthy() {
        fmt.Println(servers[i].Name, "needs attention")
    }
}
```

`for i := range servers` is used here instead of `for _, s := range servers`, because `range` normally gives a copy of each struct. To actually read or change the struct that's really inside the slice (especially before calling a pointer-receiver method), index back into the slice with `servers[i]`, not the loop's copy variable.

---

## 9. How engineers debug structs

| Symptom | Usual cause | First check |
|---|---|---|
| Changed a field inside a function, but the original is unchanged | passed the struct by value instead of by pointer | change the function parameter to `*Server` and pass `&variable` |
| `range` loop changes don't stick | `for _, s := range servers` gives a copy of `s` per iteration | use `for i := range servers` and modify `servers[i]` directly |
| Struct literal has wrong values in wrong fields | used a positional literal without field names, and the struct's field order changed | switch to named-field literal syntax |
| Struct prints as `{  false 0}` unexpectedly | forgot to initialize it; this is the zero value, not an error | check you actually assigned a literal or used dot notation to set fields |
| Compiler error "cannot use s (type Server) as type *Server" | mismatched pointer/value between method receiver and how it's called | check whether the method needs a pointer receiver |
