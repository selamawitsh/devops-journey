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
```bash
mkdir -p /tmp/nginx_practice/{sites-available,sites-enabled}
echo "server { listen 80; server_name myapp.com; root /var/www/myapp; }" > /tmp/nginx_practice/sites-available/myapp.conf
```

**Explanation:**
- `mkdir -p` creates both directories at once using brace expansion
- `echo "..." > file` creates the config file with some sample Nginx configuration text

**Verify with:**
```bash
ls -R /tmp/nginx_practice/
cat /tmp/nginx_practice/sites-available/myapp.conf
```

---

## Question 2
"Enable" the site by creating a symlink in `sites-enabled/` that
points to `sites-available/myapp.conf`.

**Command:**
```bash
ln -s /tmp/nginx_practice/sites-available/myapp.conf /tmp/nginx_practice/sites-enabled/myapp.conf
```

**Explanation:**
- `ln -s` creates a symbolic link (symlink)
- Syntax: `ln -s <target> <link-name>`
- Always use absolute paths for symlinks to avoid broken links when directories move
- This is exactly how `nginx` enable sites: `ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/`

**Verify with:**
```bash
ls -l /tmp/nginx_practice/sites-enabled/
```
Output should show:
```
lrwxrwxrwx 1 user user 52 Jan 15 10:00 myapp.conf -> /tmp/nginx_practice/sites-available/myapp.conf
```

The `->` indicates it's a symlink pointing to the original file.

**Alternative verification:**
```bash
readlink /tmp/nginx_practice/sites-enabled/myapp.conf
```
This shows where the symlink points to.

---

## Question 3
Show the inode number of the original config file.
What does the inode number represent?

**Command:**
```bash
ls -i /tmp/nginx_practice/sites-available/myapp.conf
```
or
```bash
stat /tmp/nginx_practice/sites-available/myapp.conf
```

**Example output (ls -i):**
```
1234567 /tmp/nginx_practice/sites-available/myapp.conf
```

**Example output (stat):**
```
  File: /tmp/nginx_practice/sites-available/myapp.conf
  Size: 68        	Blocks: 8          IO Block: 4096   regular file
Device: 801h/2049d	Inode: 1234567     Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/   user)   Gid: ( 1000/   user)
...
```

**My explanation:**
```
An inode (index node) is a data structure that stores metadata about a file,
including:
- File type (regular file, directory, symlink, etc.)
- Permissions (read/write/execute)
- Owner and group
- File size
- Timestamps (creation, last access, last modification)
- Pointers to the actual data blocks on disk

Every file and directory has a unique inode number within its filesystem.
The inode number is like a "license plate" for a file — it uniquely identifies
the file on that filesystem. The filename is just a human-readable label that
points to the inode. Multiple filenames (hard links) can point to the same inode.

Key insight: The inode does NOT store the filename! Filenames are stored in
directory entries that map names to inode numbers.
```

**Show inode of symlink vs original:**
```bash
ls -i /tmp/nginx_practice/sites-available/myapp.conf /tmp/nginx_practice/sites-enabled/myapp.conf
```
Notice the symlink has a different inode number than the original — this proves they are separate files.

---

## Question 4
"Disable" the site by removing only the symlink, NOT the original config.
Verify the original config still exists after removing the symlink.

**Commands:**
```bash
rm /tmp/nginx_practice/sites-enabled/myapp.conf
```

**Verify the symlink is gone:**
```bash
ls -l /tmp/nginx_practice/sites-enabled/
```
Should show empty directory.

**Verify the original config still exists:**
```bash
ls -l /tmp/nginx_practice/sites-available/myapp.conf
cat /tmp/nginx_practice/sites-available/myapp.conf
```
The original file is untouched!

**Important note:**
Always use `rm` (NOT `rm -r`) when removing symlinks. Using `rm -r` on a symlink to a directory will delete the contents of the target directory, not just the link!

---

## Question 5
What is the difference between a hard link and a symbolic link?
Give one real-world situation where you would use each.

**Hard link:**
```
A hard link is a direct reference to the same inode as the original file.
Multiple hard links share the same inode number and same data blocks on disk.
If you delete the "original" file, the data still exists through any remaining
hard link. All hard links are equal — there's no "original" vs "copy" distinction.

Limitations:
- Cannot span across different filesystems
- Cannot link to directories (except for . and .. created by system)
- All links must be on the same partition
```

**Use case:**
```
Creating backup snapshots without using extra disk space. For example, using
rsync with --link-dest to create incremental backups where unchanged files
are hard-linked to previous backups. Tools like rsync, rsnapshot, and Apple's
Time Machine use hard links to save space while maintaining full directory
structures for each backup point in time.
```

**Symbolic link:**
```
A symbolic link (symlink) is a special file that contains a path reference to
another file or directory. It has its own inode and stores the text path to
the target. If you delete the target file, the symlink becomes "broken" or
"dangling" and points to nothing. Symlinks can span filesystems and can link
to directories.
```

**Use case:**
```
Managing Nginx/Apache website configurations (sites-enabled -> sites-available).
This allows administrators to enable/disable sites by simply adding or removing
symlinks without modifying or deleting the actual configuration files. Also
commonly used for version management (e.g., /usr/bin/python -> /usr/bin/python3.9)
and creating accessible shortcuts to deeply nested paths.
```

---
