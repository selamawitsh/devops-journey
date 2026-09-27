# Lesson 1 Active Recall: Short-Answer Drill

Source material: `lesson-1-notes.md` and `lesson-1-exercise.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, you have not locked in the concept yet, so go back to the notes for that section only.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat the full drill on day 1, day 3 and day 7. Spaced repetition is what makes it stick.

---

## A. Go and DevOps

1. Which company developed Go?
2. In this roadmap, what is Go mainly used for?
3. Name three things a Go DevOps tool can talk to.
4. Give two problems with checking 50 servers by hand.
5. Name two tools from the roadmap that you will build with Go.
6. When would Bash or Python be a better choice than Go?

## B. Source code to executable

7. What does the compiler turn `main.go` into?
8. Fill in the blank: source code -> ______ -> executable.
9. Fill in the blank: a Go binary generally does not need ______ installed on the target machine.
10. True or false: Go programs have absolutely no dependencies. If false, correct it.
11. Why copy the binary to a server instead of the source code?
12. Which command creates the binary?

## C. package main

13. Every Go file belongs to a what?
14. What kind of program uses `package main`?
15. True or false: every function in Go belongs to `main`. If false, correct it.
16. A file starts with `package aws` and defines `ListInstances`. Which package does that function belong to?
17. Name three packages a DevOps project might have besides `main`.
18. In the reception analogy, what does `package main` represent?

## D. func main()

19. What is `func main()`?
20. Which two things together make a Go executable?
21. True or false: `main.go` is the entry point of the program. If false, correct it.
22. Could `main()` live in a file called `server.go`? Under what condition?

## E. import and fmt

23. What does `import "fmt"` do?
24. What is `fmt`?
25. Read `fmt.Println` in plain English.
26. Where does `Println` send its output?
27. What happens if you import a package and never use it?

## F. go.mod

28. What is a Go module?
29. Which file defines a Go module?
30. Name the two things `go.mod` always records.
31. What will `go.mod` also record later in the roadmap?
32. What is the Node.js equivalent of `go.mod`?
33. Which command creates `go.mod` for a module called `hello-go`?
34. You get `go.mod file not found`. What is the most likely cause and the first command to check?

## G. go run vs go build

35. What two things does `go run` do?
36. Does `go run` leave an executable behind?
37. What does `go build` produce?
38. Your module is `hello-go`. What is the executable called?
39. How do you run that executable?
40. True or false: `go build` downloads dependencies. If false, correct it.
41. Which command do you use for a quick experiment, and which one for something you will ship?
42. You edit `main.go` but do not rebuild. Does `./hello-go` show the change?

## H. Habits and tools

43. What does `go fmt ./...` do?
44. Why do teams care about `go fmt`?
45. Should you commit the compiled binary to Git?
46. Where do you list files that Git should ignore?

## I. Connect the dots

47. Manager: "check whether my 100 servers are reachable." What kind of tool do you build?
48. Put these in the correct order: `go build`, write `main.go`, `./tool`, `go fmt`.
49. Complete the chain: `go.mod` says what the project is, `package main` says ______, `func main()` says ______.
50. In one sentence, explain to a friend why a Go binary is easy to ship.
51. You changed one line and want to test it fast. Which command?

---

## Answer key

<details>
<summary>Try all 51 first, then open</summary>

### A. Go and DevOps

1. Google.
2. Automation and scripting: DevOps tools such as AWS automation, health checkers and CLI tools.
3. Any three of: the AWS API, servers (system commands), other APIs, configuration files.
4. It is slow and error-prone.
5. Any two of: aws-auditor, health-checker, config generator, devopsctl.
6. Quick, short throwaway scripts where writing speed matters more than reliability or distribution.

### B. Source code to executable

7. An executable binary.
8. Compiler.
9. Go.
10. False. Go can compile to a single executable that generally does not need Go installed on the target machine.
11. The server does not need Go or the compiler. It only needs the executable.
12. `go build`.

### C. package main

13. Package.
14. An executable program.
15. False. Every file belongs to a package. Executables use `main`, but functions can live in other packages.
16. `aws`.
17. Any three of: `aws`, `config`, `logger`, `health`, `database`.
18. The front door of the company, the package that makes the program executable.

### D. func main()

19. The entry point: where execution of an executable Go program starts.
20. `package main` and `func main()`.
21. False. The entry point is `func main()` in the `main` package. `main.go` is only the conventional file name.
22. Yes, if that file is in `package main`.

### E. import and fmt

23. It lets the file use functionality from the `fmt` package.
24. A standard library package for formatting and printing.
25. "From the package `fmt`, use the function `Println`."
26. Standard output, normally the terminal.
27. Go refuses to compile it and reports an "imported and not used" error.

### F. go.mod

28. A collection of Go code managed together as one project.
29. `go.mod`.
30. The module name and the Go version.
31. The project's dependencies.
32. `package.json`.
33. `go mod init hello-go`.
34. You are in the wrong directory. Run `pwd`, then `cd` to the project folder. If the folder truly has no `go.mod`, create it with `go mod init`.

### G. go run vs go build

35. It compiles the program and runs it.
36. No, it uses a temporary executable that is discarded.
37. An executable file in the current directory.
38. `hello-go`.
39. `./hello-go`.
40. False. `go build` compiles and produces the executable. Dependency management is a separate concept.
41. `go run` for quick experiments, `go build` for what you ship.
42. No. The binary is a snapshot of the old code. You must run `go build` again.

### H. Habits and tools

43. It formats your code in the official Go style.
44. CI pipelines reject unformatted code, and a single style keeps code consistent across a team.
45. No. It is build output, not source code.
46. In a `.gitignore` file.

### I. Connect the dots

47. A health-check tool that reads the server list, checks each server and prints a report.
48. Write `main.go`, `go fmt`, `go build`, `./tool`.
49. `package main` says "this is an executable"; `func main()` says "start execution here".
50. It compiles into one file that runs on another machine without installing Go or dependencies first.
51. `go run main.go`.

</details>

---
