# Shell Basics

## What is the shell
The shell is the command interpreter between you and the Linux kernel.
When you type a command, the shell reads it, figures out what to run,
executes it, shows the output, then waits again. This loop is your
entire interaction with a Linux server as a DevOps engineer.

The default shell on most Linux systems is bash.

## The prompt
- `$` means normal user
- `#` means root (superuser — be careful)

## Logging in and out
- Log out: `exit` or `Ctrl+D`
- Switch to root: `su -` or `sudo -i`

## Key commands learned
| Command | What it does |
|---------|-------------|
| `hostname` | show machine name |
| `date` | show current date and time |
| `date -I` | ISO format date |
| `id` | show your user ID and groups |
| `cal` | show calendar |
| `pwd` | show current directory |
| `ls` | list files |
| `ls -l` | long listing with permissions |
| `ls -a` | show hidden files |
| `exit` | log out |

## Why this matters in DevOps
Every server you ever SSH into starts here. You land at a shell prompt.
Knowing where you are, who you are, and what machine you are on is the
first thing you check before doing anything else.
