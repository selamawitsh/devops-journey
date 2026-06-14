# Real-World DevOps Challenge — File Permissions

## Scenario
You are auditing permissions on a server to prepare a security report.

---

## Question 1
Run `ls -l /etc/passwd /etc/shadow /etc/hosts`.
For each file, decode the permission string and explain who can do what.

**Output:**
```
```
**My decoding:**
```
/etc/passwd:
  owner can:
  group can:
  others can:

/etc/shadow:
  owner can:
  group can:
  others can:

/etc/hosts:
  owner can:
  group can:
  others can:
```

---

## Question 2
Look at `/usr/bin/passwd` with `ls -l`.
This is the command regular users run to change their password,
but `/etc/shadow` is only writable by root.
How can a regular user change their own password then?
What special character do you see in the permissions?

**Output of ls -l /usr/bin/passwd:**
```
```
**My explanation:**
```
```

---

## Question 3
What permissions does `/tmp` have? What is special about it?
Run `ls -ld /tmp` and decode what you see.

**Output:**
```
```
**Explanation:**
```
```

---

## Question 4
A new file is created by a regular user. What are the default permissions?
Are they the same for a directory? Why is execute on directories important?

**File permissions:**
```
```
**Directory permissions:**
```
```
**Why execute matters on directories:**
```
```

---

## Question 5
What does it mean for a DevOps engineer if a config file has permissions
`-rw-------`? What about `-rw-rw-rw-`? Which is safer and why?

**-rw-------:**
```
```
**-rw-rw-rw-:**
```
```
**Which is safer:**
```
```
