# Module 03 Active Recall: Short-Answer Drill

Source material: `01-lesson-notes.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.


## A. Why files and system info

1. In the memo-on-a-desk analogy, what does the employee represent, and what does the memo represent?
2. Name two reasons a real DevOps tool reads input from a file instead of hardcoding it.

## B. Reading files

3. What two values does `os.ReadFile` return?
4. Why does `os.ReadFile` return `[]byte` instead of `string`?
5. What converts `[]byte` into a readable string?
6. What does `os.Open` give you back, as opposed to `os.ReadFile`?
7. What does `bufio.NewScanner` let you do that `os.ReadFile` alone doesn't?
8. What does `scanner.Scan()` return when there are no more lines?
9. What does `scanner.Text()` give you?

## C. defer

10. What does `defer file.Close()` actually do, and when does it run?
11. Why is deferring cleanup immediately after opening something a good habit?
12. Does `defer` still run if the function returns early, or panics?

## D. Checking existence

13. What does `os.Stat` do?
14. What does `os.IsNotExist(err)` specifically check?
15. Does every file-read error mean the file is missing?

## E. Writing files

16. What does `os.WriteFile` do if the file already exists?
17. What is the third argument to `os.WriteFile`?
18. Write a line that writes `[]byte("hello")` to `"out.txt"` with permission `0644`.

## F. Appending

19. Which function do you use to append to a file instead of overwriting it?
20. What do the flags `os.O_APPEND`, `os.O_CREATE`, and `os.O_WRONLY` each mean?
21. Why are those flags combined with `|` instead of passed as separate arguments?

## G. Buffered writing

22. What does `bufio.NewWriter` wrap?
23. What must you call to make sure buffered data actually reaches the file?
24. What happens if you forget to call it?

## H. Permissions

25. In `0644`, what does each of the three digits (6, 4, 4) represent?
26. What does the digit `6` mean in permission terms?
27. What does the digit `4` mean in permission terms?
28. When would you use `0755` instead of `0644`?
29. What function checks whether a specific error was a permissions problem?

## I. Directories

30. What is the difference between `os.Mkdir` and `os.MkdirAll`?
31. Which one behaves like `mkdir -p`?
32. What does `os.ReadDir` return?
33. What method tells you whether a directory entry is itself a folder?
34. What function should you use to build a file path instead of concatenating strings with `/`?
35. Why does that function matter across different operating systems?

## J. System information

36. Which function returns the machine's hostname?
37. Which two `runtime` values give you the OS and CPU architecture?
38. What does `os.Getenv` return if the variable isn't set?
39. Why is that return value potentially misleading?
40. Which function fixes that problem, using the comma-ok pattern?
41. What does `os.Environ()` return?

## K. Applying it

42. Name three pieces of information a report-writing function might combine: one about input data, one about the machine, one about permissions.
43. Why does a log file typically use append mode, while a report typically uses overwrite mode?

## L. Debugging

44. You get `open servers.txt: no such file or directory` even though the file exists somewhere on your machine. What's the likely cause?
45. Your written file is empty even though you called `WriteString` several times. What did you forget?
46. You meant to add a line to a log but the file got wiped instead. What's the fix?
47. `os.Mkdir("logs/2026")` fails. What's a likely cause, and what's the fix?
48. A path works on your machine but breaks on a teammate's. What's the likely cause?

---

## Answer key

<details>
<summary>Try all 48 first, then open</summary>

### A. Why files and system info

1. The employee is your Go program; the memo is the file it reads.
2. Any two of: it can be edited without touching code, by someone without Go knowledge, without recompiling or redeploying.

### B. Reading files

3. `[]byte` (the data) and `error`.
4. Go doesn't assume a file is text; it could be any kind of binary data.
5. `string(data)`.
6. A `*os.File`, a handle to the open file, rather than the whole content at once.
7. Read the file one line at a time instead of loading it all at once.
8. `false`.
9. The current line, as a string.

### C. defer

10. It closes the file; it runs right before the surrounding function returns, however it returns.
11. You cannot forget to clean up, since it's scheduled immediately, before the rest of the function is even written.
12. Yes, in both cases.

### D. Checking existence

13. Gets information about a file (without reading its contents).
14. Whether the error occurred specifically because the file doesn't exist.
15. No, it could also be a permissions error or something else.

### E. Writing files

16. It overwrites the whole file.
17. The file's permissions (e.g. `0644`).
18. `os.WriteFile("out.txt", []byte("hello"), 0644)`.

### F. Appending

19. `os.OpenFile`.
20. `O_APPEND`: write at the end without erasing existing content. `O_CREATE`: create the file if it doesn't exist. `O_WRONLY`: open for writing only.
21. They're flags being combined (bitwise OR), not separate positional arguments.

### G. Buffered writing

22. An `os.File` (or any writer), to batch writes for efficiency.
23. `writer.Flush()`.
24. Some or all of the buffered data may never actually reach the file.

### H. Permissions

25. Owner, group, others (in that order).
26. Read + write.
27. Read only.
28. When the file needs to be executed, like a compiled binary or script.
29. `os.IsPermission(err)`.

### I. Directories

30. `os.Mkdir` creates one directory and fails if its parent doesn't exist; `os.MkdirAll` creates every missing directory along the path.
31. `os.MkdirAll`.
32. A slice of directory entries.
33. `entry.IsDir()`.
34. `filepath.Join`.
35. Different operating systems use different path separators (`/` vs `\`), and `filepath.Join` handles that automatically.

### J. System information

36. `os.Hostname()`.
37. `runtime.GOOS` and `runtime.GOARCH`.
38. `""`, an empty string.
39. It can't be told apart from a variable that was deliberately set to an empty value.
40. `os.LookupEnv`.
41. Every environment variable as `"KEY=value"` strings.

### K. Applying it

42. Example: the list of servers checked (input data), the hostname (system info), and the file permission used to write the report (`0644`).
43. A log is meant to accumulate a history over time; a report is meant to reflect the latest run only.

### L. Debugging

44. Wrong path, or the program is running from a different working directory than expected.
45. Calling `writer.Flush()` on a `bufio.Writer`.
46. Switch from `os.WriteFile`/`os.Create` to `os.OpenFile` with `O_APPEND|O_CREATE|O_WRONLY`.
47. The parent directory `logs` doesn't exist yet; use `os.MkdirAll` instead.
48. The path was built by concatenating strings with a hardcoded separator instead of `filepath.Join`.

</details>

---

