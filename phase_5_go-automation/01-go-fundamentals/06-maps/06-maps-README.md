# Lesson 6 Notes: Maps

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why you need key-value lookups

A slice gives you an ordered list, found **by position**: `servers[0]`, `servers[1]`. What if you want to find something **by name** instead — "what's the status of `db-01`?" — without looping through the whole list every time?

```text
Slice (find by position)              Map (find by key)
-------------------------             -----------------------
servers[0] = "web-01"                 status["web-01"]  = "healthy"
servers[1] = "web-02"                 status["web-02"]  = "warning"
servers[2] = "db-01"                  status["db-01"]   = "down"

"what's at position 2?"               "what's the status of db-01?"
-> db-01                              -> down (direct lookup, no loop)
```

A map is like a **filing cabinet with labeled folders**. You don't search drawer by drawer — you go straight to the folder labeled `"db-01"` and pull it out.

```text
+------------------------------------------+
|              FILING CABINET               |
|                                            |
|  [web-01]  ->  "healthy"                  |
|  [web-02]  ->  "warning"                  |
|  [db-01]   ->  "down"                     |
+------------------------------------------+
```

This is the shape of real DevOps data: server name to status, container ID to memory usage, hostname to IP address. Anywhere you think "look this up by name," you want a map.

---

## 2. Declaring a map

### Map literal (values known up front)

```go
status := map[string]string{
    "web-01": "healthy",
    "web-02": "warning",
    "db-01":  "down",
}
```

Read `map[string]string` as: keys are strings, values are strings.

```text
map[string]string
     |        |
    key      value
    type     type
```

### make() (start empty, fill it in later)

```go
status := make(map[string]string)
status["web-01"] = "healthy"
status["web-02"] = "warning"
```

`make` builds an empty, usable map. This matters — see the nil map warning below.

---

## 3. Reading and writing values

```go
fmt.Println(status["db-01"])   // down
status["cache-01"] = "healthy" // add a new key
status["db-01"] = "healthy"    // overwrite an existing key
```

```text
BEFORE                        AFTER status["db-01"] = "healthy"
[web-01]  -> "healthy"        [web-01]  -> "healthy"
[web-02]  -> "warning"        [web-02]  -> "warning"
[db-01]   -> "down"           [db-01]   -> "healthy"   <- overwritten
```

---

## 4. The critical gotcha: does the key even exist?

```go
value := status["gpu-server"]
fmt.Println(value)   // prints "" (empty string), NOT an error
```

Go does not crash or warn you if a key is missing. It silently gives you the **zero value** for that type (`""` for `string`, `0` for `int`, `false` for `bool`). This is dangerous: you cannot tell the difference between "this server's status really is an empty string" and "this server was never in the map at all."

The fix is the **comma-ok idiom**:

```go
value, exists := status["gpu-server"]

if exists {
    fmt.Println("Status:", value)
} else {
    fmt.Println("gpu-server not found")
}
```

```text
value, exists := status["gpu-server"]
                          |
                  +-------+-------+
                  |               |
              found?          found?
               YES              NO
                |                |
          value = real       value = ""
          exists = true      exists = false
```

Use the comma-ok form whenever you're not certain a key is there. In real DevOps code, this is exactly how you'd check "do we have monitoring data for this server yet?" before using it.

---

## 5. Deleting a key

```go
delete(status, "db-01")
```

```text
BEFORE                        AFTER delete(status, "db-01")
[web-01]  -> "healthy"        [web-01]  -> "healthy"
[web-02]  -> "warning"        [web-02]  -> "warning"
[db-01]   -> "down"           (gone)
```

Deleting a key that doesn't exist is safe — a no-op, no error.

---

## 6. Looping over a map

```go
for name, s := range status {
    fmt.Println(name, "->", s)
}
```

**Map iteration order is not guaranteed.** It can come out in a different order every time you run the program. This is a deliberate Go design decision, so nobody accidentally relies on an order that was never promised. If you need a specific order, sort the keys yourself (a topic for later, once sorting is covered).

---

## 7. len() on a map

```go
fmt.Println(len(status))   // number of key-value pairs
```

Same `len()` as slices, but here it counts entries — how many key-value pairs the map holds — not the length of any individual key.

---

## 8. DevOps example: the shape you'll actually write

```go
serverStatus := map[string]string{
    "web-01": "healthy",
    "web-02": "warning",
    "db-01":  "down",
}

for name, s := range serverStatus {
    if s == "down" {
        fmt.Println("ALERT:", name, "is down")
    }
}

if s, ok := serverStatus["cache-01"]; ok {
    fmt.Println("cache-01 status:", s)
} else {
    fmt.Println("cache-01 not being monitored yet")
}
```

A very common real pattern: loop through a map to find problems, and use comma-ok to safely check for something that might not be there yet.

---

## 9. How engineers debug maps

| Symptom | Usual cause | First check |
|---|---|---|
| `panic: assignment to entry in nil map` | wrote to a map declared with `var m map[string]string` but never `make`'d it or used a literal | declare with `make(map[K]V)` or a map literal, never bare `var` if you plan to write to it |
| Got `""` or `0` back but expected "not found" | forgot the comma-ok check | rewrite as `value, ok := m[key]` and check `ok` |
| Output order changes between runs | map iteration order is never guaranteed | don't rely on order; sort keys first if order matters |
| Value never seems to update | overwrote the wrong key, or a variable used as a key changed unexpectedly | print the exact key you're using right before the write |
