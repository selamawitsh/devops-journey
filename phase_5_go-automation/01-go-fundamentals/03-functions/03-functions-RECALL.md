# Lesson 3 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat on day 1, day 3 and day 7.

---

## A. Why functions

1. Your manager says "check all our servers." Name three separate jobs hidden inside that one sentence.
2. Why would a DevOps engineer use functions instead of putting everything inside `main()`?
3. In the labeled-worker analogy, what does `checkCPU()` represent?

## B. What a function is

4. In one sentence, what is a function?
5. What does `func sayHello() { fmt.Println("Hello") }` define?
6. Does defining that function print anything by itself?
7. What line actually makes it run?

## C. Function anatomy

8. What keyword starts a function definition?
9. Where do a function's parameters go?
10. What symbol pair marks the function body?
11. List the four parts of a function declaration, in order.

## D. Calling a function

12. True or false: defining a function automatically executes it.
13. In `main() -> sayHello() -> print "Hello"`, which one runs first?
14. If `sayHello()` is defined but never called anywhere, what gets printed?

## E. Parameters

15. In `func checkServer(serverName string)`, what is `serverName` called?
16. In `checkServer("api-server")`, what is `"api-server"` called?
17. What type is the `serverName` parameter?
18. Write a one-line call to `checkServer` for a server named `"db-01"`.
19. Can a function take more than one parameter? Write a signature for `checkServer` taking a name (string) and a port (int).

## F. Return values

20. What does `bool` after the parentheses in `func isServerReachable() bool` mean?
21. What keyword sends a value back out of a function?
22. `reachable := isServerReachable()`. If the function returns `true`, what does `reachable` hold?
23. Can a function return a value without a return type declared after its parentheses?
24. If a function has no return type at all, like `sayHello()`, what does it do instead of returning something?

## G. Parameter + return together

25. In `func isServerReachable(serverName string) bool`, name the parameter and the return type.
26. Write a one-line call that stores the result of `isServerReachable("api-server")` in a variable called `ok`.
27. In the flow `main() -> isServerReachable() -> return true -> reachable = true`, what value gets passed into the function?

## H. Parameter vs argument vs call

28. In `func checkServer(name string) bool`, is `name` a parameter or an argument?
29. In `checkServer("api-server")`, is `"api-server"` a parameter or an argument?
30. Does writing `func checkServer(name string) bool` alone execute anything?
31. What is the technical name for a line like `checkServer("api-server")` that actually runs the function?

## I. Applying it

32. You need to check reachability, CPU, memory, and then generate a report. Name four functions you would create.
33. Draw the shape (in words) of `main()` calling three functions and combining their results into one report.
34. Write a function signature (not the body) for a function called `checkMemory` that takes a server name as a string and returns a bool.
35. Why is a program built from several small functions easier to debug than one giant `main()`?

## J. Multiple return values (preview)

36. Write a function signature for `checkServer` that takes a name (string) and returns both a `bool` and a `string`.
37. In `reachable, message := checkServer("api-server")`, how many values does the right-hand side produce, and how many variables receive them?
38. What does this preview foreshadow about how functions in Lesson 8 will return errors?
39. In `func checkServer(name string) (bool, string)`, which return value comes first, and which comes second?

## K. Function naming conventions

40. What casing style does Go use for function names: camelCase or snake_case?
41. Should a function name start with a verb or a noun? Give an example of each.
42. What three prefixes are conventional for a function that returns a `bool`?
43. Why does naming a boolean-returning function `isServerReachable` (instead of `serverReachable`) make an `if` statement easier to read?

## L. Debugging functions

44. You called a function but nothing happened. What's the most likely cause?
45. You get `not enough arguments in call to checkServer`. What's the fix?
46. What should you compare side by side if a function's result looks wrong and you suspect a parameter/argument mix-up?
47. The compiler complains about a function's return. What's the first thing to check?
48. You notice two functions that do almost the same thing. What should you consider instead of keeping both?

---

## Answer key

<details>
<summary>Try all 48 first, then open</summary>

### A. Why functions

1. Any three of: check reachability, check port, check CPU, check memory, create a report.
2. To break the program into small, clear, reusable pieces instead of one giant block of code.
3. A small worker with one job: checking CPU usage.

### B. What a function is

4. A named block of code that performs a particular task.
5. A function named `sayHello` that prints "Hello".
6. No.
7. `sayHello()`, the call.

### C. Function anatomy

8. `func`.
9. Inside the parentheses `()`.
10. Curly braces `{ }`.
11. `func`, name, parameters, body.

### D. Calling a function

12. False.
13. `main()`.
14. Nothing.

### E. Parameters

15. A parameter.
16. An argument.
17. `string`.
18. `checkServer("db-01")`.
19. Yes. `func checkServer(name string, port int) { ... }`.

### F. Return values

20. The function returns a boolean value.
21. `return`.
22. `true`.
23. No. If a function returns a value, its return type must be declared after the parentheses.
24. It just performs an action, like printing, without sending any value back.

### G. Parameter + return together

25. Parameter: `serverName` (`string`). Return type: `bool`.
26. `ok := isServerReachable("api-server")`.
27. `"api-server"`.

### H. Parameter vs argument vs call

28. Parameter.
29. Argument.
30. No, it only defines what the function looks like.
31. A function call.

### I. Applying it

32. `checkReachability()`, `checkCPU()`, `checkMemory()`, `generateReport()`.
33. `main()` calls `checkServer`, `checkCPU`, and `checkPort`; each returns a result; the three results feed into a report.
34. `func checkMemory(serverName string) bool`.
35. Each function has one job, so when something breaks you know which specific function to check, instead of searching through one long block of code.

### J. Multiple return values (preview)

36. `func checkServer(name string) (bool, string)`.
37. Two values are produced, and two variables (`reachable`, `message`) receive them, in the same order.
38. That a function can return a result and an error together, with `error` taking the place of the second value.
39. The `bool` comes first, the `string` comes second — same order as listed in the parentheses.

### K. Function naming conventions

40. camelCase.
41. A verb, e.g. `checkServer` (verb-first) rather than `serverCheck` (noun-first).
42. `is`, `has`, `can`.
43. Because it reads naturally in an `if` statement: `if isServerReachable(name) { ... }` reads almost like English, while `if serverReachable(name)` does not clearly signal a true/false check.

### L. Debugging functions

44. The function was only defined, never actually called.
45. Compare the function's signature to the call and add the missing argument.
46. The function's definition (parameters) versus the call site (arguments).
47. Whether every code path in the function has a `return` matching the declared return type.
48. Whether a single function with an extra parameter could replace both, instead of keeping near-duplicate functions.

</details>

---

## Self-score

| Section | Questions | Day 1 | Day 3 | Day 7 |
|---|---|---|---|---|
| A. Why functions | 1-3 | /3 | /3 | /3 |
| B. What a function is | 4-7 | /4 | /4 | /4 |
| C. Function anatomy | 8-11 | /4 | /4 | /4 |
| D. Calling a function | 12-14 | /3 | /3 | /3 |
| E. Parameters | 15-19 | /5 | /5 | /5 |
| F. Return values | 20-24 | /5 | /5 | /5 |
| G. Parameter + return together | 25-27 | /3 | /3 | /3 |
| H. Parameter vs argument vs call | 28-31 | /4 | /4 | /4 |
| I. Applying it | 32-35 | /4 | /4 | /4 |
| J. Multiple return values | 36-39 | /4 | /4 | /4 |
| K. Naming conventions | 40-43 | /4 | /4 | /4 |
| L. Debugging | 44-48 | /5 | /5 | /5 |
| Total | 48 | /48 | /48 | /48 |

Target: 42 or more out of 48 on day 7. Any section below 80 percent, go back to that part of `README.md`.
