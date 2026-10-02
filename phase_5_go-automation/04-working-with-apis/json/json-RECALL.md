# Topic Active Recall: JSON

Source material: `README.md`.

Every question needs a short answer: one word, one line, or one sentence. If you cannot answer in one line, that concept has not sunk in yet, so revisit that section of the notes.

## How to use this file

1. Cover the notes. Answer out loud or on paper. Do not peek.
2. Check the answer key at the bottom. Mark each miss.
3. Redo only the missed questions.
4. Repeat on day 1, day 3 and day 7.

---

## A. What JSON is

1. What does JSON stand for?
2. Is JSON specific to JavaScript?
3. Why do APIs commonly use JSON?

## B. JSON structure

4. What does `{}` represent in JSON?
5. What does `[]` represent in JSON?
6. What Go concept is a JSON object similar to, in terms of key-value pairs?
7. What Go type could represent a JSON array of servers?

## C. JSON types to Go types

8. What Go type matches a JSON string?
9. What Go type matches a JSON number with a decimal?
10. What Go type matches a JSON boolean?
11. What does JSON `null` represent?

## D. encoding/json basics

12. What package do you import for JSON handling in Go?
13. What is the term for converting JSON into Go data?
14. What is the term for converting Go data into JSON?

## E. json.Unmarshal

15. Write the line that unmarshals `data` into a `Server` struct variable called `server`.
16. What does `json.Unmarshal` return?
17. Why do you pass `&server` instead of `server`?
18. Before `Unmarshal` runs, what are the struct's field values?
19. After it runs successfully, what are they?

## F. JSON tags

20. Why might a JSON key not automatically match a Go struct field?
21. Write a struct field for `Name` that maps to the JSON key `"server_name"`.
22. Why are JSON tags common in real API code, instead of renaming Go fields to match the API exactly?

## G. From HTTP response to struct

23. What are the four steps from `res.Body` to a populated struct, using `Unmarshal`?
24. What does `io.ReadAll(res.Body)` give you before decoding?

## H. json.Decoder

25. Write the one-line form that decodes directly from `res.Body` into `&server`.
26. What does `Unmarshal` require that `Decoder` doesn't?
27. When is `Decoder` usually more convenient than `Unmarshal` for HTTP API clients?

## I. Real API example

28. In the real API example, what does the client's `Timeout` protect against?
29. What check happens right after `client.Do`, before attempting to decode?
30. Why check the status code before decoding the body?

## J. Debugging

31. All your struct's fields are still zero after `Unmarshal`, and no error was returned. What's the most likely cause?
32. Some fields populate correctly, others stay zero. What's the most likely cause?
33. You get `invalid character ... looking for beginning of value`. What should you check first?
34. A struct field is lowercase. Will `encoding/json` be able to fill it?
35. A JSON number has a decimal point but your struct field is `int`. What's wrong with that?

---

## Answer key

<details>
<summary>Try all 35 first, then open</summary>

### A. What JSON is

1. JavaScript Object Notation.
2. No, it's a general-purpose data format used across almost every language.
3. It's human-readable and almost every language can parse it, making it a convenient shared format between systems.

### B. JSON structure

4. A JSON object.
5. A JSON array.
6. A Go map (key-value pairs).
7. `[]Server`, a slice of structs.

### C. JSON types to Go types

8. `string`.
9. `float64`.
10. `bool`.
11. No value / the absence of a value.

### D. encoding/json basics

12. `encoding/json`.
13. Unmarshaling (decoding).
14. Marshaling (encoding).

### E. json.Unmarshal

15. `err := json.Unmarshal(data, &server)`.
16. An `error`.
17. Because `Unmarshal` needs to modify the struct to fill it with decoded data, and that requires the struct's address.
18. Their zero values (`""`, `0`, `false`, depending on type).
19. The actual values decoded from the JSON.

### F. JSON tags

20. The JSON key uses a different naming style (e.g. snake_case) than the Go field name.
21. `Name string \`json:"server_name"\``.
22. It keeps Go field names clean and idiomatic while still correctly mapping to whatever naming convention the API actually uses.

### G. From HTTP response to struct

23. `res.Body` -> `io.ReadAll()` -> `[]byte` -> `json.Unmarshal()` -> Go struct.
24. The raw response body as `[]byte`.

### H. json.Decoder

25. `err := json.NewDecoder(res.Body).Decode(&server)`.
26. The JSON already loaded into memory as `[]byte`.
27. When decoding directly from a stream like an HTTP response body, skipping the separate `io.ReadAll` step.

### I. Real API example

28. The program hanging indefinitely if the server never responds.
29. Checking `res.StatusCode` against `http.StatusOK`.
30. So you don't try to decode an error page or empty body as if it were valid JSON.

### J. Debugging

31. `server` was passed instead of `&server`.
32. JSON key names don't match the Go struct's field names, and no JSON tags were added for the mismatched ones.
33. Whether the response body is actually valid JSON — print the raw body before decoding.
34. No, `encoding/json` can't see or fill unexported (lowercase) fields.
35. The JSON value will fail to decode cleanly into an `int`; the field's Go type should be `float64` to match a decimal JSON number.

</details>

---

## Self-score

| Section | Questions | Day 1 | Day 3 | Day 7 |
|---|---|---|---|---|
| A. What JSON is | 1-3 | /3 | /3 | /3 |
| B. JSON structure | 4-7 | /4 | /4 | /4 |
| C. JSON types to Go types | 8-11 | /4 | /4 | /4 |
| D. encoding/json basics | 12-14 | /3 | /3 | /3 |
| E. json.Unmarshal | 15-19 | /5 | /5 | /5 |
| F. JSON tags | 20-22 | /3 | /3 | /3 |
| G. From HTTP response to struct | 23-24 | /2 | /2 | /2 |
| H. json.Decoder | 25-27 | /3 | /3 | /3 |
| I. Real API example | 28-30 | /3 | /3 | /3 |
| J. Debugging | 31-35 | /5 | /5 | /5 |
| Total | 35 | /35 | /35 | /35 |

Target: 31 or more out of 35 on day 7. Any section below 80 percent, go back to that part of `README.md`.
