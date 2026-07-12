#!/usr/bin/env bash
# Practice script for user/group management.
# WARNING: this script creates system users/groups. Run in a VM or container.
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
	echo "This script must be run as root (or with sudo). Exiting." >&2
	exit 1
fi

# Configuration
EXPIRE_DATE="$(date -d '+6 months' +%F)"
BASE_HOME="/new1"

# ===========================================================
# STEP 1 — Create a group
# ===========================================================
# Create group 'hacker' with GID 1200
groupadd -g 1200 hacker || true


# ===========================================================
# STEP 2 — Customize /etc/skel BEFORE creating users
# ===========================================================
# This MUST happen before useradd -m runs, otherwise the new
# users will not get the finance/accounting file in their home dirs.
mkdir -p /etc/skel/finance
touch /etc/skel/finance/accounting


# ===========================================================
# STEP 3 — Create two users
# ===========================================================
# Ensure base home path exists
mkdir -p "$BASE_HOME"
chown root:root "$BASE_HOME"

# catbert — UID 610, primary group hacker, secondary audio+video,
# home /new1/catbert, populated from /etc/skel
useradd -u 610 -g hacker -G audio,video -d "$BASE_HOME/catbert" -m -k /etc/skel catbert || true

# dogbert — UID 611, same setup, home /new1/dogbert
useradd -u 611 -g hacker -G audio,video -d "$BASE_HOME/dogbert" -m -k /etc/skel dogbert || true


# ===========================================================
# STEP 4 — Verify the accounts were created correctly
# ===========================================================
# Check both users appear in /etc/passwd
grep -E 'catbert|dogbert' /etc/passwd

# Check the hacker group appears in /etc/group with both members
grep hacker /etc/group

# Confirm both home directories exist AND contain the finance folder
ls -ld /new1/catbert /new1/dogbert
ls -la /new1/catbert
ls -la /new1/dogbert


# ===========================================================
# STEP 5 — Set passwords
# ===========================================================
# These commands are interactive; run them manually or uncomment below.
# passwd catbert
# passwd dogbert

# Confirm shadow file has entries for both (do not reveal the hash)
grep -E 'catbert|dogbert' /etc/shadow || true


# ===========================================================
# STEP 6 — Password aging with chage
# ===========================================================
# Use a generated future expiration date unless you have a policy date.
chage -m 7 -M 30 -W 2 -I 3 -E "$EXPIRE_DATE" catbert || true
chage -m 7 -M 30 -W 2 -I 3 -E "$EXPIRE_DATE" dogbert || true

# Inspect catbert's shadow entry and identify each field
grep catbert /etc/shadow || true


# ===========================================================
# STEP 7 — Verify home directory ownership
# ===========================================================
ls -ld /new1/catbert /new1/dogbert


# ===========================================================
# STEP 8 — Test logging in as catbert (manual)
# ===========================================================
# These steps are interactive; perform them manually in a shell.
# su - catbert
# id
# pwd
# ls -la
# touch testfile
# ls -l testfile
# When finished, `exit` to return to root.


# ===========================================================
# STEP 9 — More groups
# ===========================================================
groupadd -g 30000 operators || true
groupadd admin1 || true

# Verify both groups exist
grep -E 'operators|admin1' /etc/group || true

# Add catbert and dogbert to operators WITHOUT removing existing
# secondary groups — must use -aG, never -G alone
usermod -aG operators catbert || true
usermod -aG operators dogbert || true


# ===========================================================
# STEP 10 — More users
# ===========================================================
useradd sysadmin1 || true
useradd sysadmin2 || true

usermod -aG admin1 sysadmin1 || true
usermod -aG admin1 sysadmin2 || true

# Confirm they are in the group (run manually if needed):
echo "Run 'groups sysadmin1' and 'groups sysadmin2' to verify membership."

# Examine /etc/group fully to verify ALL secondary memberships
cat /etc/group || true


# ===========================================================
# STEP 11 — sudoers configuration (manual interactive step)
# ===========================================================
# Create the sudoers.d file SAFELY using visudo -f
# Run this interactively — it opens an editor:
# visudo -f /etc/sudoers.d/admin1
# Inside that editor, type exactly this single line, then save:
# %admin1 ALL=(ALL) NOPASSWD: ALL
# Switch to sysadmin1 and verify sudo access works (manual):
# su - sysadmin1
# sudo whoami

# ===========================================================
# CLEANUP (manual)
# ===========================================================
# When you're done testing, remove test users and groups:
# userdel -r catbert || true
# userdel -r dogbert || true
# groupdel hacker || true
# groupdel operators || true