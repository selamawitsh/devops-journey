# Challenge & Answer — Break Dependency Resolution

## Command run
```bash
sudo apt-get install -y "curl=1.0.0-fake"
```

## Actual output
```
selamawit@selamawit-ThinkPad-T490:~$ sudo apt-get install -y "curl=1.0.0-fake"
[sudo] password for selamawit: 
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Package curl is not available, but is referred to by another package.
This may mean that the package is missing, has been obsoleted, or
is only available from another source

E: Version '1.0.0-fake' for 'curl' was not found
selamawit@selamawit-ThinkPad-T490:~$ 


```

## Diagnosis
- **Error type:** _(missing package / version conflict / broken partial install)_
    error type is version confilict 

- **Why:** apt checked its package index for `curl` at version `1.0.0-fake` and found no candidate matching that exact version string — this is a *missing candidate* error, not a dependency conflict, because it fails before any dependency graph is even built.

## Fix
```bash
sudo apt-get install -f
```
**What this actually does:** re-runs apt's dependency solver against the current (unchanged) state and reports "0 upgraded, 0 newly installed" if nothing was actually broken on disk — confirming the failed install above never touched dpkg's database at all.

## Lesson learned
apt validates the *requested version exists* before it ever starts resolving dependencies or writing to disk. A failed `apt-get install pkg=version` is safe — no partial state, no cleanup needed. A truly broken dependency state (e.g. from an interrupted install) shows up differently: `dpkg --audit` lists packages in a `half-installed` or `unpacked` state, which `apt-get install -f` *does* need to repair.

