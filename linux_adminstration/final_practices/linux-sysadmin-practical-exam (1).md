# Linux System Administrator — Practical Hiring Exam

**Position:** Junior/Associate Linux & DevOps Engineer
**Format:** Hands-on practical + written reasoning
**Environment:** A fresh Ubuntu Server VM (or two, for the networking section) — VirtualBox, multipass, or a cheap cloud VM all work fine

---

## How this exam works

This isn't a quiz. On a real team, nobody cares if you memorized a flag — they care whether you can fix something at 2am and explain to a teammate the next morning *why* you fixed it that way. So:

- **Open-book.** Use `man`, `--help`, docs. That's what real admins do. What you can't outsource is understanding *why* the command works.
- **For every task**, note: (1) the command(s) you ran, (2) proof it worked (paste the output), (3) 1–2 sentences on *why* you did it that way, not just that it worked.
- **No answers are included in this file on purpose.** Work through it for real. When you're done (or stuck), bring your work back and I'll review it like an actual hiring manager would — including telling you honestly where you're not there yet.

---

## Section 1 — Fundamentals Check (Warm-Up)

Fast, foundational. This is what you'd be expected to do without thinking twice on day one.

1. Create a new user `devops1` with a home directory and bash shell, and add them to a secondary group `deploy` (create the group first if it doesn't exist). Show the resulting entries in `/etc/passwd` and `/etc/group`.
2. Explain the actual difference between `useradd` and `adduser` on Debian/Ubuntu. When would you reach for one over the other in production?
3. Set up `/srv/deploy` so that any file created inside it by any member of the `deploy` group is automatically group-writable and owned by group `deploy`, regardless of who creates it. (Think about setgid and umask together.)
4. Given a file with permissions `-rwsr-xr-x`, explain in plain English what's going on, and name a real binary on a typical Linux system that legitimately needs this permission set.
5. What's the actual difference between a hard link and a symbolic link? Give one production scenario where each is the correct choice.
6. In a single command each: find every file under `/etc` modified in the last 2 days, and every file larger than 100MB anywhere under `/var`.

## Section 2 — File Systems & Storage

This is usually where junior admins fall apart. I want reasoning about disks, not `df -h` recited from memory.

7. Attach a new virtual disk to your VM. Partition it, format it ext4, and mount it persistently at `/data` — persistent meaning it survives a reboot. Prove it does.
8. Same disk, but this time with LVM: create a physical volume, volume group, and logical volume, format and mount it. Then, without unmounting, extend the logical volume by 1GB and grow the filesystem live. Prove the new size shows up.
9. Monitoring alerts you `/` is at 98% usage, but `du -sh /*` doesn't add up to anywhere near the total disk size. What's likely happening, and how do you actually find and reclaim the space? (Real, common trap — think about what `du` can't see.)
10. Explain what an inode is, and reproduce a scenario where `df -h` shows plenty of free space but you still get "No space left on device" creating a file. Then fix it.
11. Set up disk quotas on `/data` from question 7 so `devops1` can't use more than 500MB.
12. Practical difference between ext4, XFS, and btrfs — if you were setting up a server hosting a PostgreSQL database with large tables, which would you pick and why?

## Section 3 — Process & Service Management (systemd)

13. Write a custom systemd service unit that runs a script of your choice on boot, auto-restarts on crash (max 5 restarts within 60 seconds, then gives up), and runs as a dedicated non-root user. Enable it and prove it survives a reboot.
14. A process is pinned at 100% CPU and ignores `kill -15`. Walk through your exact escalation path before reaching for `kill -9`, and explain why jumping straight to `-9` can be dangerous.
15. Explain systemd targets vs. old-style runlevels. What target should a headless production server boot into, and how do you check/set it?
16. Intentionally break a service config (e.g. point Apache at a config file with a syntax error), then use only `systemctl` and `journalctl` to prove exactly why it failed to start.
17. What's the real difference between `systemctl restart` and `systemctl reload` for something like Nginx or Apache? Why does that distinction matter on a server with live traffic?

## Section 4 — Networking

18. Show your current IP config and explain, in your own words, what each field actually means (interface, inet, netmask/CIDR, broadcast, scope).
19. Configure a static IP on a server using Netplan (not the legacy `/etc/network/interfaces` method). Show the config and prove it applied.
20. Two servers, same subnet. Server A can't reach Server B on port 8080. Walk through your full diagnostic checklist in order — from "is the box even up" to "is the port actually listening" to "is something blocking it in between" — naming the exact command at each step.
21. Explain TCP vs. UDP in terms an admin actually cares about, not OSI-diagram trivia — what breaks differently when each one fails.
22. What does `ss -tulnp` show you, and why would you reach for `ss` over the older `netstat` today?
23. Set up an SSH tunnel forwarding local port 8080 to port 80 on a remote server, and describe a real work scenario where you'd actually need this — not just "because I can."

## Section 5 — Package Management & Updates

24. What's the actual difference between `apt update` and `apt upgrade`? What's the danger of running `apt upgrade` blindly on a production box without reading what's about to change?
25. Pin a specific package version on Ubuntu/Debian so it survives routine maintenance upgrades. Give a real production reason you'd do this.
26. You need to install a `.deb` that isn't in any repo and has unmet dependencies. Walk through resolving it safely.
27. What's the difference between a repository and a PPA on Ubuntu? What's a real risk of adding random PPAs to a production server?

## Section 6 — Automation & Scripting

28. Write a bash script that backs up `/etc` to `/backup/etc-$(date +%F).tar.gz` daily, keeps only the last 7 days of backups, logs success/failure with a timestamp to `/var/log/etc-backup.log`, and exits non-zero on failure.
29. Schedule that script via cron for 2:15 AM daily. Show the crontab entry and explain the difference between a user crontab and `/etc/cron.d`.
30. The script works fine run manually but silently fails under cron. What are the top 3 most common causes, and how do you debug it?
31. Write a pipeline (`grep`/`awk`/`sed`) that extracts all unique IPs from an Nginx or Apache access log and counts requests per IP, sorted highest to lowest.
32. Explain `$@` vs `$*` in bash, with a concrete example of a script handling filenames-with-spaces that breaks if you use the wrong one.

## Section 7 — Security & Hardening

33. A junior admin left port 22 open to the whole internet with password auth enabled. Walk through everything you'd change, in priority order.
34. Configure `ufw` (or `firewalld`) to allow only SSH, HTTP, and HTTPS, deny everything else by default, and prove the rules are active.
35. Explain least privilege using a concrete `sudo` example — specifically, how you'd let a teammate restart only the Nginx service via sudo without giving them full root.
36. What is SELinux or AppArmor, in plain language, and what problem does it solve that file permissions and a firewall don't?
37. You suspect a server's been compromised. Name the first five things you'd check, in order, before even thinking about wiping and rebuilding.

## Section 8 — Web Services (Apache/Nginx)

38. Set up Apache with two virtual hosts on one server — `site1.local` and `site2.local` — each serving different content. Prove both work with `curl -H "Host: ..."`.
39. Replicate one of those virtual hosts in Nginx instead. Name 2–3 concrete architectural differences in how Apache and Nginx handle a request that actually matter operationally (not "Nginx is faster").
40. Set up Nginx as a reverse proxy in front of a backend app on `localhost:3000`, forwarding `example.local` traffic to it, making sure the backend still sees the real client IP.
41. Generate a self-signed TLS cert and serve a virtual host over HTTPS with it. Explain what's different — and what an attacker could still get away with — compared to a cert from a real CA like Let's Encrypt.
42. A user reports "the website is down." Apache/Nginx is running fine when you check. Give 4 other real reasons a site can look "down" even though the web server process is healthy.

## Section 9 — Logging & Monitoring

43. Where does Apache/Nginx log errors by default on Ubuntu, and how do you tail it live while filtering only for "error" or a specific status code?
44. Explain log rotation — what's actually happening when `logrotate` runs, why it matters for disk space, and what can go wrong if a service keeps writing to a log file after it's been rotated.
45. Use `journalctl` to find every failed SSH login in the last 24 hours and count them by source IP.
46. Difference between monitoring (metrics) and logging — why does production need both? Give one concrete thing you'd only catch with metrics and one you'd only catch with logs.

## Section 10 — Incident Response (the real test)

Timed: 45 minutes, no interruptions. This is about how you think under pressure, not which commands you know.

**Scenario:** A production server is reported "slow" by three different users around the same time. You SSH in. Walk through, step by step, exactly what you check and in what order to figure out whether it's CPU, memory, disk I/O, or network — naming the exact command for each check. At each step, say what output means "this is fine, move on" vs. "this is the problem."

47. **Twist:** disk's fine, CPU's fine, but `free -h` shows almost no free memory and heavy swap usage. Walk through identifying exactly which process is responsible, and the tradeoff between killing it immediately vs. investigating first.

## Section 11 — Concept / Whiteboard Questions

No terminal for these. Half the job is explaining decisions to people who aren't sysadmins.

48. Explain to someone non-technical why you can't just "give everyone root" to make life easier.
49. What's the difference between backup and high availability? People conflate these constantly — why is that dangerous?
50. You inherit a server with zero documentation. Walk through your first hour on that box — what do you check, in what order, to build a mental model of what it does before you touch anything?

---

## How this actually gets graded

A pass isn't "the command ran." I'm looking for:

- Do you understand *why*, not just *what* — could you explain the fix to a teammate?
- Did you verify your own work before calling it done? (Real senior habit — most people skip this.)
- Did you think about what could break for other users/services, not just whether your task succeeded?
- Clean, no wasted or dangerous shortcuts (`chmod -R 777` is not a fix, it's a confession)

Bring your commands, output, and reasoning back whenever you're ready and I'll go through it section by section.
