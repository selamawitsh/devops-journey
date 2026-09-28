# Lesson 5 Notes: Arrays and Slices

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why you need a list

Every exercise so far hardcoded server names one at a time. That does not scale.

```text
Fixed, one at a time                    A real list
---------------------                   -----------
serverA := "web-01"                     servers := []string{
serverB := "web-02"                         "web-01", "web-02", "db-01",
serverC := "db-01"                      }
(add a server? add a new variable       (add a server? one line)
 and rewrite your loop)
```

```text
Array   = a shelf with a fixed number of labeled slots, built once, size never changes
Slice   = a shopping list, you can add more lines to it as you go
```

Nearly everywhere you'd think "array" in another language, Go code uses a slice.

---

## 2. Arrays: the fixed shelf

```go
var servers [3]string
servers[0] = "web-01"
servers[1] = "web-02"
servers[2] = "db-01"
```

Or in one line:

```go
servers := [3]string{"web-01", "web-02", "db-01"}
```

```text
 index:   0        1        2
       +--------+--------+--------+
       |"web-01"|"web-02"|"db-01" |
       +--------+--------+--------+
```

The `3` is part of the type. `[3]string` and `[4]string` are different types to Go. This rigidity is why arrays are rarely used directly in real Go code — you almost never know the exact count ahead of time.

---

## 3. Slices: the shopping list

```go
servers := []string{"web-01", "web-02", "db-01"}
```

No number inside `[]` — that is what makes it a slice, not an array.

```text
       +--------+--------+--------+
       |"web-01"|"web-02"|"db-01" |
       +--------+--------+--------+
index:    0        1        2
```

Looks similar to an array visually, but a slice can grow.

### Indexing: zero-based

```go
fmt.Println(servers[0])   // web-01
fmt.Println(servers[2])   // db-01
```

### len(): how many items right now

```go
fmt.Println(len(servers))   // 3
```

Always use `len(servers)` as a loop bound, never a hardcoded number. A hardcoded number goes stale the moment the slice's size changes: it misses new items if the slice grew, or causes an "index out of range" panic if the slice shrank.

### append(): add an item, grow the list

```go
servers = append(servers, "cache-01")
fmt.Println(servers)   // [web-01 web-02 db-01 cache-01]
```

Two things to remember:

1. `append` does not modify the original slice in place. It **returns** a new slice value, which you must capture: `servers = append(servers, ...)`. Writing just `append(servers, ...)` with no reassignment does nothing useful — the result is discarded.
2. Internally, Go may allocate a bigger block of memory and copy everything over to fit the new item. You don't manage this yourself; reassigning is all that's required.

### Looping over a slice

```go
for i, name := range servers {
    fmt.Println(i, name)
}
```

```text
0 web-01
1 web-02
2 db-01
3 cache-01
```

### Slicing a slice: taking a sub-list

```go
firstTwo := servers[0:2]
fmt.Println(firstTwo)   // [web-01 web-02]
```

Read `[0:2]` as "starting at index 0, up to but not including index 2." The end number is exclusive — a common off-by-one trap.

```text
servers[0:2]
   index:   0        1        2         3
         +--------+--------+--------+--------+
         |"web-01"|"web-02"|"db-01" |"cache..|
         +--------+--------+--------+--------+
          \___________________/
              included in firstTwo
```

---

## 4. DevOps example: the shape you'll actually write

```go
servers := []string{"web-01", "web-02", "db-01"}

for _, name := range servers {
    evaluateServer(name, true, 45.0)   // reusing Lesson 4's function
}
```

Adding a fourth server is one line: `servers = append(servers, "cache-01")`. The loop and `evaluateServer` never change. That is the entire point of building with slices instead of separate variables.

---

## 5. How engineers debug slices

| Symptom | Usual cause | First check |
|---|---|---|
| `index out of range` panic | hardcoded loop bound instead of `len(slice)` | replace the number with `len(servers)` |
| `append` doesn't seem to add anything | forgot to reassign: `append(servers, x)` instead of `servers = append(servers, x)` | check the assignment |
| Slice looks empty when you expected data | declared with `var servers []string` (a nil slice) but never appended | print `len(servers)` to confirm |
| Wrong items in a sub-slice | off-by-one on `[start:end]`, forgetting `end` is exclusive | manually count which indices you actually want |
| Two slices seem to affect each other unexpectedly | slicing can share the same underlying array | not a concern yet; becomes relevant once optimizing performance later in the roadmap |
