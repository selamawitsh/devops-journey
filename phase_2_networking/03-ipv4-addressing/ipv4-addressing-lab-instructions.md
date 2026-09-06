# Session 03 — IPv4 Addressing: Lab Exercises

## Lab 1 — Inspect Your Ubuntu IP

```bash
ip addr
ip addr show <your-interface-name>
ip route
```

Record:
```
IP:
CIDR:
Default gateway:
```

## Lab 2 — Loopback

```bash
ping -c 4 127.0.0.1
ping -c 4 localhost
```

## Lab 3 — Identify Your Network

```bash
ip -4 addr
```

Record:
```
IP:
CIDR:
Network:
Subnet mask:
Broadcast:
Default gateway:
```

## Lab 4 — Packet Tracer: Same-Network Communication

1. Open Packet Tracer.
2. Add 2 PCs and 1 Switch.
3. Connect PC1 — Switch — PC2 (Copper Straight-Through).
4. PC1 → Desktop → IP Configuration:
   ```
   IP Address:      192.168.10.10
   Subnet Mask:     255.255.255.0
   Default Gateway: (leave empty)
   ```
5. PC2 → Desktop → IP Configuration:
   ```
   IP Address:      192.168.10.20
   Subnet Mask:     255.255.255.0
   Default Gateway: (leave empty)
   ```
6. PC1 → Desktop → Command Prompt:
   ```
   ping 192.168.10.20
   ```
7. Confirm: `Reply from 192.168.10.20`

## Lab 5 — Packet Tracer: Different-Network Failure

1. PC2 → Desktop → IP Configuration.
2. Change IP Address to:
   ```
   192.168.20.20
   ```
3. Keep Subnet Mask: `255.255.255.0`.
4. Keep PC1 unchanged: `192.168.10.10/24`.
5. PC1 → Desktop → Command Prompt:
   ```
   ping 192.168.20.20
   ```
6. Confirm: `Request timed out` (no router connecting the two networks).

## Lab 6 — Reset and Verify

1. Change PC2's IP back to `192.168.10.20`.
2. Re-run:
   ```
   ping 192.168.10.20
   ```
3. Confirm: `Reply from 192.168.10.20`.
