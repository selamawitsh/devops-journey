# Topic Notes: JSON

Phase 5, Go for DevOps automation. Module 04, Working with APIs.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on labs).

---

## 1. Big picture: from API response to usable Go data

```text
API response
    |
    v
  JSON
    |
    v
Go data
    |
    v
 struct
    |
    v
use it in your program
```

This topic is what makes an HTTP response actually useful, instead of just a blob of text you printed in the last topic.

---

## 2. What JSON is

JSON stands for JavaScript Object Notation, but it's not JavaScript-only — it's a plain-text data format almost every language and API uses.

```json
{
  "name": "web-01",
  "status": "running",
  "cpu": 32.5
}
```

Human-readable, machine-parseable, and that's why APIs love it.

---

## 3. JSON objects: key-value pairs

```json
{
  "name": "web-01",
  "status": "running"
}
```

```text
name   -> web-01
status -> running
```

This is the same key-value idea as a Go map from Lesson 6:

```go
server := map[string]string{
    "name":   "web-01",
    "status": "running",
}
```

Not the same thing, but the same underlying concept.

---

## 4. JSON data types and their Go equivalents

```text
JSON type    Example                          Go equivalent
---------    ------------------------------   -------------
String        "name": "web-01"                 string
Number        "cpu": 32.5                       float64
Boolean        "healthy": true                   bool
Null           "ip": null                        no value
Array          "ports": [80, 443, 8080]          []int (a slice)
Object          "server": { "name": "web-01" }    a nested struct
```

### Arrays of objects

```json
[
  { "name": "web-01", "status": "running" },
  { "name": "web-02", "status": "stopped" }
]
```

```text
[
    Server 1,
    Server 2
]
```

In Go, this becomes `[]Server` — your Lesson 5 slices and Lesson 7 structs combined.

---

## 5. JSON to Go struct, and the encoding/json package

```go
type Server struct {
	Name   string
	Status string
	CPU    float64
}
```

```go
import "encoding/json"
```

Two directions you'll use constantly:

```text
JSON -> Go   is called Unmarshaling (decoding)
Go -> JSON   is called Marshaling (encoding)
```

---

## 6. json.Unmarshal

```go
data := []byte(`{
    "name": "web-01",
    "status": "running",
    "cpu": 32.5
}`)

type Server struct {
	Name   string
	Status string
	CPU    float64
}

var server Server
err := json.Unmarshal(data, &server)
if err != nil {
    fmt.Println("Failed to decode JSON:", err)
    return
}

fmt.Println(server.Name)   // web-01
fmt.Println(server.Status) // running
fmt.Println(server.CPU)    // 32.5
```

```text
JSON
 |
 v  json.Unmarshal
 |
Server struct
```

### Why &server, not server

```go
var server Server          // a struct value, all zero values
json.Unmarshal(data, &server)
```

`json.Unmarshal` needs to **modify** `server` to fill it with the decoded data. Passing `&server` gives it the address, exactly the same pointer reasoning from Lesson 7's `MarkDown()` method — a function (or in this case, `Unmarshal`) can only change the original if it has a pointer to it.

```text
before:  server { Name: "", Status: "", CPU: 0 }
             |
   json.Unmarshal(data, &server)
             |
after:   server { Name: "web-01", Status: "running", CPU: 32.5 }
```

---

## 7. How field matching works, and JSON tags

Go can loosely match JSON keys to struct field names automatically, but real APIs often use names that don't match your preferred Go naming:

```json
{
  "server_name": "web-01",
  "server_status": "running"
}
```

```go
type Server struct {
	Name   string
	Status string
}
```

Go has no way to know `server_name` means `Name`. The fix is a JSON tag:

```go
type Server struct {
	Name   string `json:"server_name"`
	Status string `json:"server_status"`
}
```

```text
JSON key               Go field
---------               --------
server_name     ->      Name
server_status   ->      Status
```

This is extremely common in real Go API code, since it lets your struct stay clean and idiomatic (`ID`, `State`) while the API's actual field names (`instance_id`, `instance_state`) are documented right there in the tag:

```go
type Instance struct {
	ID    string `json:"instance_id"`
	State string `json:"instance_state"`
}
```

---

## 8. From a real HTTP response

```text
HTTP response
     |
res.Body
     |
io.ReadAll()
     |
[]byte containing JSON
     |
json.Unmarshal()
     |
Go struct
```

```go
body, err := io.ReadAll(res.Body)
json.Unmarshal(body, &server)
```

---

## 9. The shortcut: json.Decoder

Instead of reading the whole body into `[]byte` first, you can decode directly from the response body stream:

```go
decoder := json.NewDecoder(res.Body)
err := decoder.Decode(&server)
```

Or, as you'll see constantly in real code, chained into one line:

```go
err := json.NewDecoder(res.Body).Decode(&server)
```

```text
res.Body
   |
json.NewDecoder()
   |
Decode()
   |
Go struct
```

### Unmarshal vs Decoder: the mental model

```text
Unmarshal   -> you already have the JSON in memory as []byte
Decoder     -> you have a stream, like res.Body, and want to decode directly from it
```

For HTTP API clients, `Decoder` is usually the more convenient one, since it skips the intermediate `io.ReadAll` step entirely.

---

## 10. A real example: calling a public API

```text
https://jsonplaceholder.typicode.com/todos/1
```

returns:

```json
{
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
}
```

```go
type Todo struct {
    UserID    int
    ID        int
    Title     string
    Completed bool
}

client := &http.Client{Timeout: 5 * time.Second}

req, err := http.NewRequest("GET", "https://jsonplaceholder.typicode.com/todos/1", nil)
if err != nil {
    fmt.Println("Failed to create request:", err)
    return
}

res, err := client.Do(req)
if err != nil {
    fmt.Println("Request failed:", err)
    return
}
defer res.Body.Close()

if res.StatusCode != http.StatusOK {
    fmt.Println("Unexpected status:", res.StatusCode)
    return
}

var todo Todo
if err := json.NewDecoder(res.Body).Decode(&todo); err != nil {
    fmt.Println("Failed to decode JSON:", err)
    return
}

fmt.Println("User ID:", todo.UserID)
fmt.Println("Title:", todo.Title)
fmt.Println("Completed:", todo.Completed)
```

This combines every HTTP client concept from the last topic with everything from this one: client with timeout, request creation, status check, then decode straight from `res.Body`.

---

## 11. How engineers debug JSON handling

| Symptom | Usual cause | First check |
|---|---|---|
| All struct fields stay zero after `Unmarshal` | passed `server` instead of `&server` | add the `&`, Unmarshal needs the address to modify the struct |
| Some fields populate, others stay zero | JSON key names don't match Go field names, and no JSON tags were added | add `json:"actual_key_name"` tags for the mismatched fields |
| `invalid character ... looking for beginning of value` | the input wasn't valid JSON (empty body, HTML error page, truncated response) | print the raw body before decoding to see what was actually returned |
| Fields are lowercase/unexported and never get filled | struct field isn't capitalized | capitalize the field name; `encoding/json` can't see unexported fields at all |
| Numbers decode but look wrong (e.g. `32.5` shows as `32`) | used `int` for a field that's actually a JSON float | match the Go type to the JSON type: `float64` for decimals |
| Used `Unmarshal` but also already read the body with the decoder, or vice versa | mixed the two approaches on the same body | pick one: `io.ReadAll` + `Unmarshal`, or `json.NewDecoder(...).Decode`, not both |
