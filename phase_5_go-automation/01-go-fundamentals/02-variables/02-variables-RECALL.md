# Lesson 2 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

---

## A. Why variables

1. Why does a server health checker need variables?
2. In the labeled-box analogy, what are the two things inside the box?
3. Name three pieces of server information you might store in variables.

## B. What a variable is

4. In one sentence, what is a variable?
5. `name := "Selamawit"` then `fmt.Println(name)`. What prints?
6. What three things does every Go variable have?

## C. Strong typing

7. What does "Go is strongly typed" mean?
8. `var port int = 22`. What is the type of `port`?
9. `var reachable bool = true`. What is the type of `reachable`?
10. Can you assign a `string` value to a variable that was created as `int`?

## D. Basic data types

11. Which type holds text?
12. Which type holds whole numbers?
13. Which type holds numbers with decimals?
14. Which type holds only `true` or `false`?
15. Which type would you use for a CPU usage of `72.5`?
16. Which type would you use for a port number like `22`?
17. Which type would you use for "is this server reachable"?
18. Is an IP address like `10.0.1.20` stored as a string or a special network type at this stage?
19. Give one example value for `float64` other than 72.5.

## E. Declaring variables

20. Write the explicit declaration form for a string called `serverName` with value `"web-01"`.
21. Write the short declaration form for the same variable.
22. Which keyword is used in explicit declaration that is not used in short declaration?
23. How does Go decide the type when you use `:=`?
24. Where can you use `:=`: anywhere in a file, or only inside a function?
25. `count := 5`. What type does Go infer?

## F. Changing variables

26. `status := "starting"` then `status = "running"`. What does `status` hold at the end?
27. After that reassignment, does the type of `status` change?
28. What is wrong with writing `status := "running"` again on the very next line in the same scope?
29. Which operator declares a variable, `:=` or `=`?
30. Which operator reassigns a variable, `:=` or `=`?

## G. The type rule

31. Why does `port := 22` followed by `port = "ssh"` fail?
32. What is `port`'s type fixed to after the first line?
33. Name one real-world DevOps mistake that strong typing helps prevent.

## H. Applying it

34. You are told: server name, IP, port, CPU usage, reachable. List the five variable names and their types.
35. Write one line of Go that declares a port number `8080` using short declaration.
36. Write one line of Go that declares `healthy` as `true` using short declaration.
37. Which function do you use to print a variable's value to the terminal?
38. You declared `cpuUsage := 72.5` but need to print it. Write that line.

---

## Answer key

<details>

### A. Why variables

1. To remember information about the server, such as its name, IP, port, CPU usage and reachability.
2. The value and its type.
3. Any three of: server name, IP address, port, status, CPU usage.

### B. What a variable is

4. A named place where your program stores a value.
5. `Selamawit`.
6. A name, a value, and a type.

### C. Strong typing

7. Every variable has a fixed type, and Go enforces that the value must match that type.
8. `int`.
9. `bool`.
10. No, not without conversion; this is why `port = "ssh"` fails when `port` is an `int`.

### D. Basic data types

11. `string`.
12. `int`.
13. `float64`.
14. `bool`.
15. `float64`.
16. `int`.
17. `bool`.
18. As a string, plain text.
19. Any decimal value, e.g. `3.14` or `0.5`.

### E. Declaring variables

20. `var serverName string = "web-01"`.
21. `serverName := "web-01"`.
22. `var`.
23. It infers the type from the value on the right-hand side.
24. Only inside a function.
25. `int`.

### F. Changing variables

26. `"running"`.
27. No, the type stays `string`.
28. It is a compile error: "no new variables on left side of :=", because `status` already exists in that scope.
29. `:=`.
30. `=`.

### G. The type rule

31. `port` was created as an `int`, and Go does not allow assigning a `string` value to an `int` variable.
32. `int`.
33. Any reasonable example, e.g. accidentally passing a port number as text into a function expecting a number, or mixing up a boolean flag with a status string.

### H. Applying it

34. `serverName string`, `ipAddress string`, `port int`, `cpuUsage float64`, `reachable bool`.
35. `port := 8080`
36. `healthy := true`
37. `fmt.Println()`.
38. `fmt.Println(cpuUsage)`

</details>

---

