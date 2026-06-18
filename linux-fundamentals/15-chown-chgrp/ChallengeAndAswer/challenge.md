# Real-World DevOps Challenge — chown and chgrp

## Scenario
You deployed a web application as root. Now the files are owned by root
but your web server runs as `www-data`. The app is returning permission
errors. You need to fix the ownership.

---

## Question 1
Check who owns the files in `/var/www/html/` (if it exists on your system).
Who should own them for a typical Nginx/Apache setup?

**Command:**
```
```
**Output:**
```
```
**Who should own them:**
```
```

---

## Question 2
Write the command to change ownership of `/tmp/myapp/` and all its
contents to user `www-data` and group `www-data`.

**Command:**
```
```

---

## Question 3
You created a log file as root. Your application (running as `appuser`)
needs to write to it. You want the file owned by root but the `appgroup`
group to have write access. Write the chown and chmod commands.

**chown command:**
```
```
**chmod command:**
```
```
**Resulting permissions:**
```
```

---

## Question 4
What is the difference between `chown user:group file` and
`chown user file` and `chown :group file`?

**My explanation:**
```
chown user:group  =
chown user        =
chown :group      =
```

---

## Question 5
Why can only root change a file's owner, but regular users can sometimes
change a file's group? What is the security reason behind this?

**My answer:**
```
```
