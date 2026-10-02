# Topic Active Recall: HTTP Client

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat on day 1, day 3 and day 7.

---

## A. APIs, clients, servers

1. What is an API, in your own words?
2. In a request between your Go program and an API server, which one is the client?
3. What does HTTP stand for, and what is it used for?

## B. The request

4. What four pieces make up an HTTP request?
5. What does the `GET` method normally mean?
6. What does the `DELETE` method normally mean?
7. Break down `https://api.example.com/servers/42` into its three parts.
8. What is the purpose of a header? Give one example.
9. What is the purpose of the request body? Which methods commonly use one?

## C. The response and status codes

10. What three pieces make up an HTTP response?
11. What does a `2xx` status code range mean?
12. What does a `4xx` status code range mean?
13. What does a `5xx` status code range mean?
14. What's the difference between `401` and `403`?
15. Which status code range becomes especially important once you learn retries?

## D. http.Get

16. What two values does `http.Get` return?
17. What does `err != nil` mean after calling `http.Get`?
18. What does `response.Status` give you, versus `response.StatusCode`?
19. Why do we write `defer response.Body.Close()`?
20. What type does `io.ReadAll(response.Body)` return, and what converts it to a readable string?

## E. The two kinds of failure

21. `err != nil` after `client.Do(request)` — what failed?
22. `err == nil`, `response.StatusCode == 404` — did the request fail?
23. What mistake does a program make if it only checks `err != nil` and assumes that means success?

## F. http.Client and http.NewRequest

24. Why use `http.Client` instead of just `http.Get`?
25. What does `client := &http.Client{}` create?
26. What are the three arguments to `http.NewRequest("GET", "https://example.com", nil)`?
27. Why is the third argument `nil` for a GET request?
28. Name two places where an error can occur when using `http.NewRequest` plus `client.Do`.

## G. Headers and timeouts

29. Write the line that sets an `Accept: application/json` header on a request.
30. What problem does a `Timeout` on `http.Client` solve?
31. Write the struct literal for an `http.Client` with a 5-second timeout.
32. In a tool checking 50 servers, what happens to servers 4 through 50 if server 3 hangs and there's no timeout?

## H. Status code constants

33. What does `http.StatusOK` represent, as a number?
34. Why might `http.StatusOK` be preferred over writing `200` directly?
35. Is checking `response.StatusCode != http.StatusOK` the same check as `err != nil`?

## I. Applying it

36. Draw (in words) the professional mental model: create request, error check, send, error check, then what three steps?
37. Can `http.Client` be reused across multiple requests, or does it need to be recreated each time?

## J. Debugging

38. Your program hangs indefinitely on a slow server. What's missing?
39. Your program printed success even though the API returned a 500. What check is missing?
40. You set a header but it seems to have no effect. What's the most likely cause?

---

## Answer key

<details>
<summary>Try all 40 first, then open</summary>

### A. APIs, clients, servers

1. The agreed way two systems communicate over a network.
2. The Go program.
3. Hypertext Transfer Protocol; the protocol used for communication between clients and servers.

### B. The request

4. Method, URL, headers, body.
5. Read data.
6. Delete data.
7. `https://` protocol, `api.example.com` server/domain, `/servers/42` resource/path.
8. Metadata about the request, e.g. `Content-Type: application/json` tells the server what format the body is in.
9. The actual data being sent; commonly used with POST, PUT, PATCH.

### C. The response and status codes

10. Status code, headers, body.
11. Success.
12. A problem caused by the client (bad request, missing auth, forbidden, not found).
13. A problem on the server's side.
14. `401` means authentication is missing or invalid; `403` means the server understood the request but the client doesn't have permission.
15. `5xx`.

### D. http.Get

16. `response` and `err`.
17. The request itself failed (e.g. network or DNS failure), not that the server returned a bad status.
18. `response.Status` is the full text like `"200 OK"`; `response.StatusCode` is just the number, `200`.
19. To make sure the response body is closed when the function ends, no matter how it exits.
20. `[]byte`; `string(...)` converts it.

### E. The two kinds of failure

21. The HTTP request itself (network, DNS, connection).
22. No, the request succeeded; the server responded with a 404 status.
23. It assumes any `err == nil` result means the API call was successful, missing bad HTTP statuses like 404 or 500.

### F. http.Client and http.NewRequest

24. It gives more control: custom headers, authentication, timeouts, non-GET methods.
25. A pointer to a new, empty `http.Client`.
26. The HTTP method, the URL, and the request body.
27. GET requests don't send a body.
28. Creating the request (`http.NewRequest`) and sending it (`client.Do`).

### G. Headers and timeouts

29. `request.Header.Set("Accept", "application/json")`.
30. It prevents the program from waiting indefinitely if the server never responds.
31. `client := &http.Client{Timeout: 5 * time.Second}`.
32. They never get checked; the program appears frozen on server 3.

### H. Status code constants

33. `200`.
34. It makes the meaning obvious at a glance, rather than requiring the reader to remember what the number means.
35. No, they check different things: one checks whether the HTTP operation itself failed, the other checks whether the response represents success.

### I. Applying it

36. Create request, error check (stop if error), send, error check (stop if error), then: check status, read body, process data.
37. Yes, it's safe and normal to reuse a single `http.Client` across many requests.

### J. Debugging

38. A `Timeout` on the `http.Client`.
39. A check on `response.StatusCode`, not just `err != nil`.
40. The header was set on the wrong variable, or set after the request was already sent.

</details>

---

## Self-score

| Section | Questions | Day 1 | Day 3 | Day 7 |
|---|---|---|---|---|
| A. APIs, clients, servers | 1-3 | /3 | /3 | /3 |
| B. The request | 4-9 | /6 | /6 | /6 |
| C. Response and status codes | 10-15 | /6 | /6 | /6 |
| D. http.Get | 16-20 | /5 | /5 | /5 |
| E. Two kinds of failure | 21-23 | /3 | /3 | /3 |
| F. http.Client and NewRequest | 24-28 | /5 | /5 | /5 |
| G. Headers and timeouts | 29-32 | /4 | /4 | /4 |
| H. Status code constants | 33-35 | /3 | /3 | /3 |
| I. Applying it | 36-37 | /2 | /2 | /2 |
| J. Debugging | 38-40 | /3 | /3 | /3 |
| Total | 40 | /40 | /40 | /40 |

Target: 35 or more out of 40 on day 7. Any section below 80 percent, go back to that part of `README.md`.
