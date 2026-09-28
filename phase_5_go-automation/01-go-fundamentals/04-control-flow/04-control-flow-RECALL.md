# Lesson 4 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

---

## A. Why control flow

1. What could `checkCPU()` not do in Lesson 3 that it needs to do now?
2. In the health-checker decision tree, what happens if the server is not reachable?
3. Which keyword repeats a decision across many servers?

## B. if / else

4. What does `if` require around its condition?
5. What is always required around an `if` or `else` body, even for one line?
6. Write the comparison operator for "greater than or equal to."
7. `cpuUsage := 92.5`. Write an `if`/`else` that prints "ALERT" if it is over 80, otherwise "CPU normal."
8. In an `else if` chain, does Go run every matching condition or just the first one?
9. Why must the most severe condition be checked first in an `else if` chain?
10. `reachable := true`. Write the condition to check reachability is false using `!`.

## C. Logical operators

11. What does `&&` require?
12. What does `||` require?
13. What does `!` do to a boolean value?
14. Write a condition that is true only when both `reachable` and `cpuOK` are true.

## D. = vs ==

15. Which operator compares two values for equality?
16. Which operator assigns a value to a variable?
17. Does Go's compiler allow `if reachable = true`?

## E. switch

18. When is `switch` cleaner to use than a long `else if` chain?
19. Does Go fall through to the next case automatically?
20. What does `default` do in a `switch`?
21. Write a `switch` with no value after it, checking `statusCode >= 500` and `statusCode >= 400`.

## F. for: the classic form

22. How many loop keywords does Go have?
23. Write the three parts of a classic `for` loop header, in order.
24. What separates the three parts of a classic `for` loop?
25. `for i := 0; i < 5; i++`. What happens right before each iteration runs?
26. What happens right after each iteration runs?

## G. for: other forms

27. Write a condition-only `for` loop that runs while `attempts < 3`.
28. What keyword stops an infinite `for { }` loop?
29. Name one real DevOps use for an infinite loop with `break`.

## H. range

30. What two values does `range` give you when looping over a slice?
31. How do you discard the index if you don't need it?
32. `servers := []string{"web-01", "web-02"}`. Write a loop that prints just the names.

## I. continue vs break

33. What does `continue` do?
34. What does `break` do?
35. You want to skip `"db-01"` but keep checking the rest. Which keyword do you use?

## J. Applying it and debugging

36. Why check `if !reachable { return }` before any other check in a health function?
37. `for i := 0; i <= 5; i++` loops over a 5-item slice (indices 0 to 4). What error occurs, and what is it called?
38. What is the fix for that error?
39. Your `switch` on `status` produces the wrong output. Name two likely causes.
40. Your loop never ends. Name two likely causes.

---

## Answer key

<details>
<summary>Try all 40 first, then open</summary>

### A. Why control flow

1. Decide what to do based on the actual result, instead of always doing the same thing.
2. The check stops there; the server is marked DOWN and the rest of the checks are skipped.
3. `for`.

### B. if / else

4. No parentheses.
5. Curly braces `{ }`.
6. `>=`.
7. `if cpuUsage > 80 { fmt.Println("ALERT") } else { fmt.Println("CPU normal") }`.
8. Just the first one that matches, then it stops.
9. Because Go stops at the first true condition; if a less severe condition is checked first, execution never reaches the more severe branch.
10. `if !reachable`.

### C. Logical operators

11. Both sides must be true.
12. At least one side must be true.
13. Flips it: true becomes false, false becomes true.
14. `if reachable && cpuOK`.

### D. = vs ==

15. `==`.
16. `=`.
17. No, it is a compile error, because `if` needs a boolean expression and `=` is assignment.

### E. switch

18. When several `else if` branches all check the same variable.
19. No.
20. Runs when no other case matches.
21. `switch { case statusCode >= 500: ... case statusCode >= 400: ... }`.

### F. for: the classic form

22. One (`for`).
23. Initializer, condition, post-statement — e.g. `i := 0`, `i < 5`, `i++`.
24. Semicolons.
25. The condition is checked; the loop continues only if it is true.
26. The post-statement runs, e.g. `i++`.

### G. for: other forms

27. `for attempts < 3 { ... }`.
28. `break`.
29. Retrying a connection until it succeeds or a max attempt count is reached, or polling for a status change.

### H. range

30. Index and value.
31. Use `_` in place of the index variable.
32. `for _, name := range servers { fmt.Println(name) }`.

### I. continue vs break

33. Skips the rest of the current iteration and moves to the next one.
34. Exits the loop entirely.
35. `continue`.

### J. Applying it and debugging

36. If the server isn't reachable, none of the other checks are meaningful, so there's no point running them.
37. "Index out of range", a panic, because index 5 doesn't exist in a slice with only indices 0-4.
38. Change `<=` to `<` in the loop condition.
39. Forgetting Go doesn't fall through between cases, or a missing `default` case that silently produces no output.
40. The condition never becomes false, or the post-statement (like `i++`) was forgotten.

</details>

