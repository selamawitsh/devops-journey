# Real-World DevOps Challenge — Links and Inodes

## Scenario
You are managing an Nginx web server. The config system uses symlinks
in `sites-enabled/` pointing to actual configs in `sites-available/`.
This is the real way Nginx works on Ubuntu/Debian servers.

---

## Question 1
Create this structure in `/tmp/nginx_practice/`:
```
sites-available/myapp.conf   (a real file with some text in it)
sites-enabled/               (a directory — symlinks go here)
```

**Commands:**
```
```

---

## Question 2
"Enable" the site by creating a symlink in `sites-enabled/` that
points to `sites-available/myapp.conf`.

**Command:**
```
```
**Verify with:**
```
```

---

## Question 3
Show the inode number of the original config file.
What does the inode number represent?

**Command:**
```
```
**My explanation:**
```
```

---

## Question 4
"Disable" the site by removing only the symlink, NOT the original config.
Verify the original config still exists after removing the symlink.

**Commands:**
```
```

---

## Question 5
What is the difference between a hard link and a symbolic link?
Give one real-world situation where you would use each.

**Hard link:**
```
Use case:
```
**Symbolic link:**
```
Use case:
```

---

## Cleanup
```
rm -rf /tmp/nginx_practice
```
