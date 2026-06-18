# Challenge: User and Group Account Management

## Part 1 — Hands-on exercise
You manage a Linux server and need to onboard a team of consultants.

1. Set the system-wide default so that all newly created users must change
   their password every 30 days.
2. Create a group called `consultants` with GID `35000`.
3. Configure sudo so that any member of the `consultants` group can run any
   command as any user (use a file in /etc/sudoers.d/, not the main file).
4. Create three users — `consultant1`, `consultant2`, `consultant3` — each
   with `consultants` as a secondary group.
5. Set all three passwords to something temporary.
6. Set all three accounts to expire 90 days from today.
7. Change consultant2's policy so they must change their password every
   15 days instead of the 30-day default.
8. Force all three to change their password on first login.
9. Verify everything: check /etc/group, /etc/passwd, and run `chage -l` on
   each account to confirm the aging policy actually took.

## Part 2 — Conceptual quiz
1. Which value identifies a user at the most fundamental level — username or
   UID? Why does the system care more about one than the other?
2. Which file stores local group definitions?
3. Which file stores local user account information (excluding passwords)?
4. What is the 4th field in a line of /etc/passwd?
5. Where are a user's personal files (home directory contents, dotfiles,
   shell config) actually stored — and which file points to that location?
6. Which file holds password aging parameters?
7. True or false: every secondary group a user belongs to gets created
   automatically when the user is created.
8. What does `userdel` do to a user's home directory by default? What
   changes if you add `-r`?
9. If you remove a user without `-r`, and later create a new user that gets
   assigned the same UID, what security problem can occur?
10. Explain in your own words: the difference between `su -` and `sudo`, and
    why an admin would prefer one over the other for day-to-day work.
