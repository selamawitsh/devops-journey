# Topic Exercise: Retry and Backoff

Goal: retry a failing request with exponential backoff, cap the attempts, and only retry errors actually worth retrying.

Read `README.md` first. Revise with `RECALL.md` afterward.

---

## Step 1: Set up

```bash
cd ~/Desktop/devops-journey/phase_5_go/go-automation/04-working-with-apis
mkdir retry-backoff
cd retry-backoff
go mod init retrybackoff
```

We'll use `https://httpstat.us/503` — a public test endpoint that always returns a 503, perfect for proving retry logic without needing a real flaky server.

## Step 2: Write the program yourself

Build `main.go` that:

1. Creates an `http.Client` with a 5-second timeout.
2. Sets `maxRetries := 5`.
3. Loops from `attempt := 1` to `maxRetries`, making a GET request to `https://httpstat.us/503` each time.
4. On a request error (`err != nil`), prints the error and `continue`s to the next attempt.
5. On a successful request, checks the status code:
   - If `200`, prints `Success on attempt <n>` and `break`s out of the loop.
   - If `>= 500`, prints `Attempt <n> failed with status <code>, retrying`, closes the body, and waits using exponential backoff before the next attempt.
   - If it's a `4xx` status, prints `Client error <code>, not retrying` and returns immediately, without waiting or looping further.
6. After the loop, if no attempt succeeded, prints `All <maxRetries> attempts failed`.

Do not copy a finished solution. You already have everything needed from the notes:

- classic `for` loop with `continue` and `break`
- `time.Sleep` with a doubling delay
- the `>= 500` vs `>= 400` retryable check

Target output shape (your exact wording can vary, and this specific endpoint always fails):

```text
Attempt 1 failed with status 503, retrying
Attempt 2 failed with status 503, retrying
Attempt 3 failed with status 503, retrying
Attempt 4 failed with status 503, retrying
Attempt 5 failed with status 503, retrying
All 5 attempts failed
```

## Step 3: Run and build

```bash
go fmt ./...
go run main.go
go build
./retrybackoff
```

Time the run roughly with your terminal — with delays of 1, 2, 4, 8 seconds between 5 attempts, it should take noticeably longer each time, not run instantly.

## Step 4: Prove backoff is actually increasing

Print the delay value right before each `time.Sleep` call (e.g. `fmt.Println("waiting", delay)`). Run the program and confirm the printed delays roughly double each time: 1, 2, 4, 8. Leave these print statements in for the submission — they're useful proof, not something to delete.

## Step 5: Prove a 4xx stops immediately, no retry

Temporarily change the URL to `https://httpstat.us/404`. Run the program and confirm it prints `Client error 404, not retrying` once and exits immediately — no retries, no backoff delay. Then change the URL to `https://httpstat.us/200` and confirm it prints `Success on attempt 1` right away. Finally, change it back to `https://httpstat.us/503` for your final submission.

---

## What to send for review

1. Your answers to the recall questions in `RECALL.md`
2. Your final `main.go`
3. Output of the full run against `/503` (all 5 attempts failing, with backoff delays printed)
4. Output against `/404` (immediate stop, no retry)
5. Output against `/200` (immediate success)

## Completion checklist

- [ ] `go.mod` exists in `retry-backoff`
- [ ] Retry loop has a hard maximum (`maxRetries`), not an infinite loop
- [ ] Backoff delay actually increases between attempts (printed and confirmed)
- [ ] A `5xx` status triggers a retry; a `4xx` status returns immediately without retrying
- [ ] A successful `200` breaks out of the loop immediately
- [ ] `go fmt ./...` reports no problems
- [ ] `go run main.go` and the built binary behave identically
- [ ] I reproduced and understood the 4xx-stops-immediately behavior
- [ ] I confirmed the backoff delay sequence with printed output
- [ ] I answered all recall questions without looking at the notes
- [ ] My work was reviewed

## Commit (only after review passes)

```bash
echo "retrybackoff" > .gitignore
git status
```

Confirm the compiled binary does not appear as untracked, then:

```bash
cd ~/Desktop/devops-journey
git add phase_5_go/go-automation/04-working-with-apis/retry-backoff
git commit -m "feat(go): module 04, retry logic with exponential backoff and 4xx short-circuit"
git push
```

---

## Module 04 complete

Once all four topics (`http-client`, `json`, `authentication`, `retry-backoff`) are reviewed and committed, update `04-working-with-apis/README.md`'s progress checklist, and we move on to `05-aws-sdk` — where every concept from this module (client, JSON, auth, retry) gets used directly against real AWS APIs.
