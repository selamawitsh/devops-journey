# Session 3e · Hands-On Lab — Build Your Team's Access

You are the cloud administrator now. Four short missions: create groups, add teammates,
deliberately hit a wall, then read what the wall told you.

## Exercise 1: Create Three Groups

Groups hold the permissions. Make three, each with a different access level.

- [ ] **Open IAM** — top search bar, type "IAM", click the result.
- [ ] **Go to Groups** — left menu → User groups → Create group.
- [ ] **Admins group** — name it `Admins`, tick `AdministratorAccess`, Create group.
- [ ] **Developers group** — Create group again, name it `Developers`, tick
  `AmazonEC2FullAccess`, Create group.
- [ ] **View-Only group** — Create group again, name it `ViewOnly`, tick `ReadOnlyAccess`,
  Create group.

> Permissions live on the group, never on the person.

## Exercise 2: Add Three Teammates

One user per group, so you can see each access level in action.

- [ ] **Start a user** — IAM → left menu → Users → Create user.
- [ ] **Name and access** — name the first user `amina-admin`, tick console access, set a
  password, click Next.
- [ ] **Put them in a group** — on the permissions step choose "Add user to group", tick
  `Admins`, Next, then Create user.
- [ ] **Repeat for a developer** — create `bekele-dev` the same way, add to `Developers`.
- [ ] **Repeat for view-only** — create `chaltu-view` the same way, add to `ViewOnly`.

> Add the user to a group. Do not attach permissions to the person.

## Exercise 3: Test the Walls

Sign in as your view-only teammate and try something she isn't allowed to do.

- [ ] **Open a private window** — so you stay signed in as admin in the other tab.
- [ ] **Sign in as `chaltu-view`** — using the sign-in link and her password.
- [ ] **Go to EC2** — search bar, "EC2", open it, confirm you're in your normal Region.
- [ ] **Try to launch a server** — click Launch instance, fill anything in, click Launch.
  Watch it get refused.
- [ ] **Confirm view still works** — look at the Instances list. Viewing is allowed;
  creating is not.

> A denial here means success — you built a wall that works.

## Exercise 4: Read the Denial

The red error is a gift. It tells you WHO, WHAT, and WHY in plain sight.

```
User: chaltu-view
is not authorized to perform: ec2:RunInstances
because no identity-based policy allows this action
```

| Part | Meaning |
|---|---|
| **WHO** | The exact identity refused — no guessing which user you're signed in as |
| **WHAT** | The precise action that was missing — `ec2:RunInstances`, the real name of "launch a server" |
| **WHY** | "No policy allows it" means rule 1 (default deny) fired, not an explicit block |

---

