# Real-World DevOps Challenge — chmod

## Scenario
You are setting up a new server. You need to configure permissions
correctly for security and functionality.

---

## Question 1
You have a deployment script `deploy.sh`. Set it so the owner can
read, write, and execute — but group and others can only read and execute.
Use BOTH the symbolic method and the octal method.

**Symbolic:**
```
```
**Octal:**
```
```
**Verify:**
```
```

---

## Question 2
You created a private key file `server.key`. It must be readable ONLY
by the owner and nobody else. What octal value achieves this?
Why does SSH refuse to work if this file is too permissive?

**Octal:**
```
```
**Why SSH cares:**
```
```

---

## Question 3
A web server serves files from `/var/www/html/`. Files should be readable
by everyone but only writable by the owner. Set this with a single recursive command.

**Command:**
```
```

---

## Question 4
You have a configuration file that should be readable by the owner and the
`www-data` group, but not by anyone else. Set this up.

**Command:**
```
```
**Resulting permissions:**
```
```

---

## Question 5
Decode these octal permissions without using any tools — just calculate:
- 755 → symbolic:rwxr-xr-x
- 644 → symbolic:rw-r--r--
- 600 → symbolic:rw-------
- 640 → symbolic:rw-r-----

**My calculations:**
```
755 = 7(rwx) 5(r-x) 5(r-x) = rwxr-xr-x
644 =
600 =
640 =
```
