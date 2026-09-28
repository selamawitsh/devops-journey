# Lesson 6 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.


## A. Why maps

1. What can a slice find things by, and what can a map find things by?
2. What real-world object is a map compared to in the notes?
3. Give two examples of real DevOps data that fits a key-value shape.

## B. Declaring a map

4. Write a map literal called `status` with `"web-01"` mapped to `"healthy"`.
5. In `map[string]string`, which part is the key type?
6. Which part is the value type?
7. Write the `make()` form of declaring an empty `map[string]string` called `status`.
8. Name the two ways to declare a map shown in the notes.

## C. Reading and writing

9. Write a line that reads the value for key `"db-01"` from `status`.
10. Write a line that adds a new key `"cache-01"` with value `"healthy"` to `status`.
11. What happens if you write to a key that already exists?

## D. The missing-key gotcha

12. `status["gpu-server"]` where `"gpu-server"` is not in the map. Does Go crash?
13. What does Go return instead?
14. What is this returned value called?
15. Why is this dangerous if you don't check for it?
16. What is the name of the idiom that fixes this?
17. Write the comma-ok form for checking if `"db-01"` exists in `status`.
18. In `value, exists := status["db-01"]`, what type is `exists`?
19. If the key exists, what does `exists` equal?
20. If the key does not exist, what does `value` equal (for a `map[string]string`)?

## E. Deleting

21. Write a line that deletes `"db-01"` from `status`.
22. What happens if you try to delete a key that isn't in the map?

## F. Looping and len()

23. Write a `range` loop over `status` printing each key and value.
24. Is the order of a `range` loop over a map guaranteed to be the same every run?
25. Why did Go's designers make map order unpredictable on purpose?
26. What does `len(status)` return?
27. If `status` has 5 key-value pairs, what does `len(status)` return?

## G. Applying it

28. You want to alert on every server whose status is `"down"`. Which map operation do you need: read, write, delete, or loop?
29. Why can't a single map lookup by key solve the "find all down servers" problem?
30. Write a comma-ok check for `"cache-01"` in `serverStatus` that prints its status if found, or "not being monitored yet" if not.

## H. Debugging

31. You get `panic: assignment to entry in nil map`. What is the most likely cause?
32. What is the fix for that panic?
33. Your code expected "not found" but got `""` instead. What did you forget?
34. Your printed map output is in a different order than last time you ran it. Is that a bug?

---

## Answer key

<details>
<summary>Try all 34 first, then open</summary>

### A. Why maps

1. A slice finds things by position (index). A map finds things by key (name).
2. A filing cabinet with labeled folders.
3. Any two of: server name to status, container ID to memory usage, hostname to IP address.

### B. Declaring a map

4. `status := map[string]string{"web-01": "healthy"}`.
5. The type inside the square brackets, e.g. `string` in `map[string]string`.
6. The type right after the square brackets, e.g. the second `string` in `map[string]string`.
7. `status := make(map[string]string)`.
8. A map literal, and `make()`.

### C. Reading and writing

9. `status["db-01"]`.
10. `status["cache-01"] = "healthy"`.
11. It gets overwritten with the new value.

### D. The missing-key gotcha

12. No.
13. The zero value for that type.
14. The zero value.
15. You can't tell the difference between "the value really is empty/zero" and "the key was never there."
16. The comma-ok idiom.
17. `value, exists := status["db-01"]`.
18. `bool`.
19. `true`.
20. `""` (empty string).

### E. Deleting

21. `delete(status, "db-01")`.
22. Nothing. It is a safe no-op, no error.

### F. Looping and len()

23. `for k, v := range status { fmt.Println(k, v) }`.
24. No.
25. So nobody accidentally relies on an order that was never guaranteed.
26. The number of key-value pairs in the map.
27. `5`.

### G. Applying it

28. Loop.
29. You don't know in advance which keys have status `"down"`, so you must inspect every value to find them.
30. `if s, ok := serverStatus["cache-01"]; ok { fmt.Println("cache-01 status:", s) } else { fmt.Println("not being monitored yet") }`.

### H. Debugging

31. Writing to a map that was declared with a bare `var` and never `make`'d or given a literal.
32. Declare it with `make(map[K]V)` or a map literal before writing to it.
33. The comma-ok check; you read the value directly instead of checking `ok`/`exists`.
34. No, that is expected behavior — map order is never guaranteed in Go.

</details>

---

