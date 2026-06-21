# ===========================================================
# STEP 1 — Create a group
# ===========================================================
# Create group 'hacker' with GID 1200
groupadd -g 1200 hacker


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
# catbert — UID 610, primary group hacker, secondary audio+video,
# home /new1/catbert, populated from /etc/skel
useradd -u 610 -g hacker -G audio,video -d /new1/catbert -m -k /etc/skel catbert

# dogbert — UID 611, same setup, home /new1/dogbert
useradd -u 611 -g hacker -G audio,video -d /new1/dogbert -m -k /etc/skel dogbert


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
passwd catbert
passwd dogbert

# Confirm shadow file has entries for both (do not reveal the hash)
grep -E 'catbert|dogbert' /etc/shadow


# ===========================================================
# STEP 6 — Password aging with chage
# ===========================================================
# Note: replace 2026-12-31 with whatever "this year" actually is
# when you run this for real — never hardcode a past date.
chage -m 7 -M 30 -W 2 -I 3 -E "2026-12-31" catbert
chage -m 7 -M 30 -W 2 -I 3 -E "2026-12-31" dogbert

# Inspect catbert's shadow entry and identify each field
grep catbert /etc/shadow


# ===========================================================
# STEP 7 — Verify home directory ownership
# ===========================================================
ls -ld /new1/catbert /new1/dogbert


# ===========================================================
# STEP 8 — Test logging in as catbert
# ===========================================================
su - catbert

# As catbert, run these and observe the output:
id
pwd
ls -la
touch testfile
ls -l testfile

# As catbert, try changing your own password. What happens and why?
# (Hint: -m 7 means minimum 7 days between password changes —
#  if catbert just got the password set by root moments ago,
#  the system may still allow it since "last_change" was set
#  by the passwd command itself. Test it and write down what
#  actually happens on your system as a comment here.)
#
# OBSERVATION:


# Return to root
exit


# ===========================================================
# STEP 9 — More groups
# ===========================================================
groupadd -g 30000 operators
groupadd admin1

# Verify both groups exist
grep -E 'operators|admin1' /etc/group

# Add catbert and dogbert to operators WITHOUT removing existing
# secondary groups — must use -aG, never -G alone
usermod -aG operators catbert
usermod -aG operators dogbert


# ===========================================================
# STEP 10 — More users
# ===========================================================
useradd sysadmin1
useradd sysadmin2

usermod -aG admin1 sysadmin1
usermod -aG admin1 sysadmin2

# Confirm they are in the group
groups sysadmin1
groups sysadmin2

# Examine /etc/group fully to verify ALL secondary memberships
cat /etc/group


# ===========================================================
# STEP 11 — sudoers configuration
# ===========================================================
# Create the sudoers.d file SAFELY using visudo -f
# Run this interactively — it opens an editor:
visudo -f /etc/sudoers.d/admin1

# Inside that editor, type exactly this single line, then save:
# %admin1 ALL=(ALL) NOPASSWD: ALL

# Switch to sysadmin1 and verify sudo access works
su - sysadmin1
sudo whoami