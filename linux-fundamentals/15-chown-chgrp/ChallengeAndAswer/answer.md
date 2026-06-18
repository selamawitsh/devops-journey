# Real-World DevOps Challenge — chown and chgrp Solutions

## Question 1
**Command:**
ls -la /var/www/html/

**Output:**
drwxr-xr-x 2 root root 4096 Jun 18 10:00 .
-rw-r--r-- 1 root root  256 Jun 18 10:00 index.html

**Who should own them:**
For Nginx/Apache, files should typically be owned by www-data:www-data
(or the web server user/group of your distribution). Root-owned files
prevent the web server from reading/serving them properly.

---

## Question 2
**Command:**
chown -R www-data:www-data /tmp/myapp/

---

## Question 3
**chown command:**
chown root:appgroup app.log

**chmod command:**
chmod 660 app.log
# or chmod g+w app.log (if starting from 640)

**Resulting permissions:**
-rw-rw---- 1 root appgroup ... app.log

---

## Question 4
**My explanation:**
chown user:group  = Changes both owner AND group simultaneously
chown user        = Changes ONLY the owner, group remains unchanged
chown :group      = Changes ONLY the group, owner remains unchanged

---

## Question 5
**My answer:**
Only root can change a file's owner because of security — preventing
users from giving away files to others to bypass disk quotas or hide
malicious files. Regular users can change a file's group only if they
own the file AND are a member of the target group. This prevents users
from granting group access to unauthorized groups while still allowing
legitimate collaboration.