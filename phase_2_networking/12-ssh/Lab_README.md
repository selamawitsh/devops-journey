# 12 — SSH

## Learning Objectives
By the end of this module you should be able to:
- Explain how SSH key-based authentication works (conceptually)
- Enable SSH on a Cisco device (router or switch) and disable Telnet
- Connect to a device via SSH from a client
- Explain why SSH is preferred over Telnet for remote administration

## Why This Matters
SSH is *the* way you'll access nearly every Linux server, cloud VM, network device, and container host in your career. This module focuses on the network-device side (routers/switches) — the same core ideas apply directly to Linux servers, which you'll use constantly later in your DevOps path.

## Core Concepts

### Symmetric vs. asymmetric crypto (just enough to understand SSH)
- **Symmetric encryption**: same key encrypts and decrypts. Fast, but both sides need the same secret.
- **Asymmetric (public-key) encryption**: a **key pair** — a public key (shareable) and a private key (secret, never leaves the device). Data encrypted with the public key can only be decrypted with the matching private key.

SSH uses asymmetric crypto to authenticate and set up the session, then a fast symmetric key for the actual traffic.

### Why SSH over Telnet
Telnet sends everything — including your password — as **plain text** across the network. Anyone capturing traffic between you and the device (see Module 11!) can read your credentials directly. SSH encrypts the entire session, so even a full packet capture reveals nothing usable.

### What actually enables SSH on a Cisco device
1. A **hostname** and **domain name** must be set (SSH needs these to generate its keys).
2. An **RSA key pair** must be generated on the device (`crypto key generate rsa`) — this is the actual cryptographic material that makes SSH possible.
3. **Local user accounts** are needed for authentication (or an AAA server, out of scope here).
4. The **VTY lines** (virtual terminal lines — how remote sessions connect) must be set to accept SSH and use the local user database.

## Key Commands Cheat Sheet
```
hostname R1
ip domain-name labs.local
crypto key generate rsa
username admin secret Cisco123!
ip ssh version 2
line vty 0 4
 transport input ssh
 login local
show ip ssh
```

---

## Lab Exercise (Packet Tracer — `lab.pkt`)

This is a fully native Packet Tracer lab — routers and switches genuinely support SSH configuration, and PCs have a real SSH client in the Command Prompt.

### Topology
```
[PC1]---[Switch]---[Router]
```
- 1 Router, 1 Switch, 1 PC, all cabled and addressed in the same management subnet, PC's default gateway set to the router.

### Steps
1. **Build and address the topology** — PC1 gets an IP in the same subnet as the router's connected interface, with that interface as its default gateway.
2. **Set device identity** on the router:
   ```
   hostname R1
   ip domain-name labs.local
   ```
3. **Generate the RSA key pair** (this is the step that actually enables SSH):
   ```
   crypto key generate rsa
   ```
   When prompted for a modulus size, use 1024 or 2048.
4. **Create a local user**:
   ```
   username admin secret Cisco123!
   ```
5. **Restrict the VTY lines to SSH only**, using the local user database:
   ```
   line vty 0 4
    transport input ssh
    login local
   ```
6. **(Recommended) force SSH version 2**: `ip ssh version 2`.
7. **Connect from PC1**: Desktop → Command Prompt → `ssh -l admin <router-ip>`, enter the password, confirm you land in the router's CLI prompt.
8. **Verify Telnet is actually blocked**: from PC1, try `telnet <router-ip>` — it should be refused, since `transport input ssh` removed Telnet access entirely.
9. **Check the config**: on the router, `show ip ssh` — confirm SSH is enabled and note the version/timeout values shown.
10. **Stretch**: repeat steps 2–9 on a switch instead of a router — the VTY/SSH configuration is identical, and switches need remote management just as often.

### Checkpoint Questions
1. What specific command actually generates the cryptographic material that makes SSH possible, and why can't SSH work without it?
2. What happened when you tried Telnet after configuring `transport input ssh` — and why exactly does that command cause that behavior?
3. What role does `login local` play in this configuration, and what would break without it?
4. Why does `ip domain-name` need to be set *before* you can generate the RSA keys?
