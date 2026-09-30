# Module 02 Active Recall: Short-Answer Drill

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

---

## A. Why packages

1. What problem does splitting code into packages solve?
2. In the department analogy, what does `main` do versus what other packages do?
3. Can two people work more easily on separate packages than on one giant `main.go`? Why?

## B. What a package is

4. What line, present in every Go file, declares its package?
5. Is `package main` special syntax only for executables, or does every file need a package line?
6. Can a non-`main` package be run directly with `go run`?
7. What is a non-`main` package meant to be used for instead?

## C. One folder, one package

8. How many different `package` names can exist in one ordinary folder?
9. Can files in the same package call each other's functions without an import?
10. Name the one kind of file that is an exception to the one-package-per-folder rule.

## D. Module path and imports

11. What line in `go.mod` defines the module path?
12. Given `module github.com/selamawit/devopsctl` and a folder `config/`, what is the full import path?
13. What determines the name you use to call into an imported package, e.g. `aws.ListInstances()`?
14. Why should a package's name match its folder name?

## E. Exported vs unexported

15. What single thing determines whether a function is exported or unexported in Go?
16. Is `ListInstances` exported or unexported?
17. Is `fetchFromAPI` exported or unexported?
18. Can `main.go` call `aws.fetchFromAPI()`? Why or why not?
19. What compile error would you get if you tried?
20. Does Go have `private` and `public` keywords?
21. Why might a package deliberately keep a helper function unexported?

## F. go mod tidy

22. What does `go mod tidy` add?
23. What does `go mod tidy` remove?
24. Which two files does `go mod tidy` update?
25. When should you run `go mod tidy`, as a habit?

## G. Naming conventions

26. Should package names be short or descriptive-but-long?
27. Should package names be lowercase or mixed case?
28. Should package names use underscores?
29. Name two package names considered bad practice in Go, and explain why.

## H. Debugging

30. You see `found packages aws and config in the same folder`. What's the fix?
31. You see `undefined: aws.ListInstances`. Name two possible causes.
32. You see `no required module provides package ...`. What should you compare?
33. You see `import cycle not allowed`. What does this mean, in your own words?
34. What is a common fix for an import cycle?

---

## Answer key

<details>
<summary>Try all 34 first, then open</summary>

### A. Why packages

1. It separates code by responsibility so a large project doesn't become one unmanageable file, and makes it easier for multiple people to work on it at once.
2. `main` coordinates and starts the program; other packages handle specific responsibilities like AWS, config, or logging.
3. Yes, because each package is its own folder/area of responsibility, so changes in one don't collide with changes in another.

### B. What a package is

4. The `package` declaration on the first line of the file.
5. Every file needs a package line; `package main` is not special syntax, just the specific name reserved for executables.
6. No.
7. To be imported and used by other packages.

### C. One folder, one package

8. One.
9. Yes, no import needed.
10. `_test.go` files (covered later in the testing module).

### D. Module path and imports

11. The `module` line.
12. `github.com/selamawit/devopsctl/config`.
13. The package's folder/package name.
14. So the name used to call into it makes sense and isn't confusing or mismatched.

### E. Exported vs unexported

15. The capitalization of the first letter.
16. Exported.
17. Unexported.
18. No, because `fetchFromAPI` starts with a lowercase letter, making it private to its own package.
19. `fetchFromAPI is not exported`.
20. No, capitalization is the only access control mechanism.
21. To keep it as an internal implementation detail that other packages shouldn't depend on directly.

### F. go mod tidy

22. Missing dependencies your code actually imports.
23. Dependencies listed in `go.mod` that are no longer used.
24. `go.mod` and `go.sum`.
25. After adding or removing any import, as a regular habit, not a one-time setup step.

### G. Naming conventions

26. Short.
27. Lowercase.
28. No.
29. `utils` and `helpers`, because they are vague and become a dumping ground for unrelated code instead of being organized around one responsibility.

### H. Debugging

30. Make sure every file in that folder declares the same package name.
31. The function is unexported (lowercase), it's misspelled, or it isn't actually defined in that package.
32. The import path used in code against the `module` line in `go.mod`.
33. Two (or more) packages depend on each other circularly, e.g. package A imports B, and B imports A back.
34. Redesign the structure, often by extracting the shared code both packages need into a third package that both can import.

</details>

---
