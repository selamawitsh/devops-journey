# Practice — Package Management

Environment: Ubuntu on VMware. Run everything below in order and record real output, not paraphrased.

## 1. Explore the dpkg/apt split

```bash
dpkg -l | head -20
dpkg -l | wc -l

dpkg -s bash
dpkg -L bash | head

apt-cache show curl | head -20
apt-cache depends curl
apt-cache policy curl

ls /var/lib/apt/lists/ | head
cat /etc/apt/sources.list
```

**Expected:** `apt-cache policy curl` shows `Installed:` and `Candidate:` lines. If they differ, an upgrade is available.

**Result:**
```
<paste your actual output here>
```

---

## 2. Add a third-party repo with a GPG key

```bash
sudo apt-get install -y curl gnupg2 ca-certificates lsb-release

curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo gpg --dearmor -o /usr/share/keyrings/nginx-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

sudo apt-get update
apt-cache policy nginx
```

**Expected:** `apt-cache policy nginx` shows a candidate sourced from `nginx.org/packages/ubuntu` rather than Ubuntu's default archive.

**Result:**
```
<paste your actual output here>
```

**Why `signed-by` instead of `apt-key add`:** scopes trust to one repo file instead of trusting a key globally across every repo on the system.

---

## 3. Hold vs pin

```bash
sudo apt-mark hold nginx
apt-mark showhold
sudo apt-get upgrade -y   # nginx should show as "kept back"

sudo tee /etc/apt/preferences.d/nginx-pin <<'EOF'
Package: nginx
Pin: origin nginx.org
Pin-Priority: 1001
EOF

apt-cache policy nginx   # note the priority number next to the candidate

# cleanup
sudo apt-mark unhold nginx
sudo rm /etc/apt/preferences.d/nginx-pin
```

**Expected:** `apt-get upgrade` output includes a `The following packages have been kept back:` line listing `nginx`.

**Result:**
```
<paste your actual output here>
```

| Tool | Scope | When to use |
|---|---|---|
| `apt-mark hold` | one package, one machine | quick, temporary freeze |
| `/etc/apt/preferences.d/` pin | declarative, config-managed | reproducible across servers |

---

## Project deliverable
See `scripts/bootstrap.sh` — an idempotent bootstrap script that installs and pins a defined package set. Run it twice: the second run should report everything already satisfied, not error.
