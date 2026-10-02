# Topic Active Recall: Authentication

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat on day 1, day 3 and day 7.

---

## A. What authentication is

1. What question does authentication answer?
2. What status code typically comes back when authentication is missing or wrong?

## B. API keys

3. Write a line that sets an `X-API-Key` header to the value of a variable called `apiKey`.
4. What should never be hardcoded directly into that line in real code?

## C. Keeping secrets out of code

5. What happens to a secret once it's committed to Git, even if the line is later deleted?
6. Write the two lines: setting an environment variable called `API_KEY` in the shell, then reading it into Go.
7. Why does reading from an environment variable protect the secret, specifically?

## D. Bearer tokens

8. Write the HTTP header format for a Bearer token, as plain text.
9. Write the Go line that sets this header using a variable called `token`.
10. Is `Bearer` part of the token value, or a separate literal word in the header?

## E. The complete example

11. In the complete example, what is the one genuinely new line compared to the `http-client` topic?
12. What import is needed to read an environment variable?

## F. Why environment variables, specifically

13. Name three kinds of secrets, besides API tokens, that follow this same pattern in DevOps work.
14. What does `os.Getenv` return if the variable isn't set?
15. Why is that return value dangerous if unchecked?
16. What happens to a request sent with an empty Bearer token — does it fail to send, or does it go out and get rejected?
17. Which function should you use instead of `os.Getenv` to catch a missing variable before using it?
18. Write the comma-ok check for `API_TOKEN`, printing a message and returning if it's missing or empty.

## G. Where secrets should live

19. Name two places secrets should never live.
20. What should a local file holding a real secret for testing be listed in?

## H. Debugging

21. Every request returns 401. What's the first thing to check?
22. A request works for you but fails for a teammate. What's the likely cause?
23. The header looks correct in your code but the request still fails. Name two specific things to check in the header value itself.
24. A secret was accidentally committed to Git. Is deleting the line and committing again enough to remove it from history?
25. `os.Getenv` returns `""` but the request still goes out instead of failing early. What's missing?

---

## Answer key

<details>
<summary>Try all 25 first, then open</summary>

### A. What authentication is

1. "Who are you?"
2. `401 Unauthorized`.

### B. API keys

3. `req.Header.Set("X-API-Key", apiKey)`.
4. The actual secret value.

### C. Keeping secrets out of code

5. It remains in the repository's history permanently, unless the history itself is rewritten.
6. `export API_KEY="your-secret-key"` in the shell; `apiKey := os.Getenv("API_KEY")` in Go.
7. The secret is never typed into a `.go` file, so it's never staged or committed with the code.

### D. Bearer tokens

8. `Authorization: Bearer YOUR_TOKEN`.
9. `req.Header.Set("Authorization", "Bearer "+token)`.
10. A separate literal word, followed by a space and then the token.

### E. The complete example

11. `req.Header.Set("Authorization", "Bearer "+token)`.
12. `"os"`.

### F. Why environment variables, specifically

13. Any three of: AWS credentials, database passwords, SSH-related secrets, CI/CD secrets.
14. `""`, an empty string.
15. It can't be told apart from a variable that was deliberately set to an empty value, so a missing secret looks the same as one set to nothing.
16. It goes out and gets rejected (typically with a 401), it does not fail to send.
17. `os.LookupEnv`.
18. `token, exists := os.LookupEnv("API_TOKEN"); if !exists || token == "" { fmt.Println("API_TOKEN is not set"); return }`.

### G. Where secrets should live

19. Hardcoded in a `.go` file, or committed in a config file tracked by Git.
20. `.gitignore`.

### H. Debugging

21. Whether the token/key is actually set — print its length, never the value itself.
22. The environment variable isn't set in their shell, or is set to an outdated value.
23. The literal word `Bearer` and the space before the token; also the exact header name for typos.
24. No, the secret remains in Git history; it must be rotated (treated as compromised) regardless.
25. A check for the empty/unset case before using the value, e.g. switching to `os.LookupEnv`.

</details>

---

## Self-score

| Section | Questions | Day 1 | Day 3 | Day 7 |
|---|---|---|---|---|
| A. What authentication is | 1-2 | /2 | /2 | /2 |
| B. API keys | 3-4 | /2 | /2 | /2 |
| C. Keeping secrets out of code | 5-7 | /3 | /3 | /3 |
| D. Bearer tokens | 8-10 | /3 | /3 | /3 |
| E. The complete example | 11-12 | /2 | /2 | /2 |
| F. Why environment variables | 13-18 | /6 | /6 | /6 |
| G. Where secrets should live | 19-20 | /2 | /2 | /2 |
| H. Debugging | 21-25 | /5 | /5 | /5 |
| Total | 25 | /25 | /25 | /25 |

Target: 22 or more out of 25 on day 7. Any section below 80 percent, go back to that part of `README.md`.
