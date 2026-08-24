# Real-World DevOps Challenge — File Permissions

## Scenario
You are auditing permissions on a server to prepare a security report.

---

## Question 1
Run `ls -l /etc/passwd /etc/shadow /etc/hosts`.
For each file, decode the permission string and explain who can do what.

**Output:**
```
selamawit@selamawit-ThinkPad-T490:~$ ls -l /etc/passwd
-rw-r--r-- 1 root root 3052 May 28 17:12 /etc/passwd
```

```
selamawit@selamawit-ThinkPad-T490:~$ ls -l /etc/shadow
-rw-r----- 1 root shadow 1479 Jun  5 17:00 /etc/shadow

```

```
selamawit@selamawit-ThinkPad-T490:~$ ls -l /etc/hosts
-rw-r--r-- 1 root root 238 Mar 12 21:57 /etc/hosts

```
**My decoding:**
```
/etc/passwd:
  owner can:read and write but not excute and the owner is root also has a primary group root
  group can: only read which is memebers of root group
  others can: only read 

/etc/shadow:
  owner can:can read and werite and the owner is root and the group is shadow
  group can: group members of shadow can only read 
  others can: it has no permission on the file

/etc/hosts:
  owner can: the owner has read and write permission on this directory, the owner is root
  group can:the group has only read permission and the group is root
  others can: others can only read to this directory
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
selamawit@selamawit-ThinkPad-T490:~$ ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 64152 May 30  2024 /usr/bin/passwd


```
**My explanation:**
```
because we have permission of s which is special permission which allow us to edited it as a root not as a regular user setuid
```

---

## Question 3
What permissions does `/tmp` have? What is special about it?
Run `ls -ld /tmp` and decode what you see.

**Output:**
```
selamawit@selamawit-ThinkPad-T490:~$ ls -ld /tmp
drwxrwxrwt 31 root root 12288 Jun 15 12:49 /tmp


```
**Explanation:**
```
t is stand for stickybits Users can delete only their own files, even though everyone has write permission.
```

---

## Question 4
A new file is created by a regular user. What are the default permissions?
Are they the same for a directory? Why is execute on directories important?

**File permissions:**
```
644 - rw-r--r--: users or owners have read and write default permission and group and other have read default permission
```
**Directory permissions:**
```
755 -rwx r-x r-x: users have full permission and groups and others have read and excute default permission
```
**Why execute matters on directories:**
```
Without execute: cd directory fails. Even if you can read it.
```

---

## Question 5
What does it mean for a DevOps engineer if a config file has permissions
`-rw-------`? What about `-rw-rw-rw-`? Which is safer and why?

**-rw-------:**
```
i think this is safer because only the owner can access it.
```
**-rw-rw-rw-:**
```
```
**Which is safer:**
```
-rw-------:
```
