# Session 3c · JSON, Policy Documents & Least Privilege

## First, What Is JSON?

JSON is just a tidy way to write down facts as `label: value` pairs. AWS reads permissions
written this way.

```json
{
  "name": "Amina",
  "age": 24,
  "city": "Addis Ababa"
}
```

| Symbol | Meaning |
|---|---|
| `{ }` | Wraps the whole thing |
| `"label": value` | One fact — label, colon, value |
| `,` | Separates each fact |
| `" "` | Text is quoted, numbers are not |

## Policies: Permissions as Documents

**A policy is a JSON document that says WHO can do WHAT, on WHICH things, under WHAT
conditions.**

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "ec2:DescribeInstances",
    "Resource": "*"
  }]
}
```

| Field | Meaning |
|---|---|
| **Effect** | `Allow` or `Deny` — the verdict |
| **Action** | Which operations, in `service:Operation` form. `*` = all |
| **Resource** | Which things it applies to. `*` = everything |
| **Version** | A fixed spec date. Always copy it exactly |

In plain English: allow viewing the list of servers, nothing else.

### Three Policy Types

| Type | What it is | When |
|---|---|---|
| **AWS managed** | Written and maintained by AWS, hundreds exist, ready to use | Start here — used in today's lab |
| **Customer managed** | Written by you, reusable across identities | For when AWS's are too broad — your take-home |
| **Inline** | Stuck to one identity, not reusable | Rare — usually a sign to switch to managed |

### A Real (Broad) Example — View-Only Access

```json
{
  "Effect": "Allow",
  "Action": ["ec2:Describe*", "ec2:Get*"],
  "Resource": "*"
}
```

`ec2:Describe*` = every Describe action (view servers, view networks, etc). `ec2:Get*` =
every Get action (read settings/details). `Resource: *` = on everything in the account.
View-only, but view *everything*. The `*` wildcard is convenient but broad — the take-home
assignment narrows this down to one exact permission.

## How AWS Decides: Allow or Deny?

1. **Start at DENY** — every request begins denied by default. If nothing allows it, it
   stays denied.
2. **Look for an Allow** — AWS checks all attached policies. One matching Allow flips the
   request to allowed.
3. **An explicit Deny always wins** — if *any* policy says Deny, that beats every Allow.
   Deny is the final word.

## Least Privilege: The Golden Rule

Give each identity the smallest set of permissions it needs to do its job, and nothing
more.

- **Start closed, open as needed** — begin with no access, add exactly what someone is
  blocked on, one permission at a time.
- **Why it matters** — if an identity is compromised, the damage is capped at what little it
  could do. Small blast radius.
- **The everyday version** — a shop clerk gets a till key, not the safe combination. Access
  matches the job, not the person.

## Key Terms

- **JMESPath / policy JSON** — the structured document format IAM policies are written in
- **Wildcard (`*`)** — matches "everything" in an Action or Resource field
- **Blast radius** — how much damage is possible if a given identity is compromised



