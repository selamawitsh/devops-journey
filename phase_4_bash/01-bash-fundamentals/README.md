# Bash Fundamentals

Session 1 of Phase 4 — Bash, part of the devops-journey DevOps mentorship curriculum.

## What this covers
- What a shell is and how Bash fits in
- The difference between running a command directly (./script.sh) and running it through an interpreter (bash script.sh)
- Why the shebang line (#!/bin/bash vs #!/usr/bin/env bash) matters across environments
- File execute permissions and how they interact with the kernel vs. the shell
- Basic echo usage

## Folder contents
- notes.md — concept notes with the real-world reasoning behind each one
- commands.md — the exact commands run this session, with what each is for
- examples/ — small standalone examples, one concept each
- scripts/ — the mini script built to practice everything from this session

## Key takeaway
ps -p $$ tells the truth about what shell you're actually running in; $SHELL is just a stored default and can be stale. Execute permission is only checked when the kernel runs a file directly — running it via bash file.sh never needs it.
