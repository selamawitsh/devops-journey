# Lesson 3 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.


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

## F. Return values

19. What does `bool` after the parentheses in `func isServerReachable() bool` mean?
20. What keyword sends a value back out of a function?
21. `reachable := isServerReachable()`. If the function returns `true`, what does `reachable` hold?
22. Can a function return a value without a `return` type declared after its parentheses?

## G. Parameter + return together

23. In `func isServerReachable(serverName string) bool`, name the parameter and the return type.
24. Write a one-line call that stores the result of `isServerReachable("api-server")` in a variable called `ok`.
25. In the flow `main() -> isServerReachable() -> return true -> reachable = true`, what value gets passed into the function?

## H. Parameter vs argument vs call

26. In `func checkServer(name string) bool`, is `name` a parameter or an argument?
27. In `checkServer("api-server")`, is `"api-server"` a parameter or an argument?
28. Does writing `func checkServer(name string) bool` alone execute anything?
29. What is the technical name for a line like `checkServer("api-server")` that actually runs the function?

## I. Applying it

30. You need to check reachability, CPU, memory, and then generate a report. Name four functions you would create.
31. Draw the shape (in words) of `main()` calling three functions and combining their results into one report.
32. Write a function signature (not the body) for a function called `checkMemory` that takes a server name as a string and returns a bool.
33. Why is a program built from several small functions easier to debug than one giant `main()`?

---

## Answer key

<details>
<summary>Try all 33 first, then open</summary>

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

### F. Return values

19. The function returns a boolean value.
20. `return`.
21. `true`.
22. No. If a function returns a value, its return type must be declared after the parentheses.

### G. Parameter + return together

23. Parameter: `serverName` (`string`). Return type: `bool`.
24. `ok := isServerReachable("api-server")`.
25. `"api-server"`.

### H. Parameter vs argument vs call

26. Parameter.
27. Argument.
28. No, it only defines what the function looks like.
29. A function call.

### I. Applying it

30. `checkReachability()`, `checkCPU()`, `checkMemory()`, `generateReport()`.
31. `main()` calls `checkServer`, `checkCPU`, and `checkPort`; each returns a result; the three results feed into a report.
32. `func checkMemory(serverName string) bool`.
33. Each function has one job, so when something breaks you know which specific function to check, instead of searching through one long block of code.

</details>

---

