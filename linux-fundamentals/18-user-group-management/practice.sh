#!/bin/bash
# Practice: User and Group Account Management
# Run with: sudo bash practice.sh
# Go through each section, run it, then read the output before moving on.

echo "=== 1. Identity basics ==="
id
whoami
who
echo

echo "=== 2. Create a group ==="
groupadd -g 1200 hacker
tail -n 1 /etc/group
echo

echo "=== 3. Create two users in that group, with secondary groups ==="
useradd -u 610 -g 1200 -G audio,video -m -b /home catbert
useradd -u 611 -g 1200 -G audio,video -m -b /home dogbert
grep bert /etc/passwd
grep bert /etc/group
echo

echo "=== 4. Set passwords (will prompt interactively) ==="
# passwd catbert
# passwd dogbert
echo "(uncomment the two lines above to actually set passwords)"
echo

echo "=== 5. Set password aging policy on catbert ==="
chage -m 7 -M 30 -W 2 -I 3 -E "$(date -d '+180 days' +%F)" catbert
chage -l catbert
echo

echo "=== 6. Inspect the shadow entry (fields explained in notes.md) ==="
grep catbert /etc/shadow
echo

echo "=== 7. Lock and unlock an account ==="
usermod -L dogbert
grep dogbert /etc/shadow   # note the ! prepended to the hash when locked
usermod -U dogbert
echo

echo "=== 8. Clean up (uncomment when you're done practicing) ==="
# userdel -r catbert
# userdel -r dogbert
# groupdel hacker
