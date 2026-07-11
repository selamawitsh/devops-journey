# SSH Tunneling — Local, Remote, and X11 Forwarding

## The core idea
SSH can do more than give you a shell it can also forward NETWORK
TRAFFIC through the encrypted connection. This means you can reach a
service that isn't normally exposed to you, by routing the traffic
through a machine that CAN reach it.

## Local forwarding (-L)
  ssh -L local_port:target_host:target_port user@ssh_server

Meaning: "connect to ssh_server, then forward connections from MY
local_port, through ssh_server, to target_host:target_port"

Example:
  ssh -L 9000:hckrnews.com:80 root@5.161.197.79

This connects to 5.161.197.79 via SSH, and creates a tunnel so that
anything sent to localhost:9000 on YOUR machine actually gets routed
through 5.161.197.79 to hckrnews.com port 80.

  curl localhost:9000     # this request travels through the tunnel

Real use case: accessing a database that only listens on localhost
on a remote server, without exposing that database port to the
public internet at all. You tunnel through SSH instead.

## Remote forwarding (-R)
  ssh -R remote_port:local_host:local_port user@ssh_server

This is the OPPOSITE direction — it exposes something on YOUR machine
to the remote server (or beyond).

Example:
  ssh -R 8000:localhost:80 root@5.161.197.79

Now anyone connecting to port 8000 ON 5.161.197.79 gets routed back
to port 80 on YOUR local machine. This is how you'd expose a website
you're running locally to the internet via a server that already has
a public IP, without deploying anything.

  ssh -R 0.0.0.0:8000:localhost:7777 192.168.70.2

The `0.0.0.0` means "bind on ALL network interfaces of the remote
machine," not just localhost there — so anyone who can reach
192.168.70.2 at all can hit port 8000 and get routed to your local
port 7777.

## X11 forwarding (-X)
Lets you run a GRAPHICAL Linux application on a remote machine, but
have its window actually display on YOUR local screen.

Requirement — both sides need this enabled:
  /etc/ssh/sshd_config:
  X11Forwarding yes

Usage:
  ssh -X user@remotehost
  gedit          # opens on YOUR screen, but running on the remote machine

This is genuinely useful when a tool only exists on a remote server
and you need its GUI without physically being at that machine.

## Mental model to keep straight
- **-L (Local)**: "let ME reach something THROUGH the server" — forward FROM my machine
- **-R (Remote)**: "let THE SERVER (or others) reach something on MY machine" — forward TO my machine
- **-X**: "let me see THEIR graphical app on MY screen"

## Why this matters in DevOps
-L is used constantly to reach internal-only databases, admin panels,
or dashboards through a bastion/jump host without opening firewall
ports to the public internet. -R is less common but useful for quick
demos or exposing a local dev server temporarily. -X is handy for
one-off GUI debugging tools on remote systems.
