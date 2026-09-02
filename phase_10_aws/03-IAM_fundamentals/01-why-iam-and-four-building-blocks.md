# Session 3a · Why IAM Comes First & The Four Building Blocks

> Part of my Qiyas Cloud Computing learning log.

## A True Story (Why We Learn This Before Anything Else)

A developer pushes code to a public repository. Hidden inside it: an AWS access key. Bots
scan public repos for exactly this, around the clock. Within minutes the key is found and
used to launch crypto-mining servers. The bill arrives in the thousands of dollars.

**The lesson:** IAM discipline is not paranoia. It's the seatbelt you put on before you
drive. That's why it's Session 3, not an afterthought bolted on later.

## The Four Building Blocks

| Block | What it is |
|---|---|
| **User** | A permanent identity for one person or one program. Has a password and/or access keys. |
| **Group** | A container for users who need the same access. Attach permissions once, everyone inside gets them. |
| **Role** | A temporary identity you put on for a task, then take off. No password, no owner. |
| **Policy** | The document (written in JSON) that lists what is allowed. Attached to users, groups, or roles. |

Users and groups are about *identity* — who someone is. Roles are about *borrowed* access
for a task. Policies are the actual permission document attached to any of the above.

## Key Terms

- **IAM (Identity and Access Management)** — the AWS service controlling who can do what
- **Identity** — a user, group, or role that AWS can grant permissions to
- **Access key** — the credential a program uses instead of a typed password

