# Lesson 2 Notes: Variables and Basic Data Types

Phase 5, Go for DevOps automation. Module 01, Go fundamentals.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on task).

---

## 1. Big picture: why a DevOps tool needs variables

You are building a server health checker. The program needs to remember information about a server:

```text
Server name     ->  web-server-01
IP address      ->  10.0.1.20
Port            ->  22
Status          ->  reachable
CPU usage       ->  72.5
```

A variable is a labeled box that holds one of these values:

```text
+--------------------------+
| serverName               |
|                          |
| "web-server-01"          |
+--------------------------+

+--------------------------+
| port                     |
|                          |
| 22                       |
+--------------------------+

+--------------------------+
| reachable                |
|                          |
| true                     |
+--------------------------+
```

The program then uses those boxes:

```text
serverName -> "web-server-01"
port       -> 22
reachable  -> true
```

Variables are the foundation for everything built later: structs, server objects, automation tools.

---

## 2. What is a variable?

A named place where your program stores a value.

```go
var name string = "Selamawit"
```

```text
name
  |
  v
"Selamawit"
```

```go
fmt.Println(name)   // prints: Selamawit
```

---

## 3. Go is strongly typed

Every variable has a name, a value, and a type. Go enforces the type.

```text
Variable
   |
   +-- name
   +-- value
   `-- type
```

Example:

```text
serverName
   |
   +-- type: string
   `-- value: "web-01"
```

```go
var serverName string = "web-01"   // string
var port int = 22                  // int
var reachable bool = true          // bool
```

---

## 4. The basic data types

### string: text

```go
var serverName string = "web-01"
```

Examples: `"hello"`, `"web-server"`, `"10.0.1.20"`, `"running"`.

Note: an IP address is stored as a string at this stage. It is just text to Go here, not a special network type.

### int: whole numbers

```go
var port int = 22
```

Examples: `1`, `10`, `22`, `80`, `443`, `100`.

### float64: numbers with decimals

```go
var cpuUsage float64 = 72.5
```

Examples: `72.5`, `98.2`, `0.5`, `3.14`.

### bool: true or false only

```go
var reachable bool = true
```

DevOps use: a health check reduces to one bool: `true` (reachable) or `false` (not reachable).

---

## 5. Two ways to create variables

### Method 1: explicit declaration

```go
var serverName string = "web-01"
```

You tell Go the name and the type directly.

### Method 2: short declaration

Inside a function only:

```go
serverName := "web-01"
```

Go infers the type from the value:

```text
"web-01"  ->  string
22        ->  int
true      ->  bool
```

`:=` is what you will see in almost all everyday Go code.

---

## 6. Variables can change

```go
status := "starting"
status = "running"
fmt.Println(status)   // running
```

```text
status
  |
  v
"starting"
  |
  | (reassigned, no ":=" the second time)
  v
"running"
```

The value changes. The type does not.

---

## 7. One important rule: type stays fixed

```go
port := 22
port = "ssh"   // compile error
```

`port` was created as `int` the first time it was assigned. You cannot later put a `string` into it. This is what strong typing enforces, and it is the same protection that stops you from silently passing the wrong kind of value to an AWS API call in later lessons.

---

## 8. Declare with `:=` vs reassign with `=`

```text
:=    used ONCE, when the variable is created (declare + assign)
=     used every time AFTER that, to change the value
```

```go
port := 22     // declare
port = 2222    // reassign, same type
```

Writing `port := 2222` again in the same scope is a compile error: "no new variables on left side of :=".

---

## 9. DevOps example

```go
serverName := "web-01"
ipAddress := "10.0.1.20"
port := 22
cpuUsage := 72.5
reachable := true

fmt.Println(serverName)
fmt.Println(ipAddress)
fmt.Println(port)
fmt.Println(cpuUsage)
fmt.Println(reachable)
```

Output:

```text
web-01
10.0.1.20
22
72.5
true
```

This is the first step from raw server information into a real automation tool.

---

## 10. Visual mental model

```text
                  GO PROGRAM
                      |
              +-------+-------+
              |   VARIABLES   |
              +-------+-------+
                      |
       +--------------+--------------+
       v              v              v
   serverName       port         reachable
       |              |              |
       v              v              v
   "web-01"           22            true
       |              |              |
    string            int           bool
```

Where this leads:

```text
variables
   |
   v
structs
   |
   v
server objects
   |
   v
automation tools
```
