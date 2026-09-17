# Session 14 — WAF and Shield

## The shift this file represents

```
  CloudTrail   -\
  Config        >-  WATCH   (record, flag, detect)
  GuardDuty    -/

  WAF          -\
  Shield        >-  BLOCK   (actively stop the attack)
```

Everything up to now has been about knowing. This file is about doing something at the moment of attack, before it ever reaches your application.

---

## Where these two sit, physically

```
  Internet
     |
     v
  +-----+
  | WAF |   <-- inspects every request first
  +-----+
     |
     v
  Your application
```

```
  Normal traffic:

  users  ->>>  Your Website


  DDoS flood:

  attacker machines
  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
           |
           v
       Your Website
```

Two different attack shapes, and each tool is built for one of them.

---

## WAF — Web Application Firewall

WAF inspects individual web requests and applies rules to them.

```
   a request arrives
          |
          v
   +--------------+
   |     WAF      |
   |  check rules |
   +--------------+
          |
     +----+----+
     |         |
     v         v
   BLOCK     ALLOW
     |         |
     v         v
  attacker   your app
  gets       receives
  nothing    the request
```

### What WAF can catch

```
  SQL injection            (malicious data trying to manipulate your database)
  bad bots                 (automated scrapers, credential-stuffing tools)
  too many requests        (rate limiting — one IP hammering an endpoint)
  requests from a country  (geo-blocking)
```

### The example from the lab, worked through

```
  POST /login
        |
        v
  attacker sends a crafted request
        |
        v
  WAF checks it against configured rules
        |
        v
  matches a rule  -->  ❌ BLOCK, never reaches your app
```

WAF's power is that it operates on the **content and pattern** of a request, not just its volume. A single malicious request from a single IP, sent once, can still be caught — volume has nothing to do with it.

---

## Shield — DDoS protection

Shield's job is different in kind, not just degree. It is not reading the content of requests; it is absorbing sheer volume.

```
  a DDoS attack:

  thousands of machines, worldwide
              |
              v
     all sending traffic
        at the same target
        at the same time
              |
              v
        goal: overwhelm the
        service so real users
        cannot get through
```

```
  Shield Standard   -->  free, automatic, on by default for every AWS customer
  Shield Advanced   -->  paid, adds bigger protection and dedicated support
```

Standard already gives you baseline protection against the most common infrastructure-layer floods without you doing anything. Advanced is what a company reaches for when DDoS resilience is business-critical enough to justify paying for a dedicated response team.

---

## WAF vs Shield, side by side

```
+-------------------------+-------------------------+
|          WAF            |         SHIELD           |
+-------------------------+-------------------------+
| looks at CONTENT         | looks at VOLUME          |
| of individual requests   | of overall traffic        |
+-------------------------+-------------------------+
| SQL injection, bad bots, | massive traffic floods    |
| rate limiting, geo rules |  (DDoS)                   |
+-------------------------+-------------------------+
| you write/choose rules   | mostly automatic           |
+-------------------------+-------------------------+
| application layer        | network/transport layer,   |
| (layer 7)                 | and application layer      |
|                           | for Advanced                |
+-------------------------+-------------------------+
```

A useful way to hold both at once: WAF is a bouncer checking IDs at the door one person at a time. Shield is what handles the building being rushed by ten thousand people simultaneously — no amount of ID-checking helps once the doors are being battered down; you need something built for volume.

---

## Where the Web ACL actually attaches

This is the architectural detail Exercise 4 is testing:

```
  User
   |
   v
  CloudFront  or  Application Load Balancer
   |
   v
  WAF Web ACL      <-- attaches HERE, in front of the app
   |
   v
  Your application
```

WAF is not something you install on the EC2 instance itself. It sits on the edge component — CloudFront or the load balancer — so bad requests never even reach your servers to consume their CPU or connections.

---

## Why the lab has you design, not deploy, the WAF rule

```
  deploying a real Web ACL  ->  can incur cost
  designing it on paper      ->  free, and tests the same understanding
```

The exercise: "block any IP making more than 1000 requests in 5 minutes" — that's rate limiting, one of WAF's core capabilities, and you can reason through the whole architecture (where the Web ACL attaches, what it inspects, what happens on a match) without spending anything.

---

## Why companies layer both, not just one

```
  WAF only:    a volumetric flood can still exhaust your
               infrastructure even if every individual request
               looks harmless

  Shield only: a crafted SQL injection request is not high-volume,
               so a flood-focused defense never notices it

  WAF + Shield: content-level attacks get filtered,
                volume-level attacks get absorbed
```

Neither tool substitutes for the other because they are solving different shapes of problem.

---

## Active Recall — WAF and Shield

**Q1.** In one line each: what does WAF look at, and what does Shield look at?

<details><summary>Answer</summary>
WAF looks at the content of individual requests. Shield looks at the volume of overall traffic.
</details>

**Q2.** Name four things WAF can be configured to block.

<details><summary>Answer</summary>
SQL injection, bad bots, too many requests from one IP (rate limiting), and requests from specific countries.
</details>

**Q3.** Where does a WAF Web ACL actually attach, and why not directly on the EC2 instance?

<details><summary>Answer</summary>
It attaches to CloudFront or a load balancer, in front of the application — so malicious requests are filtered before they ever reach and consume resources on the actual servers.
</details>

**Q4.** What is the difference between Shield Standard and Shield Advanced?

<details><summary>Answer</summary>
Standard is free and automatic for every AWS customer. Advanced is paid and adds larger-scale protection plus dedicated support.
</details>

**Q5.** "Block SQL injection on my website" and "survive a DDoS flood" — match each to a tool, and explain why the other tool would not work for that case.

<details><summary>Answer</summary>
SQL injection -> WAF, because it inspects request content and Shield does not look at content, only volume. DDoS flood -> Shield, because WAF inspecting every request individually does not solve an overwhelming volume problem — you need something built to absorb scale.
</details>

**Q6.** Why does the lab ask you to design a WAF rate-limit rule on paper instead of deploying it?

<details><summary>Answer</summary>
Deploying a real Web ACL can incur cost, while designing the rule and reasoning through where it attaches tests the same understanding for free.
</details>

**Q7.** A single attacker sends one crafted, malicious request. Which tool is more likely to catch it, and why?

<details><summary>Answer</summary>
WAF — the request is malicious by content, not by volume, and a single request is not a scale problem Shield is built to detect.
</details>
