# 01 — Apache Basics: Challenge

Do these **without** running `practice.sh` — the point is to prove you can
do it from memory / from `notes.md`, not from watching a script run. Use a
fresh VM or container if you can, so you're not relying on state the script
already set up for you.

No answers included on purpose. If you get stuck, re-read `notes.md` before
asking for help — the goal is recall, not lookup speed.

---

## Part A — DocumentRoot

1. Create a new site folder at `/var/www/html/farmers` and put an
   `index.html` inside it that says `Agri-Yield Farmer Portal`.
   answer:
   i have screenshot of what i created
2. Without changing any Apache config, confirm via `curl` that the file is
   reachable, and explain in your own words *why* it's reachable without
   any extra config.
   i don't know why it is reachable without any config but like since it is local host i can access it aguess

3. Now request `/farmers/` (with the trailing slash, no filename) instead of
   `/farmers/index.html`. Does it still work? Why?
   yes it does still show me i don't know why though

## Part B — Directory / AllowOverride / Require

4. Create a folder `/var/www/html/investors-only`. Password-protect it so
   only a user called `investor1` can access it.
   i don't know how to create it to be honest

5. Deliberately break it: set `AllowOverride None` on that directory and
   restart Apache. What HTTP status code do you get now when requesting
   the page? Explain *why* — not "it's blocked," but the actual mechanism.
   i don't know

6. Fix it, then add a second user `investor2` to the same password file
   **without** wiping out `investor1`. What flag do you avoid using when
   adding the second user, and why?
    i don't know

## Part C — Modules & handlers

7. Enable `mod_rewrite` and confirm with `apache2ctl -M` that it's active.
   how can i enable it

8. Install PHP support. Before enabling the PHP module, predict what you'll
   see in the browser when requesting a `.php` file — then verify your
   prediction.
   how can i install and where do i install

9.  Disable the PHP module again (`a2dismod`) and re-test the same file.
   Confirm the behavior reverts. What does this tell you about where the
   "decision" to execute vs. serve-as-text actually lives?
   i don't know

## Part D — Logs

10. Trigger a 403 Forbidden error on purpose (hint: think about what
    `Require all denied` does, or file permissions). Find the corresponding
    line in `error.log`.
    i don't understand

11. Set `LogLevel debug` temporarily, reproduce the same error, and compare
    how much more detail shows up in `error.log`. Set it back to `warn`
    afterward — explain why leaving it on `debug` long-term is a bad idea
    on a production server.
    how can i do it 

12. Using only `access.log`, answer: how would you find every request that
    resulted in a 404 in the last hour? (You don't need a perfect one-liner
    — describe the approach, then try to actually build the command.)
    how can i do it


## Stretch goal (optional, ties into Agri-Yield instincts)

13. Your Agri-Yield services follow hexagonal architecture with clear
    boundaries between layers. Write 2-3 sentences comparing that mental
    discipline to Apache's "deny by default, explicitly allow" pattern in
    `<Directory>` blocks. What's the shared principle underneath both?
    help me with this 

---
