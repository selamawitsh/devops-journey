# Topic Active Recall: Retry and Backoff

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat on day 1, day 3 and day 7.

---

## A. Why retry

1. A request fails with a 503. Should the program necessarily give up immediately?
2. Give one real reason a server might temporarily fail that has nothing to do with your request being wrong.

## B. Simple retry loop

3. Which Go loop construct is used to attempt a request multiple times?
4. Inside the loop, what keyword skips to the next attempt when `err != nil`?
5. What keyword stops the loop entirely once a request succeeds?
6. Why must `res.Body.Close()` still be called on a failed attempt, not just a successful one?

## C. What backoff is

7. What problem does a fixed, identical delay between every retry create under load?
8. What does exponential backoff do differently from a fixed delay?
9. Write the sequence of delays (in seconds) for 4 attempts of exponential backoff starting at 1 second.

## D. Maximum retries

10. What happens to a retry loop with no maximum attempt count, if the server never recovers?
11. Why is an uncapped retry loop considered a return of the same problem that timeouts were meant to solve?

## E. When not to retry

12. Name two status codes worth retrying.
13. Name two status codes NOT worth retrying.
14. What is the underlying principle for deciding whether a failure is worth retrying?
15. Why is retrying a `400 Bad Request` pointless?
16. Why is retrying a `401 Unauthorized` pointless?
17. Write the condition that treats any status `>= 500` as retryable and anything `>= 400` (but below 500) as not retryable.

## F. The full picture

18. In the full retry flowchart, what's checked immediately after a request succeeds?
19. What's checked immediately after a request fails?
20. What's checked after confirming an error is retryable, before waiting and trying again?

## G. Debugging

21. Your program retries forever and never stops. What's the likely cause?
22. Your program retries on a 404 every time. What's the likely cause?
23. All your retries happen instantly with no visible delay. What's the likely cause?
24. Your delay doesn't seem to increase between attempts. What's the likely cause?
25. Many clients retrying at the same fixed delay make a struggling server worse. What technique specifically addresses this?

---

## Answer key

<details>
<summary>Try all 25 first, then open</summary>

### A. Why retry

1. No, the failure might be temporary.
2. Any reasonable example: temporary overload, a deployment in progress, a brief network blip.

### B. Simple retry loop

3. A classic `for` loop with a counter, e.g. `for attempt := 1; attempt <= 3; attempt++`.
4. `continue`.
5. `break`.
6. To avoid leaking the response body's resources, even on a failed attempt.

### C. What backoff is

7. It can cause many clients to retry at the exact same moment, creating a burst of traffic right when the server can least handle it.
8. It increases the wait time between each attempt, rather than keeping it fixed.
9. 1, 2, 4, 8.

### D. Maximum retries

10. The program retries indefinitely and never moves on.
11. Both cases leave the program stuck waiting indefinitely instead of eventually giving up and reporting failure.

### E. When not to retry

12. Any two of: 500, 502, 503, 504.
13. Any two of: 400, 401, 403, 404.
14. Retry only when the failure is likely temporary and outside your control.
15. The request itself is malformed; retrying sends the exact same bad request and gets the same result.
16. The credentials are wrong; retrying doesn't fix invalid authentication.
17. `if res.StatusCode >= 500 { /* retryable */ } else if res.StatusCode >= 400 { /* not retryable */ }`.

### F. The full picture

18. Nothing further — the flow is done.
19. Whether the error is retryable at all.
20. Whether the maximum attempt count has already been reached.

### G. Debugging

21. No maximum retry count, or the loop condition never becomes false.
22. Retrying on any non-200 status instead of checking whether it's specifically a 5xx (retryable) vs 4xx (not retryable) error.
23. A missing or misplaced `time.Sleep`, not actually running between attempts.
24. The delay variable is reset to the same value each iteration instead of growing.
25. Exponential backoff.

</details>

---

## Self-score

| Section | Questions | Day 1 | Day 3 | Day 7 |
|---|---|---|---|---|
| A. Why retry | 1-2 | /2 | /2 | /2 |
| B. Simple retry loop | 3-6 | /4 | /4 | /4 |
| C. What backoff is | 7-9 | /3 | /3 | /3 |
| D. Maximum retries | 10-11 | /2 | /2 | /2 |
| E. When not to retry | 12-17 | /6 | /6 | /6 |
| F. The full picture | 18-20 | /3 | /3 | /3 |
| G. Debugging | 21-25 | /5 | /5 | /5 |
| Total | 25 | /25 | /25 | /25 |

Target: 22 or more out of 25 on day 7. Any section below 80 percent, go back to that part of `README.md`.
