# Session 3d · Access Keys & Hardening Identities

## What Is an Access Key?

An access key is a username and password *for programs*. The CLI and code use it to prove
who they are, instead of typing a password into a website.

| Concept | Detail |
|---|---|
| **Two parts** | An Access Key ID (like a username, not secret) and a Secret Access Key (like a password — shown once, keep it hidden) |
| **Password vs key** | You type a *password* into the Console website. A *program* uses an *access key*. Same idea, different door |
| **Guard it like cash** | Never put a key in code, screenshots, or a public repo — that's the exact mistake that caused the crypto-mining bill from Session 3a |

## Hardening Identities

- **Turn on MFA** — a password can be stolen. MFA adds a second factor from your phone, so a
  stolen password alone isn't enough.
- **Rotate and remove keys** — delete access keys you no longer use, and replace old ones
  regularly. An unused key is pure risk sitting around for no benefit.
- **Never share logins** — one person, one identity. Shared logins destroy the audit trail:
  nobody can tell who actually did what.

## Key Terms

- **Access Key ID** — the non-secret half of a program credential, identifies which key it is
- **Secret Access Key** — the secret half, shown once at creation, must be guarded like a password
- **MFA (Multi-Factor Authentication)** — a second proof of identity beyond a password

