# chmod — Change File Permissions

## Two methods: symbolic and octal

## Symbolic method
  chmod who+/-/=what file

Who: u (user), g (group), o (other), a (all)
Operator: + (add), - (remove), = (set exactly)
What: r, w, x, X (execute only if dir or already executable)

Examples:
  chmod u+x script.sh        # add execute for owner
  chmod go-w file.txt        # remove write from group and other
  chmod a=r file.txt         # set everyone to read only
  chmod u=rwx,go=r file.txt  # owner all, group+other read only

## Octal method
Each permission is a bit. Add the values:
  r = 4
  w = 2
  x = 1

Three digits: owner | group | other
  chmod 644 file.txt    # owner rw, group r, other r
  chmod 755 script.sh   # owner rwx, group rx, other rx
  chmod 700 private/    # owner rwx, nobody else
  chmod 600 secrets.txt # owner rw only

## Common octal values to memorize
| Octal | Symbolic | Typical use |
|-------|----------|-------------|
| 644 | rw-r--r-- | regular files |
| 755 | rwxr-xr-x | scripts, directories |
| 600 | rw------- | SSH keys, private configs |
| 700 | rwx------ | private directories |
| 777 | rwxrwxrwx | (almost never use this) |
| 640 | rw-r----- | config with group access |

## Recursive chmod
  chmod -R 755 /var/www/html   # apply to all files and subdirectories

## Why this matters in DevOps
- Deploy scripts need execute: `chmod 755 deploy.sh`
- SSH keys must be restricted: `chmod 600 ~/.ssh/id_rsa`
- Web server files: `chmod 644 index.html`
- Wrong chmod breaks deployments and creates security holes
