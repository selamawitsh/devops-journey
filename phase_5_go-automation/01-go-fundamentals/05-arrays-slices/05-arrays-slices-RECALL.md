# Lesson 5 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

---

## A. Why you need a list

1. What was the problem with hardcoding `serverA`, `serverB`, `serverC` as separate variables?
2. In the shelf vs shopping-list analogy, which one is a slice?
3. Which one, array or slice, is what you will actually use almost all the time?

## B. Arrays

4. How do you declare a 3-item string array with values in one line?
5. What makes `[3]string` and `[4]string` different types?
6. Why are arrays rarely used directly in real Go code?

## C. Slice basics

7. How does the declaration of a slice differ visually from an array?
8. `servers := []string{"web-01", "web-02", "db-01"}`. What is `servers[0]`?
9. What is `servers[2]`?
10. Are Go slice indexes zero-based or one-based?

## D. len()

11. What does `len(servers)` return?
12. Why should a loop bound use `len(servers)` instead of a hardcoded number?
13. A slice grows from 3 to 4 items but your loop bound is a hardcoded `3`. What happens to the fourth item?
14. A slice shrinks and your loop bound is a hardcoded number based on the old size. What error can this cause?

## E. append()

15. What does `append(servers, "cache-01")` return?
16. Does `append` change `servers` in place?
17. What must you do with the result of `append` for the change to actually take effect?
18. What is wrong with this line on its own: `append(servers, "cache-01")`?
19. What might Go need to do internally when a slice grows past its current capacity?

## F. Looping over a slice

20. Write a `range` loop that prints the index and value of each item in `servers`.
21. If you only need the value, not the index, what do you write in its place?

## G. Slicing a slice

22. What does `servers[0:2]` mean in plain English?
23. Is the end index in `[0:2]` inclusive or exclusive?
24. `servers := []string{"a", "b", "c", "d"}`. What does `servers[1:3]` contain?
25. Name the common mistake people make with the end index in a slice expression.

## H. Applying it

26. Why is a slice a better fit than separate variables when your manager adds a new server every week?
27. What two things stay unchanged in your code when you add a new server to a slice-based health checker?
28. Write one line that adds `"new-server"` to an existing slice called `servers`.

## I. Debugging

29. You get an "index out of range" panic. Name the most likely cause.
30. You called `append` but the slice looks unchanged. Name the most likely cause.
31. `var servers []string` was declared but nothing was appended. What does `len(servers)` return?
32. A sub-slice has the wrong items in it. What should you check first?

---

## Answer key

<details>
<summary>Try all 32 first, then open</summary>

### A. Why you need a list

1. Adding a new server meant adding a new variable and rewriting the loop; it does not scale.
2. The shopping list.
3. Slice.

### B. Arrays

4. `servers := [3]string{"web-01", "web-02", "db-01"}`.
5. The size is part of the type, so a 3-slot array and a 4-slot array are different types.
6. You almost never know the exact count ahead of time, and their fixed size makes them inflexible.

### C. Slice basics

7. A slice has no number inside the square brackets: `[]string` instead of `[3]string`.
8. `"web-01"`.
9. `"db-01"`.
10. Zero-based.

### D. len()

11. The current number of elements in the slice.
12. Because a hardcoded number goes stale when the slice's size changes.
13. It is skipped, because the loop stops before reaching index 3.
14. An "index out of range" panic.

### E. append()

15. A new slice value with the item added.
16. No.
17. Reassign it back to the variable: `servers = append(servers, ...)`.
18. The result is discarded, so `servers` does not actually change.
19. Allocate a bigger block of memory and copy the existing items into it.

### F. Looping over a slice

20. `for i, name := range servers { fmt.Println(i, name) }`.
21. `_` in place of the index variable.

### G. Slicing a slice

22. Starting at index 0, up to but not including index 2.
23. Exclusive.
24. `["b", "c"]`.
25. Forgetting that the end index is exclusive, and including or excluding one item too many.

### H. Applying it

26. Adding a server is one line (`append`), instead of adding a new variable and touching every place that lists servers individually.
27. The loop and the function that processes each server (e.g. `evaluateServer`).
28. `servers = append(servers, "new-server")`.

### I. Debugging

29. A hardcoded loop bound that no longer matches the slice's actual length.
30. Forgetting to reassign the result of `append` back to the variable.
31. `0`.
32. Whether the end index in `[start:end]` is exclusive, and recount which indices are actually wanted.

</details>

---

