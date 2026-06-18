# Real-World DevOps Challenge — chmod Solutions

## Question 1
**Symbolic:**
chmod u=rwx,go=rx deploy.sh

**Octal:**
chmod 755 deploy.sh

**Verify:**
ls -l deploy.sh
# Output: -rwxr-xr-x 1 user group ... deploy.sh

---

## Question 2
**Octal:**
chmod 600 server.key

**Why SSH cares:**
SSH refuses to use private keys that are accessible to group or others 
because it considers them insecure. If someone else can read your private key, 
they can impersonate you and access your servers. SSH enforces this by checking 
permissions and aborting with "Permissions 0xxx for 'server.key' are too open" 
if the file is group/other readable or writable.

---

## Question 3
**Command:**
find /var/www/html -type f -exec chmod 644 {} \;

---

## Question 4
**Command:**
chown :www-data config.file
chmod 640 config.file

**Resulting permissions:**
-rw-r----- 1 user www-data ... config.file

---

## Question 5
**My calculations:**
755 = 7(rwx) 5(r-x) 5(r-x) = rwxr-xr-x
644 = 6(rw-) 4(r--) 4(r--) = rw-r--r--
600 = 6(rw-) 0(---) 0(---) = rw-------
640 = 6(rw-) 4(r--) 0(---) = rw-r-----