# Notes — Automation Patterns

## The big picture

    Bash automation script
              |
    +---------+---------+---------+
    |         |         |         |
 Config   Decision/   Logging   dry-run?
           Logic
    |         |         |         |
    +---------+---------+---------+
              |
        Actual action

Four separate concerns, working together in every real production script.

## Idempotency

Definition: a script is idempotent if running it once, or running it 10
times, produces the SAME final state, with no errors from "it's already
done."

Non-idempotent:

    Run 1: mkdir /tmp/app_config    -> created, succeeds
    Run 2: mkdir /tmp/app_config      -> FAILS, "File exists"
    Run 3: mkdir /tmp/app_config        -> FAILS, "File exists"

Idempotent (check first, act only if needed):

    if [[ -d /tmp/app_config ]]; then
        echo "already exists, skipping"
    else
        mkdir /tmp/app_config
    fi

    Run 1: doesn't exist yet -> creates it
    Run 2: already exists      -> skips, no error
    Run 3: already exists        -> skips, no error

    Final state every time: /tmp/app_config exists. No failures, ever.

Same idea applies beyond directories — e.g. creating a user:

    Run 1: useradd deploy    -> user created
    Run 2: useradd deploy      -> FAILS, "user already exists"

    Idempotent version, conceptually:
        if user "deploy" exists
            do nothing
        else
            create the user

mkdir -p is a convenient built-in shortcut that's ALREADY idempotent on
its own for directories specifically — silently does nothing if the
directory exists, no if-check needed. But idempotency isn't "always use
-p" — that's just one command that happens to support the pattern
natively. The actual concept is broader than any one flag.

## The mindset shift this requires

    BAD mindset:  "what COMMANDS should I run?"

        run mkdir
        run chmod
        run cp
        run systemctl restart

    BETTER mindset:  "what STATE do I want the system to end up in?"

        [ ] directory exists
        [ ] correct permissions
        [ ] correct application files
        [ ] service running

The difference: a command-list mindset assumes a clean starting point
every time. A desired-state mindset checks "is this already true?" before
acting, and only takes action when it isn't — which is exactly why it
survives being run repeatedly, on a system in any starting condition.

This exact mindset — describe the desired end state, let the tool figure
out what needs to change to get there — is the foundation of Docker,
Ansible, Terraform, and Kubernetes. Idempotency in a 5-line Bash script is
the same idea you'll meet again at much larger scale later in this
roadmap.

Real-world relevance: a script that runs automatically (cron, CI/CD, a
config management tool checking in repeatedly) MUST be idempotent, or it
works exactly once and then breaks on every later run even though
nothing is actually wrong.
