# Lesson 8 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.


## A. Why Go handles errors differently

1. In the delivery analogy, what does the "package thrown over the fence" represent?
2. In the same analogy, what does "signature required" represent?
3. What is the practical danger of an exception-style failure that Go's approach avoids?
4. Where does Go tell you a function can fail, without reading its whole body?

## B. The error type

5. What does `err == nil` mean?
6. Does `nil` mean "empty," or something more specific? What?
7. What built-in Go type is `error`?

## C. The core pattern

8. Write a function signature for `pingServer` taking a `string` and returning `(bool, error)`.
9. What Go type keyword is lowercase: `string` or `String`?
10. What is the very next line you should write after calling a function that returns `(result, error)`?
11. Should you use the result before or after checking the error?

## D. Creating your own errors

12. Which function creates a simple, fixed error message: `errors.New` or `fmt.Errorf`?
13. Which function lets you insert a dynamic value into an error message?
14. Write an error using `fmt.Errorf` that includes an integer variable `port` in the message.
15. Why is `fmt.Errorf("invalid port: %d", port)` more useful than `errors.New("port out of valid range")` at 2am during an incident?

## E. Wrapping errors

16. What formatting verb wraps an error while keeping the original reachable?
17. What formatting verb turns an error into flat text with no way back to the original?
18. What two functions can later unwrap a `%w`-wrapped error?
19. Write a wrapped error: `checkServer` failed for `name`, wrapping an existing `err`.

## F. panic

20. What kind of problem is `error` meant for?
21. What kind of problem is `panic` meant for?
22. Which lesson did you already encounter a panic in, without knowing the term?
23. What was that panic called?
24. Is "the server didn't respond" a good reason to `panic`?

## G. Applying it

25. Write a `for` loop over `servers` that calls `checkServer`, logs an error with `fmt.Println`, and moves on to the next server without stopping.
26. Which keyword lets the loop move to the next server after logging an error?
27. Why shouldn't one unreachable server stop the whole health check?

## H. Debugging

28. Your program panics unexpectedly. What should you NOT do: quietly wrap it and move on, or read the panic message and stack trace?
29. Your error message just says "something went wrong." What's the fix?
30. A function's `error` return value was never checked. What happens to real failures?
31. After three layers of function calls, you can no longer tell what the original error was. What formatting mistake likely caused this?
32. What's wrong with this code?
    ```go
    result, err := checkServer("db-01")
    fmt.Println(result)
    ```

---

## Answer key

<details>
<summary>Try all 32 first, then open</summary>

### A. Why Go handles errors differently

1. An exception: you don't know it happened until it's already caused damage.
2. A Go error: the function hands it to you directly as a return value, and you must check it before moving on.
3. A failure can happen and be missed entirely, silently continuing with bad data or a bad state.
4. In its return type, e.g. `(bool, error)`.

### B. The error type

5. No error happened; the function succeeded.
6. Something more specific: "no error/no value," not "empty."
7. An interface.

### C. The core pattern

8. `func pingServer(name string) (bool, error) { }`.
9. `string`.
10. `if err != nil { ... }`.
11. After.

### D. Creating your own errors

12. `errors.New`.
13. `fmt.Errorf`.
14. `fmt.Errorf("invalid port: %d", port)`.
15. It tells you the actual value that caused the failure, instead of a generic message you have to investigate further to understand.

### E. Wrapping errors

16. `%w`.
17. `%v`.
18. `errors.Is` and `errors.As`.
19. `fmt.Errorf("checkServer failed for %s: %w", name, err)`.

### F. panic

20. Expected, recoverable problems, a normal part of operation.
21. Bugs — situations that should never happen if the code is correct.
22. Lesson 5.
23. "Index out of range."
24. No, that's a normal, expected outcome and should be an `error`.

### G. Applying it

25. `for _, name := range servers { _, err := checkServer(name); if err != nil { fmt.Println("ALERT:", err); continue }; fmt.Println(name, "is healthy") }` (shape may vary).
26. `continue`.
27. Because the point of a health checker is to report on all servers; one failure shouldn't hide the status of every other server.

### H. Debugging

28. Do not quietly wrap it and move on; read the panic message and stack trace.
29. Use `fmt.Errorf` with the specific values involved instead of a bare, generic `errors.New`.
30. They get missed entirely; the program continues as if nothing went wrong.
31. Using `%v` (or string concatenation) instead of `%w` when wrapping.
32. The error returned by `checkServer` is never checked, so a failure could be silently ignored while `result` is printed anyway.

</details>

---

