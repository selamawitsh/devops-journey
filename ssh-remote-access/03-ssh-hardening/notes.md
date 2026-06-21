# SSH Hardening — sshd_config

## The config file
The SSH SERVER's behavior is controlled by:
  /etc/ssh/sshd_config

After ANY change to this file, you must reload the service:
  systemctl reload sshd

## Why disable direct root login
| Risk | Explanation |
|------|-------------|
| Predictable target | "root" exists on every Linux system by default — attacker only needs to guess the password, not the username too |
| Unlimited blast radius | root has full system control — a compromised root login is total compromise |
| No accountability | if everyone logs in directly as root, you can't tell WHO did WHAT from logs |

The fix — force everyone to log in as a named regular user first,
then `su -` or `sudo` to get elevated access when actually needed.
That action is logged and attributable to a real person.

## PermitRootLogin setting
  PermitRootLogin yes              # default — root can log in directly (bad practice)
  PermitRootLogin no                # root cannot SSH in at all
  PermitRootLogin without-password  # root can SSH in ONLY with a key, never a password

## Why disable password authentication entirely
| Risk with passwords | Why keys are better |
|---------------------|---------------------|
| Brute-force / guessing attacks | A private key can't be "guessed" the way a weak password can |
| Only ONE secret needed (the password) | An attacker needs BOTH the private key file AND its passphrase |
| Vulnerable to phishing | There's nothing to "type" that can be phished |

## PasswordAuthentication setting
  PasswordAuthentication yes    # default — passwords allowed
  PasswordAuthentication no     # only key-based auth allowed

## PubkeyAuthentication
  PubkeyAuthentication yes      # usually the default, often left commented out

A commented-out line in sshd_config means "using the default value" —
it does NOT mean the feature is off. You have to know the defaults to
correctly read a config file that relies on them.

## The order ssh tries authentication methods
By default ssh tries key-based authentication FIRST. If that fails
(no key configured for that user), it falls back to password
authentication — UNLESS PasswordAuthentication is set to no, in which
case there is no fallback at all.

## The exact hardening workflow
1. Set up key-based auth and CONFIRM it works for at least one admin
   user before doing anything else (so you don't lock yourself out!)
2. Set PermitRootLogin to no
3. Reload sshd, test that root login is now refused
4. Set PasswordAuthentication to no
5. Reload sshd, test that a user without keys is now refused, and a
   user WITH keys still works fine

## Why this matters in DevOps
This is one of the very first things done when securing any new
production server. Getting the order wrong (disabling password auth
before confirming key auth works) can permanently lock everyone out
of a server with no recovery except console/physical access.
