# Topic Exercise: Authentication

Goal: send an authenticated request using a Bearer token read from an environment variable, and handle the case where it's missing.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis
mkdir authentication
cd authentication
go mod init authentication
```

We'll use `https://httpbin.org/bearer` for this lab — a public test endpoint that specifically checks for a Bearer token and reports back whether it was valid, without needing a real account or API key of your own.

## Step 2: Write the program yourself

Build `main.go` that:

1. Reads an environment variable called `API_TOKEN` using `os.LookupEnv`.
2. If it's missing or empty, prints `API_TOKEN is not set` and returns, without making any request.
3. Otherwise, creates an `http.Client` with a 5-second timeout.
4. Creates a GET request to `https://httpbin.org/bearer`.
5. Sets the `Authorization` header to `"Bearer " + token`.
6. Sends the request, handling both creation and send errors separately.
7. Closes the response body with `defer`.
8. Prints the status code.
9. If the status is `200`, prints `Authenticated successfully`. If it's `401`, prints `Authentication failed`. Otherwise prints `Unexpected status: <code>`.

Do not copy a finished solution. You already have everything needed from the notes:

- `os.LookupEnv` comma-ok check
- everything from the `http-client` topic (client, request, timeout)
- `req.Header.Set("Authorization", "Bearer "+token)`

## Step 3: Run with a token set

```bash
export API_TOKEN="any-test-value-works-here"
go fmt ./...
go run main.go
```

Expected: status `200`, `Authenticated successfully` — `httpbin.org/bearer` accepts any non-empty Bearer token and just echoes back that it received one.

## Step 4: Run without a token set

```bash
unset API_TOKEN
go run main.go
```

Expected: your program prints `API_TOKEN is not set` and exits before making any network request at all. Confirm this by checking that no status code is printed.

## Step 5: Build and verify both paths again

```bash
export API_TOKEN="any-test-value-works-here"
go build
./authentication

unset API_TOKEN
./authentication
```

## Step 6: Break it on purpose, then fix it

Temporarily switch `os.LookupEnv` back to plain `os.Getenv`, and remove the "is not set" check entirely. Run the program with `API_TOKEN` unset and observe: the request still goes out with `Authorization: Bearer ` (empty token), and you get back whatever status the server returns for that, instead of catching the problem locally before any network call. Write down what you observe. Then restore the `LookupEnv` check.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output from Step 3 (token set) and Step 4 (token unset)
4. What you observed in Step 6 (the `Getenv` version going out with an empty token)

## Completion checklist

- [ ] `go.mod` exists in `authentication`
- [ ] `os.LookupEnv` used, not plain `os.Getenv`, for the final version
- [ ] Program exits before any request when the token is missing
- [ ] Program sends a correctly formatted `Authorization: Bearer <token>` header when the token is set
- [ ] Status code handled for 200, 401, and anything else
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and the built binary behave identically in both the set and unset cases
- [ ] I reproduced and understood the empty-token-still-sent problem with plain `Getenv`
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "authentication" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, and that you never committed a real secret, then:

```bash
cd ~/Desktop/devops-journey
git add phase_5_go/go-automation/04-working-with-apis/authentication
git commit -m "feat(go): module 04, authenticated requests with Bearer tokens from env vars"
git push
```
