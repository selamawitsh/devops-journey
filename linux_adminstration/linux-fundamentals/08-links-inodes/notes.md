# Links and Inodes

## What is an inode?
Every file has an inode — a data structure that stores:
- File type, permissions, owner, group
- File size and timestamps
- Pointers to the actual data blocks on disk
The inode does NOT store the filename. The directory stores the filename.

## Hard links
A hard link is another name pointing to the same inode.
- `ln original.txt hardlink.txt`
- Both names point to exactly the same data
- Deleting one does not delete the data — it only removes one name
- The data is deleted only when the last link is removed
- Cannot link across different filesystems
- Cannot link directories

## Symbolic (soft) links
A symbolic link is a file that contains the path to another file.
- `ln -s /etc/hosts myhosts`
- Like a shortcut or alias
- If the original is deleted, the symlink breaks
- Can link across filesystems
- Can link to directories

## Viewing inode numbers
`ls -li` shows inode numbers. Hard links to the same file share the same number.

## Identifying links with ls -l
- Hard link: appears as a regular file, link count > 1
- Symbolic link: shown as `lrwxrwxrwx` with `->` pointing to target

## Why this matters in DevOps
Symbolic links are used everywhere in Linux:
- `/etc/nginx/sites-enabled/` contains symlinks to configs in `sites-available/`
- Python/Node version managers use symlinks to switch versions
- Log rotation creates symlinks
You will create and manage symlinks regularly.
