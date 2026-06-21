#!/bin/bash
# Topic: SSH Tunneling
# These need a real remote host to fully test — adjust IPs/hosts as needed

# LOCAL FORWARDING — reach a remote-only service through the tunnel
# This forwards your local port 9000 to hckrnews.com:80, via the SSH server
# ssh -L 9000:hckrnews.com:80 root@5.161.197.79
#
# In a SEPARATE terminal while that connection is open:
# curl localhost:9000

# Practical local forwarding example — reach a DB that only listens
# on localhost on the remote server, from your own machine:
# ssh -L 5433:localhost:5432 user@dbserver
# (now connect your local DB client to localhost:5433)

# REMOTE FORWARDING — expose YOUR local service to a remote server
# This exposes your local port 80 as port 8000 on the remote server
# ssh -R 8000:localhost:80 root@5.161.197.79
#
# Now anyone who can reach 5.161.197.79:8000 gets routed to your machine

# Remote forwarding bound to all interfaces (not just localhost on remote)
# ssh -R 0.0.0.0:8000:localhost:7777 192.168.70.2

# X11 FORWARDING — run a remote GUI app, display locally
# Check sshd_config has X11Forwarding yes on BOTH sides
grep X11Forwarding /etc/ssh/sshd_config

# Connect with X forwarding enabled
# ssh -X user@remotehost
# Then on the remote shell, try:
# gedit &
# (the gedit window should appear on YOUR screen)

# Firewall note — if tunneling to a port that needs to be reachable
# from outside, you may need to open it:
# firewall-cmd --zone=public --add-port=9000/tcp --permanent
# firewall-cmd --reload
