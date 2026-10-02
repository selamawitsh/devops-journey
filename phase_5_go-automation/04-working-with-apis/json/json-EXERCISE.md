# Topic Exercise: JSON

Two labs, done in order: `01-unmarshal`, then `02-api-decoder`.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Lab 1: 01-unmarshal

Goal: decode a hardcoded JSON string into a Go struct, then fix the mapping with JSON tags when the keys don't match.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis
mkdir -p json/01-unmarshal
cd json/01-unmarshal
go mod init unmarshal
```

### Step 2: Write the program yourself

Build `main.go` that:

1. Defines this JSON as a `[]byte`:
   ```json
   {
     "name": "web-01",
     "status": "running",
     "cpu": 45.7
   }
   ```
2. Defines a `Server` struct with `Name`, `Status`, `CPU`.
3. Declares a `Server` variable.
4. Unmarshals the JSON into it with `json.Unmarshal`.
5. Handles the error.
6. Prints:
   ```text
   Server: web-01
   Status: running
   CPU Usage: 45.7
   ```

Do not copy a finished solution. You already have everything needed from the notes:

- `encoding/json` import
- struct definition
- `json.Unmarshal(data, &server)`

### Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
./unmarshal
```

### Step 4: Bonus — JSON tags

Change the JSON to:

```json
{
  "server_name": "web-01",
  "server_status": "running",
  "cpu_usage": 45.7
}
```

Add JSON tags to your struct so the same output still prints correctly:

```text
server_name   -> Name
server_status -> Status
cpu_usage     -> CPU
```

### Step 5: Break it on purpose, then fix it

Temporarily remove the JSON tags while keeping the renamed JSON keys. Run the program and observe which fields come back empty or zero, with no error raised. Write down what you observe, then restore the tags.

---

## Lab 2: 02-api-decoder

Goal: call a real public API and decode the response directly from the HTTP body, combining everything from the `http-client` topic with this one.

### Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis
mkdir -p json/02-api-decoder
cd json/02-api-decoder
go mod init apidecoder
```

### Step 2: Write the program yourself

Build `main.go` that:

1. Defines a `Todo` struct with `UserID` (int), `ID` (int), `Title` (string), `Completed` (bool).
2. Creates an `http.Client` with a 5-second timeout.
3. Creates a GET request to `https://jsonplaceholder.typicode.com/todos/1`.
4. Sends it and handles both the request-creation and request-sending errors separately.
5. Closes the response body with `defer`.
6. Checks the status code is `200`, printing `Unexpected status: <code>` and returning if not.
7. Decodes the response directly into a `Todo` using `json.NewDecoder(res.Body).Decode(&todo)`.
8. Handles the decode error.
9. Prints `User ID`, `ID`, `Title`, `Completed`.

Do not copy a finished solution. You already have everything needed from the notes:

- everything from the `http-client` topic (client, request, timeout, status check)
- `json.NewDecoder(res.Body).Decode(&todo)`

### Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
./apidecoder
```

Expected output shape:

```text
User ID: 1
ID: 1
Title: delectus aut autem
Completed: false
```

### Step 4: Compare the two decoding approaches

Temporarily rewrite the decode step using the `Unmarshal` approach instead: `io.ReadAll(res.Body)` into a `[]byte`, then `json.Unmarshal(data, &todo)`. Confirm you get identical output. Write one sentence on which approach you'd prefer in real code, and why. Then switch back to the `Decoder` form.

### Step 5: Break it on purpose, then fix it

Temporarily change the URL to a todo ID that doesn't exist, like `/todos/99999999`. Check what status code and body come back, and confirm your status check catches it before attempting to decode. Then change the URL back to `/todos/1`.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. `main.go` for both `01-unmarshal` and `02-api-decoder`
3. Output of both labs' run/build steps, including the JSON-tag bonus
4. What you observed in Lab 1 Step 5 (missing tags), and Lab 2 Step 5 (bad ID)

## Completion checklist

- [ ] `01-unmarshal` decodes correctly with the original JSON
- [ ] `01-unmarshal` still works after renaming JSON keys, using tags
- [ ] `02-api-decoder` successfully calls the real API and decodes the response
- [ ] `02-api-decoder` checks the status code before decoding
- [ ] Both labs' errors are checked and handled, not ignored
- [ ] `go fmt ./...` reports no problems in both
- [ ] I reproduced and understood the missing-tag bug
- [ ] I reproduced and understood the bad-ID response
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis/json/01-unmarshal
echo "unmarshal" > .gitignore

cd ../02-api-decoder
echo "apidecoder" > .gitignore
```

```bash
cd ~/Desktop/devops-journey
git add phase_5_go/go-automation/04-working-with-apis/json
git commit -m "feat(go): module 04, json labs with Unmarshal, tags, and a real API decoder"
git push
```
