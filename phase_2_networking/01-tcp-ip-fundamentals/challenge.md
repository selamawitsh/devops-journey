# TCP/IP Challenge — Test Your Understanding

Answer these without looking at notes first. Then check your answers.

---

## Question 1
You run `curl https://example.com` and get:
curl: (6) Could not resolve host: example.com

**Which layer has failed? What command confirms it?**

<details>
<summary>Answer</summary>

**Application layer (DNS).** Confirm with `dig example.com` or `nslookup example.com`. If DNS can't resolve the name to an IP, no TCP connection can even begin.
</details>

---

## Question 2
`ss -tn` shows port 80 is LISTENING. Your colleague says "the server is reachable."
**What two other layers must be checked before that's true?**

<details>
<summary>Answer</summary>

1. **Internet layer (Layer 3)** — Firewalls/security groups could be blocking the traffic. Check `iptables` or cloud security group rules.
2. **Link layer (Layer 1/2)** — The network interface must actually be UP. Check `ip link` — a server with a listening port but a down interface is unreachable.
</details>

---

## Question 3
You see `[F.]` in a tcpdump capture after a successful data transfer.
**What is it? Is something wrong?**

<details>
<summary>Answer</summary>

**FIN-ACK — normal, healthy connection teardown.** The client is saying "I'm done sending data, let's close gracefully." The server will respond with its own FIN, and they'll both ACK. This is the TCP 4-way close.
</details>

---

## Question 4
Your laptop is `192.168.1.42/24`, gateway `192.168.1.1`. You send a packet to `8.8.8.8`.
**What destination MAC goes in the Ethernet frame? The MAC of 8.8.8.8 or 192.168.1.1? Why?**

<details>
<summary>Answer</summary>

**The MAC of 192.168.1.1 (the gateway).** Your laptop knows 8.8.8.8 is not on the local 192.168.1.x network. It sends the frame to the gateway's MAC, but the IP packet inside still says destination 8.8.8.8. The gateway strips the Ethernet frame, reads the IP, and forwards it. Link layer only cares about the next hop.
</details>

---

## Question 5
Arrange these in the order they happen when you browse to https://google.com:

- [ ] TCP 3-way handshake
- [ ] DNS resolution
- [ ] TLS handshake
- [ ] HTTP request sent
- [ ] Ethernet frame sent to gateway MAC

<details>
<summary>Answer</summary>

1. **DNS resolution** — Need the IP first
2. **TCP 3-way handshake** — Establish connection to that IP:443
3. **TLS handshake** — HTTPS negotiation (on top of TCP)
4. **HTTP request sent** — Now send the actual GET request
5. **Ethernet frame sent to gateway MAC** — This actually happens at EVERY step above, for every single packet. Encapsulation is constant.

</details>

---

## Question 6
A packet arrives at a server's network card.
**What order are the headers stripped off as it moves up the stack?**

<details>
<summary>Answer</summary>

1. **Ethernet header stripped** (Link layer — confirms destination MAC matches)
2. **IP header stripped** (Internet layer — confirms destination IP matches)
3. **TCP header stripped** (Transport layer — confirms destination port, reassembles segments)
4. **Raw HTTP data delivered** to the web server application

Each layer only looks at its own header and passes the payload up.
</details>

---
