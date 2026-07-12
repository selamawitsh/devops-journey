# Real-World DevOps Challenge — Managing Files

## Scenario
You are setting up a directory structure for a new application deployment.
You need to create folders, move config files, back up old configs, and
clean up temporary files.

---

## Question 1
Create this directory structure in /tmp with a single command:
```
/tmp/myapp/
    configs/
    logs/
    backups/
```

**Command:**
```bash
mkdir -p /tmp/myapp/{configs,logs,backups}
```

**Explanation:**
The curly braces `{}` with comma-separated names use brace expansion to create all three directories in one command.

**Verify with:**
```bash
ls -R /tmp/myapp
```
or
```bash
tree /tmp/myapp
```

---

## Question 2
Create a file called `app.conf` in `/tmp/myapp/configs/`.
Add a backup copy called `app.conf.bak` in `/tmp/myapp/backups/`.

**Commands:**
```bash
touch /tmp/myapp/configs/app.conf
cp /tmp/myapp/configs/app.conf /tmp/myapp/backups/app.conf.bak
```

**Verify with:**
```bash
ls -l /tmp/myapp/configs/
ls -l /tmp/myapp/backups/
```

---

## Question 3
Rename `app.conf` to `application.conf` without leaving the configs directory.

**Command:**
```bash
cd /tmp/myapp/configs
mv app.conf application.conf
```

**Verify with:**
```bash
ls -l
```

---

## Question 4
Copy the entire `/tmp/myapp/configs/` directory to `/tmp/myapp/configs_old/`.

**Command:**
```bash
cp -r /tmp/myapp/configs /tmp/myapp/configs_old
```

**Explanation:**
The `-r` flag is required to recursively copy directories and their contents.

**Verify with:**
```bash
ls -R /tmp/myapp/
```

---

## Question 5
Delete `/tmp/myapp/configs_old/` and everything inside it.
Then verify it is gone.

**Commands:**
```bash
rm -r /tmp/myapp/configs_old
```

**Verify it's gone:**
```bash
ls /tmp/myapp/
```
or
```bash
ls -d /tmp/myapp/configs_old/
```
This should return: `ls: cannot access '/tmp/myapp/configs_old/': No such file or directory`

---

## Question 6
What is the difference between `rm -r` and `rm -rf`?
When would using `-rf` be dangerous?

**Explanation:**

### `rm -r` (Recursive)
- Deletes directories and their contents recursively
- Will prompt for confirmation before deleting write-protected files
- Safer — it asks "are you sure?" if something is protected
- Gives you a chance to cancel before permanent deletion

### `rm -rf` (Recursive + Force)
- Deletes directories and their contents recursively
- `-f` means "force" — NO prompts, no warnings, no questions asked
- Silently deletes everything, including write-protected files
- No confirmation, no safety net, no undo

```