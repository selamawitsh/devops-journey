# Phase 1 - Process Management

Part of the `linux-mastery` repo. Covers processes, PIDs/PPIDs, `ps`/`top`/`htop`,
process states, signals, `nohup`/`disown`, zombies/orphans, and a watchdog
script that kills runaway processes automatically.

## What I learned

- A **process** is a running instance of a program, tracked by a unique **PID**.
  Every process has a **PPID** (parent), forming a tree back to PID 1 (`systemd`).
- `ps aux` gives a one-time snapshot of all processes; `top`/`htop` show a live,
  continuously refreshing view.
- **Signals** are how you actually "kill" something -- `kill` just sends a signal:
  - `SIGTERM` (15, the default) asks a process to shut down cleanly, giving it
    a chance to save state / close files first.
  - `SIGKILL` (9) terminates it instantly with zero cleanup -- a last resort.
- `pkill`/`killall` let you signal a process by name instead of hunting for
  its PID with `ps` + `grep` first.
- Background jobs (`command &`) are children of your shell. If the shell's
  SSH session drops, it sends `SIGHUP` to its children, killing them by
  default. `nohup` makes a command ignore that signal from the start;
  `disown` detaches an already-running background job from the shell's job
  table so it survives disconnection.
- **Zombie**: a finished process still listed until its parent reads its exit
  status via `wait()`. Harmless individually; a large pile signals a buggy
  parent.
- **Orphan**: a process whose parent died first -- automatically re-parented
  to PID 1, which cleans it up properly when it exits.

## Commands used

```bash
ps aux
ps aux | grep [y]es          # bracket trick avoids grep matching itself
htop
yes > /dev/null &            # test process that burns CPU, for practice
kill <pid>                   # SIGTERM
kill -9 <pid>                # SIGKILL
pkill yes
killall yes
nohup yes > /dev/null &
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6
```

## Project: watchdog.sh

A script that scans running processes, flags any exceeding a CPU% threshold,
kills them (SIGTERM first, SIGKILL if it doesn't respond), and logs every
action with a timestamp to `~/watchdog.log`.

Run it:
```bash
chmod +x watchdog.sh
./watchdog.sh
cat ~/watchdog.log
```

Test it by starting a CPU-heavy process first, then running the script in
another terminal:
```bash
yes > /dev/null &
./watchdog.sh
```

### Lessons learned
- Killing a process is really "sending it a signal" -- the process itself
  gets to decide how to react (within limits), which is why SIGTERM vs
  SIGKILL matters.
- Bash can't compare decimal numbers natively, so CPU% comparisons need
  `awk` (or a similar tool) to do the actual math.
- A "watchdog" pattern -- detect, act, log -- shows up constantly in real
  ops work (health checks, autoscaling, alerting), not just in this script.
