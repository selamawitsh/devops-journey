# Real-World DevOps Challenge — GPG Encryption

## No hints. No Google. No AI.

## Scenario
Your team needs to share sensitive deployment credentials with a new
contractor securely, AND verify that release files published by your
company genuinely came from your team and weren't tampered with in
transit. Separately, a teammate's laptop was stolen with their GPG
private key on it.

---

## Question 1
You need to send sensitive credentials to a contractor named `bekele`
so that ONLY he can read them, even if the file is intercepted in
transit. What do you need from him FIRST, before you can encrypt
anything for him specifically?

**What you need first:**
```
```
**Command to get it onto your machine once you have it:**
```
```

---

## Question 2
Write the full command to encrypt a file called `credentials.txt` so
that only `bekele@company.com` can decrypt it.

**Command:**
```
```
**Can YOU decrypt this file afterward? Why or why not?**
```
```

---

## Question 3
Your company publishes a software release file. You want anyone who
downloads it to be able to verify it genuinely came from your team and
was not tampered with — but the file itself doesn't need to be secret,
just provably authentic.

Is this a job for ENCRYPTING or SIGNING? Explain the difference in
what each one actually guarantees.

**Which one and why:**
```
```

---

## Question 4
Write the command your team would run to sign a release file called
`release-v2.tar.gz`, and the command a USER downloading it would run
to verify that signature.

**Your team's signing command:**
```
```
**The downloader's verification command:**
```
```

---

## Question 5
A teammate's laptop containing their GPG private key was stolen.
What is the correct, responsible action they need to take regarding
their GPG identity, and what command starts that process? Why does
simply generating a NEW key pair without doing this leave a problem
unresolved?

**Correct action:**
```
```
**Command:**
```
```
**Why just making a new key isn't enough on its own:**
```
```

---

## Question 6
Fill in this table from memory — for ENCRYPTING a file, whose key
encrypts and whose key decrypts? For SIGNING a file, whose key signs
and whose key verifies? Get the direction right.

```
Encrypting:
  Encrypt with: _______ key (whose?)
  Decrypt with: _______ key (whose?)

Signing:
  Sign with:    _______ key (whose?)
  Verify with:  _______ key (whose?)
```
