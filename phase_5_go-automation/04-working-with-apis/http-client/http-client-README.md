# Topic Notes: HTTP Client

Phase 5, Go for DevOps automation. Module 04, Working with APIs.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on labs).

---

## 1. Big picture: what you're actually automating

When you use a food delivery app and tap "show me my orders," your phone doesn't open the restaurant's database directly:

```text
Your app
   |
   | HTTP request
   v
API server
   |
   | talks to database
   v
Database
   |
   v
API server
   |
   | HTTP response
   v
Your app
```

An API is the agreed way two systems talk to each other. In DevOps, you'll do this constantly:

```text
Go program
    |
    v
AWS API
    |
    v
EC2 / S3 / IAM
```

When you use the AWS SDK later in this roadmap, you're really just using APIs through a convenient Go library.

---

## 2. Client and server

```text
Client   -> the thing making the request: a browser, curl, Postman, a Go program, the AWS CLI
Server   -> the thing receiving the request and sending a response
```

```text
Go program
    |
    | GET /servers
    v
DevOps API server
```

The Go program is the client. The API server is the server.

---

## 3. HTTP, in one sentence

HTTP (Hypertext Transfer Protocol) is the protocol clients and servers use to communicate. You've used it every time you opened a URL in a browser, just without thinking about it.

```text
GET https://api.example.com/servers
     |
     v
200 OK
```

---

## 4. The HTTP request: four pieces

```text
REQUEST
 |
 +-- Method
 +-- URL
 +-- Headers
 `-- Body
```

### Method: what you want to do

| Method | Typical purpose |
|---|---|
| GET | Read data |
| POST | Create/send data |
| PUT | Replace/update data |
| PATCH | Partially update data |
| DELETE | Delete data |

```text
GET /servers          -> "give me the servers"
DELETE /servers/42     -> "delete server 42"
```

### URL: where you're sending it

```text
https://api.example.com/servers/42
   |              |          |
protocol    server/domain   resource/path
```

### Headers: metadata about the request

```text
Content-Type: application/json     -> "I'm sending JSON"
Authorization: Bearer abc123       -> "here is my authentication token"
```

### Body: the actual data being sent

```text
POST /servers

Headers:
Content-Type: application/json

Body:
{
    "name": "web-server",
    "environment": "production"
}
```

GET requests typically have no body. POST/PUT/PATCH commonly do.

---

## 5. The HTTP response: three pieces

```text
RESPONSE
 |
 +-- Status code
 +-- Headers
 `-- Body
```

```text
HTTP/1.1 200 OK

Content-Type: application/json

{
    "name": "web-server",
    "status": "running"
}
```

---

## 6. Status codes: know these cold

```text
2xx  -> success
  200 OK              request succeeded
  201 Created          something was successfully created
  204 No Content       succeeded, no response body

4xx  -> client-side problem
  400 Bad Request      the request itself is invalid
  401 Unauthorized     authentication is missing or invalid
  403 Forbidden        understood you, but you don't have permission
  404 Not Found        the resource doesn't exist

5xx  -> server-side problem
  500 Internal Server Error    something went wrong on the server
  503 Service Unavailable      temporarily unavailable
```

5xx codes matter a lot once you reach retry logic — a 503 is often worth retrying, a 404 almost never is.

---

## 7. net/http: the simple way

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	response, err := http.Get("https://example.com")
	if err != nil {
		fmt.Println("Request failed:", err)
		return
	}
	defer response.Body.Close()

	fmt.Println("Status:", response.Status)
}
```

`http.Get` returns `(response, error)` — the same `(result, error)` shape from Lesson 8. `response` holds the server's reply; `err` holds a problem with making the request itself (DNS failure, network failure, invalid URL), not a bad HTTP status.

### Why defer response.Body.Close()

```text
Open resource
     |
Use resource
     |
Close resource
```

`defer response.Body.Close()` schedules the cleanup immediately, so it runs when the function ends no matter how it exits — same habit as `defer file.Close()` from Module 03.

### Reading the response body

```go
import "io"

body, err := io.ReadAll(response.Body)
if err != nil {
    fmt.Println("Failed to read response:", err)
    return
}
fmt.Println(string(body))
```

`io.ReadAll` returns `[]byte`, not `string` — same reasoning as `os.ReadFile`: Go doesn't assume the body is text.

### Two different kinds of failure

```text
err != nil                -> the REQUEST failed (network, DNS, connection)
err == nil, StatusCode 404 -> the request SUCCEEDED; the server responded with a bad status
```

The server can respond with `404`, `500`, or `503` without Go treating the HTTP exchange itself as an error. Never assume `err == nil` means "the API call worked" — you still have to check `response.StatusCode` separately.

---

## 8. http.Client: the proper way

`http.Get` hides a lot of control you'll need for real tools: custom headers, timeouts, authentication, non-GET methods.

```text
Create client
     |
Create request
     |
Send request using client
     |
Receive response
```

```go
client := &http.Client{}

request, err := http.NewRequest("GET", "https://example.com", nil)
if err != nil {
    fmt.Println("Failed to create request:", err)
    return
}

response, err := client.Do(request)
if err != nil {
    fmt.Println("Request failed:", err)
    return
}
defer response.Body.Close()
```

### http.NewRequest's three arguments

```text
http.NewRequest("GET", "https://example.com", nil)
                 |            |                |
              method         URL            body (nil, GET doesn't need one)
```

### Two separate places errors can happen now

```text
Create request
      |
   ERROR?
    /   \
  yes    no
   |      |
 stop   Send request
           |
        ERROR?
         /   \
       yes    no
        |      |
      stop   Response
```

Creating the request can fail (bad method, malformed URL). Sending it can fail separately (network issue). Both get their own `if err != nil` check.

### Request vs response

```text
request   -> what YOU send: method, URL, headers, body
response  -> what the SERVER sends back: status code, headers, body
```

### Adding headers

```go
request.Header.Set("Accept", "application/json")
```

```text
request
   |
   `-- Header
         |
         +-- Accept
         `-- Authorization   (covered in the authentication topic)
```

### Timeouts

```go
import "time"

client := &http.Client{
	Timeout: 5 * time.Second,
}
```

```text
Request
   |
 wait...
   |
 5 seconds
   |
 TIMEOUT
```

Without a timeout, a health checker that calls 50 servers can hang on one unresponsive server and never reach the other 49:

```text
Without timeout:                     With timeout:
Server 1 -> response                 Server 1 -> healthy
Server 2 -> response                 Server 2 -> healthy
Server 3 -> hangs forever            Server 3 -> timeout, move on
Server 4 -> never reached            Server 4 -> healthy
```

### Checking status with named constants

```go
if response.StatusCode != http.StatusOK {
    fmt.Println("Request was not successful")
    return
}
```

`http.StatusOK`, `http.StatusNotFound`, `http.StatusInternalServerError`, and similar constants exist for the common codes — `http.StatusOK` makes intent clearer than a bare `200`.

### err != nil vs StatusCode != 200: still two different checks

```go
response, err := client.Do(request)
// err != nil             -> the HTTP operation itself failed
// response.StatusCode     -> what the server decided to respond with, even on success
```

A `500` response with `err == nil` is completely possible — the server responded, it just responded badly.

---

## 9. The professional mental model

```text
                CREATE REQUEST
                      |
                  ERROR?
                 /      \
               YES       NO
                |         |
              STOP       SEND
                           |
                        ERROR?
                       /      \
                     YES       NO
                      |         |
                    STOP     RESPONSE
                                |
                          CHECK STATUS
                                |
                           READ BODY
                                |
                          PROCESS DATA
```

This exact pattern repeats constantly across DevOps automation: AWS calls, GitHub calls, Kubernetes calls, internal health checks.

---

## 10. How engineers debug HTTP clients

| Symptom | Usual cause | First check |
|---|---|---|
| Program hangs indefinitely on one request | no `Timeout` set on the client | add `Timeout: 5 * time.Second` (or similar) to `http.Client{}` |
| Code treats a 404/500 as if the call succeeded | checked only `err != nil`, never `response.StatusCode` | add an explicit status check after a nil error |
| `request.Header.Set(...)` seems to have no effect | header was set on the wrong variable, or set after the request was already sent | set headers on the `*http.Request` before calling `client.Do` |
| Forgot to close the response body | missing `defer response.Body.Close()` | add it immediately after a successful request, every time |
| `nil` body panics when reading | tried to read `response.Body` without checking `err` first | always check `err != nil` before touching `response` |
| Works for one request, breaks under load | reused a single `http.Client{}` incorrectly, or created a new one per request unnecessarily | `http.Client` is safe to reuse across many requests — create it once |
