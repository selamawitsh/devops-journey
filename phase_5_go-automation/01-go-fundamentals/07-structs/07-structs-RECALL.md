# Lesson 7 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat on day 1, day 3 and day 7.

---

## A. Why structs

1. What problem with parallel slices does a struct solve?
2. In the ID-card analogy, what does a struct represent?
3. What silent bug can happen with parallel slices that a struct prevents?

## B. Defining a type vs creating an instance

4. What keyword starts a struct type definition?
5. Write a struct type called `Server` with `Name` (string), `Reachable` (bool), `CPUUsage` (float64).
6. By convention, is a struct's type name capitalized or lowercase?
7. By convention, is a variable holding a struct instance capitalized or lowercase?
8. What is the difference between `type Server struct {...}` and `webServer := Server{...}`?

## C. Creating instances

9. Write a named-field literal creating a `Server` called `"db-01"`, not reachable, `0.0` CPU usage.
10. Why is a named-field literal safer than a positional one?
11. `var s Server` with no values assigned. What does `s.CPUUsage` equal?
12. What does `s.Reachable` equal in that same uninitialized struct?

## D. Accessing fields

13. What operator do you use to read a field from a struct instance?
14. What operator do you use to change a field on a struct instance?
15. Is it a different operator for reading versus writing?

## E. Slices of structs

16. Write a one-line append that adds a new `Server` named `"cache-01"`, reachable `true`, CPU `12.0`, to a slice called `servers`.
17. What is the main benefit of a slice of structs over three parallel slices?

## F. The value-copy gotcha

18. You pass a `Server` into a function that sets `s.Reachable = false` inside it, using a plain value parameter. Does the original change?
19. Why or why not?
20. What must the function's parameter type become to fix this?
21. What must you pass at the call site to fix this?
22. What does `&webServer` mean?
23. What does `*Server` mean in a function signature?
24. Do you need to manually dereference a pointer to a struct in Go, like in C?

## G. Methods

25. In `func (s Server) Describe() string`, what is `s` called?
26. Is that receiver a value receiver or a pointer receiver?
27. What kind of receiver would `func (s *Server) MarkDown()` have?
28. Rule of thumb: when should a method use a pointer receiver?
29. Rule of thumb: when is a value receiver fine?
30. `webServer.MarkDown()` — do you need to write `(&webServer).MarkDown()` instead?

## H. range and structs together

31. `for _, s := range servers` where `servers` is `[]Server`. If you set `s.Reachable = false` inside the loop, does it change the original slice?
32. Why or why not?
33. What loop form should you use instead if you need to modify structs inside the slice?
34. Write the corrected line that sets `Reachable` to `false` on the actual struct inside the slice, using index `i`.

## I. Debugging

35. You changed a field inside a function but the original struct is unchanged. What's the most likely cause?
36. Your positional struct literal now has values in the wrong fields. What's the most likely cause?
37. Your struct prints as `{  false 0}` and you didn't expect that. What does this mean?

---

## Answer key

<details>
<summary>Try all 37 first, then open</summary>

### A. Why structs

1. Parallel slices can drift out of sync (e.g. one gets appended to and another doesn't); a struct bundles all of one server's fields together so they can't separate.
2. One record holding all the related fields for one thing, like one ID card per server.
3. Index mismatch: appending to one slice but not the others, so `servers[3]` no longer lines up with `reachable[3]`.

### B. Defining a type vs creating an instance

4. `type`.
5. `type Server struct { Name string; Reachable bool; CPUUsage float64 }` (written on separate lines in real code).
6. Capitalized.
7. Lowercase.
8. The first defines the shape of the struct (happens once); the second creates an actual instance with real values (happens every time you need one).

### C. Creating instances

9. `Server{Name: "db-01", Reachable: false, CPUUsage: 0.0}`.
10. The order doesn't matter and it's clear which value goes to which field, so it survives the struct's field order changing later.
11. `0`.
12. `false`.

### D. Accessing fields

13. Dot (`.`).
14. Dot (`.`).
15. No, the same dot notation is used for both; the difference is which side of `=` it's on.

### E. Slices of structs

16. `servers = append(servers, Server{Name: "cache-01", Reachable: true, CPUUsage: 12.0})`.
17. Each server's data travels together as one unit, so there's no risk of separate lists drifting out of sync.

### F. The value-copy gotcha

18. No.
19. Go passes structs by value, so the function receives a copy; changes to the copy never reach the original.
20. `*Server` (a pointer to `Server`).
21. `&webServer` (the address of the variable).
22. The address of `webServer`.
23. A pointer to a `Server`.
24. No, Go lets you write `s.Field` directly even when `s` is a pointer.

### G. Methods

25. The receiver.
26. A value receiver.
27. A pointer receiver.
28. When the method needs to change a field on the struct.
29. When the method only reads from the struct and doesn't need to modify it.
30. No, Go converts that automatically.

### H. range and structs together

31. No.
32. `range` gives a copy of each struct per iteration, so modifying the copy doesn't touch the original slice.
33. `for i := range servers`, modifying `servers[i]` directly.
34. `servers[i].Reachable = false`.

### I. Debugging

35. The struct was passed by value instead of by pointer.
36. A positional literal was used and the struct's field order changed since it was written.
37. It's the zero value: the struct was declared but never given any values via a literal or dot notation.

</details>

---

## Self-score

| Section | Questions | Day 1 | Day 3 | Day 7 |
|---|---|---|---|---|
| A. Why structs | 1-3 | /3 | /3 | /3 |
| B. Type vs instance | 4-8 | /5 | /5 | /5 |
| C. Creating instances | 9-12 | /4 | /4 | /4 |
| D. Accessing fields | 13-15 | /3 | /3 | /3 |
| E. Slices of structs | 16-17 | /2 | /2 | /2 |
| F. Value-copy gotcha | 18-24 | /7 | /7 | /7 |
| G. Methods | 25-30 | /6 | /6 | /6 |
| H. range and structs | 31-34 | /4 | /4 | /4 |
| I. Debugging | 35-37 | /3 | /3 | /3 |
| Total | 37 | /37 | /37 | /37 |

Target: 33 or more out of 37 on day 7. Any section below 80 percent, go back to that part of `README.md`. Sections F, G, and H are really one concept in three disguises — value vs pointer — so if you miss in one, re-check all three.
