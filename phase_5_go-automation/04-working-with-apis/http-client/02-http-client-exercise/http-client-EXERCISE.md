# Topic Exercise: HTTP Client

Two labs, done in order: `01-get-request`, then `02-http-client`.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Lab 1: 01-get-request

Goal: make your first real HTTP request with Go, using the simple `http.Get` shortcut.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis
mkdir -p http-client/01-get-request
cd http-client/01-get-request
go mod init getrequest
```

### Step 2: Write the program yourself

Build `main.go` that:

1. Imports `fmt`, `io`, `net/http`.
2. Makes a GET request to `https://example.com`.
3. Handles the request error.
4. Closes the response body with `defer`.
5. Prints the HTTP status code (not the full status text).
6. Reads the response body with `io.ReadAll`.
7. Handles the body-reading error.
8. Prints the response body.

Do not copy a finished solution. You already have everything needed from the notes:

- `http.Get`
- `(response, error)` checking
- `defer response.Body.Close()`
- `io.ReadAll` and `string(...)`

### Bonus

Print only:

```text
Status code: 200
```

instead of the full `response.Status` text. Look at what field on `response` holds just the number.

### Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
./getrequest
```

---

## Lab 2: 02-http-client

Goal: build a small API health checker using a configured `http.Client`, a timeout, and a custom header.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis
mkdir -p http-client/02-http-client
cd http-client/02-http-client
go mod init httpclient
```

### Step 2: Write the program yourself

Build `main.go` that:

1. Creates an `http.Client` with a 5-second `Timeout`.
2. Creates a GET request to `https://example.com` using `http.NewRequest`.
3. Adds an `Accept: text/html` header to the request.
4. Sends the request with `client.Do`.
5. Handles errors from both creating and sending the request, separately.
6. Closes the response body with `defer`.
7. Prints `Status code: <code>`.
8. If the status isn't `200`, prints `Server returned an unexpected status`.
9. If it is `200`, prints `Server is healthy`.

Do not copy a finished solution. You already have everything needed from the notes:

- `&http.Client{Timeout: ...}`
- `http.NewRequest` and its three arguments
- `request.Header.Set`
- `client.Do`
- checking `response.StatusCode` against `http.StatusOK`

### Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
./httpclient
```

### Step 4: Break it on purpose, then fix it

Temporarily point the request at a URL guaranteed to fail or time out, such as `https://httpstat.us/503?sleep=10000` with your timeout still set to 5 seconds. Run it and copy the exact error. Confirm your program doesn't hang for the full 10 seconds — it should stop at 5. Then point the URL back to `https://example.com`.

### Step 5: Prove err and StatusCode are different checks

Temporarily point the request at `https://httpstat.us/404`. Run it and confirm: `err` is `nil` (the request succeeded), but your status check correctly catches the 404 and prints "Server returned an unexpected status." Write down what would have happened if your code only checked `err != nil`. Then point the URL back to `https://example.com`.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. `main.go` for both `01-get-request` and `02-http-client`
3. Output of both labs' run/build steps
4. The timeout behavior from Step 4, and the 404-vs-err behavior from Step 5

## Completion checklist

- [ ] `01-get-request` prints status code and body correctly
- [ ] `02-http-client` uses a configured client with a timeout and a header
- [ ] Both labs check errors from every fallible call separately
- [ ] Both labs use `defer response.Body.Close()`
- [ ] `go fmt ./...` reports no problems in both
- [ ] I reproduced and understood the timeout cutting off a slow request
- [ ] I reproduced and understood `err == nil` with a non-200 status
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis/http-client/01-get-request
echo "getrequest" > .gitignore

cd ../02-http-client
echo "httpclient" > .gitignore
```

```bash
cd ~/Desktop/devops-journey
git add phase_5_go/go-automation/04-working-with-apis/http-client
git commit -m "feat(go): module 04, http-client labs with http.Get and http.Client"
git push
```
