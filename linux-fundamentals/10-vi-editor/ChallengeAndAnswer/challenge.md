# Real-World DevOps Challenge — vi Editor

## Scenario
The server's only editor is vi. You need to edit a config file during
an incident. No nano, no VSCode — just vi.

---

## Task
Complete ALL of these steps manually in vi. After each step,
write the exact key sequence you used.

---

## Step 1
Open a new file called `/tmp/server_config.conf` in vi.

**Command:**
```
```

---

## Step 2
Enter insert mode and type exactly this content:
```
# Server Configuration
hostname=prod-server-01
port=8080
log_level=INFO
max_connections=100
```

**Key to enter insert mode:**
```
```
**Key to exit insert mode:**
```
```

---

## Step 3
Save the file without quitting.

**Key sequence:**
```
```

---

## Step 4
Go to line 3 (the port line). Delete the entire line.

**How to navigate to line 3:**
```
```
**How to delete the line:**
```
```

---

## Step 5
Search for the word "INFO" and change it to "DEBUG".

**Search command:**
```
```
**How I changed it:**
```
```

---

## Step 6
Save and quit.

**Key sequence:**
```
```

---

## Step 7
Verify the file contents from the shell (not vi).

**Command:**
```
```
**Output:**
```
```

---

## Self-Assessment
- [ ] I can open, edit, and save a file in vi without help
- [ ] I know the three modes and how to switch between them
- [ ] I still feel uncomfortable with vi (that is okay — keep practicing)
