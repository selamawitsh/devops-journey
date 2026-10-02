# Topic Notes: Authentication

Phase 5, Go for DevOps automation. Module 04, Working with APIs.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on lab).

---

## 1. Big picture: how does the API know it's you?

Everything so far in this module worked against public, open APIs. Real DevOps work almost never does — AWS, GitHub, internal services all require you to prove who's asking before they'll answer.

```text
HTTP
 |
Request
 |
Response
 |
JSON
 |
Go struct
```

Authentication answers one question: **"who are you?"** Without a correct answer, the server responds:

```text
401 Unauthorized
```

---

## 2. API keys

A common pattern: the server expects a specific header carrying a secret value.

```go
req.Header.Set("X-API-Key", "abc123")
```

```text
GET /servers
Host: example.com
X-API-Key: abc123
```

The server checks the key before returning data.

---

## 3. The rule you must never break: no secrets in code

```go
req.Header.Set("X-API-Key", "abc123")   // NEVER do this with a real key
```

If `abc123` is a real secret and this line gets committed, the key is now sitting in your Git history — forever, even if you later delete the line, unless you rewrite history entirely, which is its own painful process. Instead, pull the secret from the environment at runtime:

```bash
export API_KEY="your-secret-key"
```

```go
apiKey := os.Getenv("API_KEY")
req.Header.Set("X-API-Key", apiKey)
```

```text
Environment variable
        |
      token
        |
Authorization/API-Key header
        |
       API
```

---

## 4. Bearer tokens

Another very common pattern, especially for OAuth-style APIs:

```http
Authorization: Bearer YOUR_TOKEN
```

```go
token := os.Getenv("API_TOKEN")
req.Header.Set("Authorization", "Bearer "+token)
```

The word `Bearer` is literal — it's part of the header value, not a placeholder, and is followed by a space and then the actual token.

---

## 5. Complete example

```go
package main

import (
    "fmt"
    "net/http"
    "os"
)

func main() {
    token := os.Getenv("API_TOKEN")

    req, err := http.NewRequest("GET", "https://example.com/api/servers", nil)
    if err != nil {
        fmt.Println("Failed to create request:", err)
        return
    }

    req.Header.Set("Authorization", "Bearer "+token)

    client := &http.Client{}
    res, err := client.Do(req)
    if err != nil {
        fmt.Println("Request failed:", err)
        return
    }
    defer res.Body.Close()

    fmt.Println("Status:", res.StatusCode)
}
```

The entire new idea is one line: `req.Header.Set("Authorization", "Bearer "+token)`. Everything around it is the `http-client` topic you already know.

---

## 6. Why environment variables specifically

```go
token := "my-secret-token"   // then committed to Git — now permanently exposed
```

vs.

```bash
export API_TOKEN="my-secret-token"
```

```go
token := os.Getenv("API_TOKEN")
```

The secret stays outside the source code entirely — it's never typed into a `.go` file, never staged, never committed. This matters constantly in DevOps work: AWS credentials, API tokens, database passwords, SSH-related secrets, CI/CD secrets all follow this same pattern.

### The silent-empty-string trap, again

`os.Getenv` has the same gap seen with map lookups (Lesson 6) and `os.Getenv` from Module 03: if the variable isn't set, you get `""` with no error.

```go
token := os.Getenv("API_TOKEN")
// if unset, token == "", and the request goes out with "Authorization: Bearer "
```

A request sent with an empty token isn't the same as no request at all — it goes out, gets rejected with a `401`, and if you're not checking for that, you'll spend time debugging the wrong thing. The safer check:

```go
token, exists := os.LookupEnv("API_TOKEN")
if !exists || token == "" {
    fmt.Println("API_TOKEN is not set")
    return
}
```

Catching this before the request goes out at all is clearer than reading a `401` and having to guess why.

---

## 7. Where secrets should actually live

```text
Never:        hardcoded directly in a .go file
Never:        committed in a config file tracked by Git
Better:        an environment variable set in the shell or CI/CD pipeline
Also common:    a secrets manager (AWS Secrets Manager, HashiCorp Vault) — out of scope for now, but this is the direction real production systems go
```

For this module, environment variables are the right tool. `.gitignore` is also part of this discipline: any local file holding a real secret for testing (like a `.env` file) should be listed in `.gitignore` so it's never accidentally staged.

---

## 8. How engineers debug authentication

| Symptom | Usual cause | First check |
|---|---|---|
| `401 Unauthorized` on every request | token/key missing, expired, or malformed | print the token's length (never the token itself) to confirm it's actually set |
| Request works for one teammate, not another | the environment variable isn't set in their shell, or is set to an old value | confirm with `echo $API_TOKEN` (or the equivalent) on their machine |
| Header looks right but still fails | missing the literal word `Bearer` and the space before the token, or a typo in the header name | print the exact header value right before sending the request |
| A secret ended up in Git history | hardcoded directly instead of read from the environment | rotate the secret immediately; a `git rm` alone does not remove it from history |
| `os.Getenv` returns `""` with no error, request still goes out | didn't check for the empty/unset case before using the value | switch to `os.LookupEnv` and check before making the request |
