# chown and chgrp — Change Ownership

## chown — change owner and/or group
  chown owner file          # change owner only
  chown owner:group file    # change owner and group
  chown :group file         # change group only
  chown -R owner:group dir  # recursive

## chgrp — change group only
  chgrp groupname file      # equivalent to chown :group file

## Who can use chown?
- Only root can change a file's owner
- Regular users can change a file's group ONLY if they belong to both
  the current group and the target group

## Checking current ownership
  ls -l file        # shows owner and group
  stat file         # detailed info including ownership
  id                # shows your current user and groups

## Practical examples
```bash
# Give a file to the web server user
chown www-data:www-data /var/www/html/index.html

# Give a directory to a deploy user, recursively
chown -R deploy:deploy /opt/myapp/

# Change group so team members can access logs
chown root:developers /var/log/myapp.log
chmod 640 /var/log/myapp.log

# Fix ownership after copying files as root
chown -R john:john /home/john/
```

## Why this matters in DevOps
Web server files must be owned by `www-data`. Application files
must be owned by the service account. After deploying as root,
you must fix ownership. Getting this wrong breaks applications.
