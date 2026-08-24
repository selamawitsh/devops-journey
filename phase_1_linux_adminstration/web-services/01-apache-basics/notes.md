# 01 — Apache Basics (Ubuntu)

## Mental model first

Every Apache directive answers one of four questions:

1. **Where** on disk do I look for files? → `DocumentRoot`
2. **Who's** allowed to ask? → `Directory`, `AllowOverride`, `Require`
3. **What** do I do when they ask? → modules / handlers
4. **How** do I record what happened? → logs

If a config line doesn't obviously map to one of these four, stop and figure out which one it actually serves — that's usually the fastest way to understand an unfamiliar directive.

---

## 1. Install & service basics (Ubuntu)

```bash
sudo apt update
sudo apt install apache2 -y

sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2
```

Test it's alive:
```bash
curl http://localhost/
```

---

## 2. Config file layout (Ubuntu ≠ RHEL — paths differ!)

```
/etc/apache2/
├── apache2.conf        # main config, pulls everything else in
├── ports.conf          # what ports Apache listens on (Listen 80)
├── sites-available/    # every site config you've defined
├── sites-enabled/      # symlinks = which sites are actually live
├── mods-available/     # every module that could be turned on
├── mods-enabled/       # symlinks = modules actually active
└── conf-enabled/       # small config snippets (ssl-params etc.)
```

Default site: `/etc/apache2/sites-available/000-default.conf`

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

**Key insight:** `DocumentRoot` is a *directive*, not tied to a specific file. It can live inside any `<VirtualHost>` block in any file under `sites-available/`. `000-default.conf` is just the file Apache ships with — once we do virtual hosting (module 03), you'll have many of these.

---

## 3. DocumentRoot — where files live

URL path after the domain maps directly onto a folder path under `DocumentRoot`.

`DocumentRoot /var/www/html` + request for `/shop/item1.html`
→ Apache looks for `/var/www/html/shop/item1.html` on disk. That's it. No magic.

---

## 4. Access control — Directory / AllowOverride / Require

A `<Directory>` block targets a **filesystem path**, not a URL.

```apache
<Directory /var/www/>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
```

- **`Options`** — features turned on for that folder (`Indexes` = show file listing if no index.html exists)
- **`AllowOverride`** — whether a `.htaccess` file in that folder is even *read* by Apache
  - `None` → `.htaccess` is completely ignored, no matter what's in it
  - `AuthConfig` → only auth-related directives (`AuthType`, `AuthName`, `AuthUserFile`, `Require`) are honored
  - `All` → everything in `.htaccess` is honored
- **`Require`** — who's actually allowed in (`all granted`, `all denied`, `valid-user`, `user selam`)

**The #1 gotcha:** `AllowOverride` is a permission for the *config file to exist and matter* — it is NOT the access rule itself. If `AllowOverride None` is set, a perfectly correct `.htaccess` with password rules inside will do absolutely nothing. Apache never reads it.

### Password-protecting a folder end to end

```bash
sudo apt install apache2-utils -y
sudo htpasswd -c /etc/apache2/.htpasswd selam      # -c creates new file (first user only!)
sudo htpasswd /etc/apache2/.htpasswd guest         # no -c = append, don't wipe existing users
```

In the site config:
```apache
<Directory /var/www/html/private>
    AllowOverride AuthConfig
</Directory>
```

In `/var/www/html/private/.htaccess`:
```apache
AuthType Basic
AuthName "Restricted Area"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user
```

```bash
sudo systemctl restart apache2
curl -u selam:yourpassword http://localhost/private/
```

---

## 5. Modules & handlers — what happens when a request comes in

- **Static file** → Apache reads raw bytes off disk, streams them as-is. No processing.
- **Handler-processed file** (e.g. `.php`) → Apache hands the file to an interpreter (module), which *executes* it. The output of execution is what gets sent back — not the source code.

```bash
apache2ctl -M                  # list active modules
sudo a2enmod rewrite           # enable a module
sudo a2dismod rewrite          # disable a module
```

PHP example:
```bash
sudo apt install php libapache2-mod-php -y
ls /etc/apache2/mods-available/ | grep php    # find exact module name/version
sudo a2enmod php8.1
sudo systemctl restart apache2
```

If you forget to enable the module, requesting a `.php` file dumps the raw `<?php ... ?>` source as plain text — proof Apache fell back to treating it as static content.

---

## 6. Logs — how to know what actually happened

Ubuntu path: `/var/log/apache2/` (NOT `/var/log/httpd/` — that's RHEL)

- `access.log` — every request: who, what, status code, timestamp. Confirms *that* something happened.
- `error.log` — what went wrong: missing files, permission denials, script failures. Tells you *why*.

```bash
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log
```

`LogLevel` controls verbosity: `emerg, alert, crit, error, warn (default), notice, info, debug`. Turn up to `debug` only while actively chasing a bug — turn it back down after, debug logging fills disks fast on busy servers.

**Rule of thumb:** a blank page or unexpected behavior → check `error.log` first. A "did this request even happen / what status code came back" question → `access.log`.
