# Session 3b · Users & Groups vs Roles

## Users & Groups: The Team Structure

**Golden rule: attach permissions to GROUPS, never to individual users.** Move people
between groups to change their access.

| Situation | What you do |
|---|---|
| One person joins | Add them to the right group — they instantly have exactly that group's access, nothing to set up per person |
| Someone changes team | Move them from one group to another — old access gone, new access granted, in one action |
| Why not per-user? | Per-user permissions drift into a mess nobody can audit. Groups keep access tidy and reviewable |

## Roles: The Visitor Badge

A **role** is an identity with permissions but no owner. You don't log in to a role — you
temporarily **assume** it.

**Think of a hospital visitor badge:** you arrive, sign in at the front desk, and they hand
you a badge. It opens a few doors, only for today. You never owned it, you just wore it for
the visit, and you hand it back on the way out. It even expires on its own. A role is that
badge — assumed for a task, grants specific access for a short time, then it's gone.

| Who assumes a role | Why |
|---|---|
| A program | A server that needs another AWS service gets a role, so no permanent keys sit on the machine waiting to leak |
| A person | An auditor needs one afternoon of access. They assume a role for the day, nothing to create or delete |

## Tie-In: This Is Just RBAC

If this feels familiar, it should — it's the same shape as role-based access control in any
backend framework (Spring Security's `@PreAuthorize`, for instance): identities get grouped
by role, permissions attach to the role/group rather than the individual, and the framework
checks membership before allowing an action. AWS IAM is doing the exact same thing at the
infrastructure layer instead of the application layer.

## Key Terms

- **RBAC (Role-Based Access Control)** — granting permissions based on group/role membership rather than per individual
- **Assume a role** — temporarily taking on a role's permissions for a task, then dropping them




