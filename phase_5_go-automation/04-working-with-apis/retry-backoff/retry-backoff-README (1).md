# Topic Notes: Retry and Backoff

Phase 5, Go for DevOps automation. Module 04, Working with APIs.

Related files: `RECALL.md` (revision questions) and `EXERCISE.md` (hands-on lab).

---

## 1. Big picture: should your program give up immediately?

```text
Go program -> API
            |
        503 Service Unavailable
```

Should the program immediately give up? Not necessarily — the server might be temporarily busy, deploying a new version, or briefly overloaded. This is a normal, expected part of calling real APIs over an unreliable network, not a bug in your code.

```text
Attempt 1 -> 503 (fail)
     |
  wait 1 second
     |
Attempt 2 -> 503 (fail)
     |
  wait 2 seconds
     |
Attempt 3 -> 200 (success)
```

This is retry with backoff.

---

## 2. Simple retry

```go
for attempt := 1; attempt <= 3; attempt++ {
    res, err := client.Do(req)

    if err != nil {
        fmt.Println("Request failed:", err)
        continue
    }

    if res.StatusCode == http.StatusOK {
        fmt.Println("Success!")
        res.Body.Close()
        break
    }

    res.Body.Close()
    fmt.Println("Request failed with status:", res.StatusCode)
    time.Sleep(2 * time.Second)
}
```

```text
for attempt := 1; attempt <= 3; attempt++    <- classic for loop, Lesson 4
if err != nil { continue }                    <- skip to next attempt, Lesson 4
if StatusCode == 200 { break }                <- stop the loop entirely, Lesson 4
```

Every piece here is something you already know; retry logic is just those pieces combined around an HTTP call.

---

## 3. What backoff is

Retrying with a fixed wait every time:

```text
1 second
1 second
1 second
```

works, but if the server is overloaded, three clients all retrying after exactly 1 second creates a burst of simultaneous traffic right when the server can least handle it. Backoff increases the wait each time instead:

```text
Attempt 1
   |
wait 1 second

Attempt 2
   |
wait 2 seconds

Attempt 3
   |
wait 4 seconds
```

This is exponential backoff — each wait roughly doubles the last.

```go
delay := time.Duration(1<<uint(attempt-1)) * time.Second
time.Sleep(delay)
```

Don't worry about the bit-shift syntax (`1<<...`) in detail yet — the concept to hold onto is the sequence it produces:

```text
1 -> 2 -> 4 -> 8 -> ...
```

A simpler, equally valid way to write the same doubling pattern while you're still building intuition for it:

```go
delay := time.Second
for attempt := 1; attempt <= maxRetries; attempt++ {
    // ... make the request ...
    time.Sleep(delay)
    delay *= 2
}
```

---

## 4. Maximum retries: don't retry forever

```go
maxRetries := 3

for attempt := 1; attempt <= maxRetries; attempt++ {
    // ... attempt request ...
}

fmt.Println("All retries exhausted")
```

A retry loop without a cap isn't resilience, it's an infinite loop waiting to happen — if the server is genuinely down, retrying forever just means your program never moves on, which is exactly the hanging behavior the timeout topic was trying to prevent in the first place.

---

## 5. When NOT to retry

Not every failure deserves a retry. This is the part easiest to get wrong.

```text
Worth retrying (transient, might succeed next time):
  500 Internal Server Error
  502 Bad Gateway
  503 Service Unavailable
  504 Gateway Timeout
  network timeouts, connection resets

NOT worth retrying (the request itself is the problem):
  400 Bad Request        -> your request is malformed; retrying sends the same bad request again
  401 Unauthorized         -> your credentials are wrong; retrying won't fix that
  403 Forbidden            -> you don't have permission; retrying won't fix that
  404 Not Found            -> the resource doesn't exist; retrying won't make it appear
```

The underlying principle: retry only when the failure is likely **temporary** and outside your control. A `4xx` status almost always means something about the request itself needs to change, and retrying the identical request will just get the identical failure, wasting time and load on the server for no benefit.

```go
if res.StatusCode >= 500 {
    // worth retrying
} else if res.StatusCode >= 400 {
    fmt.Println("Client error, not retrying:", res.StatusCode)
    return
}
```

---

## 6. The full picture, combined

```text
attempt := 1
     |
     v
make request
     |
     v
  success? ----yes----> done
     |
     no
     |
     v
retryable error? ----no----> stop, report failure
     |
    yes
     |
     v
attempt == max? ----yes----> stop, report failure
     |
     no
     |
     v
wait (backoff)
     |
     v
attempt++  -----------------> back to "make request"
```

This is the shape every resilient API client eventually needs, and it's exactly what the Phase 5 capstone (`devopsctl`) and the AWS SDK calls after it will rely on.

---

## 7. How engineers debug retry logic

| Symptom | Usual cause | First check |
|---|---|---|
| Program retries forever | no `maxRetries` cap, or the loop condition never becomes false | add an explicit maximum and confirm the loop variable actually increments |
| Program retries a `404` or `401` pointlessly | retrying on any non-200 status instead of checking which kind of error it is | only retry on `5xx` (and genuine network errors), return immediately on `4xx` |
| All retries happen instantly, with no real delay | missing or misplaced `time.Sleep`, e.g. placed before the request instead of after a failed attempt | confirm `time.Sleep` runs only after a failed attempt, inside the loop |
| Backoff doesn't seem to increase | delay variable reset to the same value every iteration, instead of growing | confirm the delay is read from an increasing value (e.g. `1<<attempt` or `delay *= 2`), not a constant |
| Retries overwhelm a struggling server further | fixed-delay retries from many clients line up and all retry at the same moment | this is exactly why exponential backoff exists; fixed delays make the problem worse under load |
