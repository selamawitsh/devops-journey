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

## Dry-run mode

Definition: show what the script WOULD do, without actually doing it.

    Normal run:                   Dry-run:
    ./deploy.sh                   ./deploy.sh --dry-run

    Creating directory...         [DRY-RUN] Would create directory...
    Copying files...              [DRY-RUN] Would copy files...
    Restarting service...         [DRY-RUN] Would restart service...

    (actions actually happen)     (nothing actually happens)

## Why the SAME command path matters for both modes

The dangerous version — two separate, disconnected descriptions of what
should happen:

    if dry_run; then
        echo "Would create directory"      <- this message is hand-written
    else
        mkdir -p /opt/myapp                  <- this is the real command
    fi

The trap: later, someone updates the real command (say, to
mkdir -p /opt/myapp/config) but forgets to update the hand-written dry-run
message to match. Now the preview LIES about what the script actually
does — genuinely dangerous, since the whole point of dry-run is trusting
what it tells you.

The correct version — one function, one single source of truth, used by
BOTH modes:

    create_directory() {
        if [[ "$DRY_RUN" == true ]]; then
            echo "[DRY-RUN] Would create $APP_DIR"
        else
            mkdir -p "$APP_DIR"
        fi
    }

Visual:

                 create_directory()
                        |
                   is dry-run?
                   /         \
                 yes           no
                  |             |
              describe        execute
              the action      the action
              (from the       (from the
              SAME $APP_DIR   SAME $APP_DIR
              variable)       variable)

Because both branches read from the exact same variables/arguments, the
preview can never drift out of sync with reality — if the real command
changes, the description automatically reflects that change too, since
they're generated from the same place, not maintained as two separate
copies.

Real-world relevance: before running a script that deletes old backups,
overwrites a production config, or restarts a live service, an engineer
runs --dry-run first, reads exactly what it claims it will do, and only
removes the flag once confident it's correct.

## Proper logging — separating normal output from problems

    Script
      |
    +-+-------------+
    |               |
  stdout          stderr
  normal          problems -
  output          warnings, errors

    echo "Deployment started"          -> stdout (default)
    echo "Deployment failed" >&2         -> stderr (explicit redirect)

Why separate them: because stdout and stderr can be redirected
INDEPENDENTLY of each other (Session 9):

    ./deploy.sh > output.log 2> errors.log

        output.log   <- only normal progress messages land here
        errors.log     <- only warnings/errors land here

This lets a person, a cron job, or a monitoring system filter and react
to failures completely separately from routine chatter, using nothing
but standard redirection — no special log-parsing tool required.

Wrapping this in functions instead of repeating echo everywhere:

    log_info()  { echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*"; }
    log_warn()  { echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2; }
    log_error() { echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2; }

    log_info "Starting deployment"      -> stdout
    log_warn "Config file missing"        -> stderr
    log_error "Deployment failed"           -> stderr

    ./script.sh 2>/dev/null      shows ONLY log_info output; WARN/ERROR
                                    discarded entirely since they went to
                                    stderr, which got redirected to the
                                    "black hole" /dev/null

## Configuration separated from logic

Without separation — everything mixed into one file:

    deploy.sh
      |
      +-- configuration   (APP_NAME, APP_DIR, RETENTION_DAYS...)
      +-- logic             (the actual commands and decisions)
      +-- logging             (log_info/log_warn/log_error)

Changing any setting means opening and editing the actual script logic —
risky, and requires understanding Bash to do safely.

With separation:

    config.sh                       deploy.sh
      |                                |
      +-- settings only                +-- logic
                                        +-- actions
                                        +-- logging
                                        +-- source config.sh   <- loads
                                            the settings in

    source config.sh     (or the shorthand:  . config.sh)

"source" reads a file's variable assignments directly into the CURRENT
shell's environment, exactly as if you had typed those lines yourself —
not a subprocess, no isolation, the variables become immediately usable
in the rest of the calling script.

Editing config.sh alone changes the script's behavior on its very next
run. The script's actual logic is never touched — someone who doesn't
know Bash at all can safely change a retention policy or a target
directory just by editing plain variable assignments in a separate file.

Real-world relevance: this is the exact same underlying idea behind .env
files, Kubernetes ConfigMaps, and Ansible variable files — separate WHAT
a script does (logic, stays constant) from WHICH values it uses
(configuration, changes per environment: dev/staging/production).

## All four patterns, combined

                 A real automation script
                          |
         +----------------+----------------+
         |                |                |
      config           dry-run          logging
         |                |                |
         +----------------+----------------+
                          |
                  idempotent actions

Typical real usage:

    source config.sh              load settings first
    ./deploy.sh --dry-run            preview every action, nothing runs
    ./deploy.sh                        actually execute, for real

And every individual action in a script built this way is:
  - safe to repeat (idempotent)
  - previewable before running for real (dry-run)
  - clearly logged, normal output separated from problems (logging)
  - configurable without touching code (config separation)

## Cheat sheet — Session 13

    Idempotency
      check state before acting:  if [[ -d "$DIR" ]]; then ... fi
      mkdir -p                       built-in idempotent shortcut

    Dry-run
      DRY_RUN=true/false               toggle via a flag like --dry-run
      one function, one command path     both modes read from it

    Logging
      log_info()   -> stdout
      log_warn()     -> stderr (>&2)
      log_error()      -> stderr (>&2)
      2>/dev/null         discards stderr only, keeps stdout

    Configuration
      config.sh              plain variable assignments, no logic
      source config.sh         loads those variables into the current shell

## Configuration separated from logic

Without separation — everything mixed into one file:

    deploy.sh
      |
      +-- configuration   (APP_NAME, APP_DIR, RETENTION_DAYS...)
      +-- logic             (the actual commands and decisions)
      +-- logging             (log_info/log_warn/log_error)

Changing any setting means opening and editing the actual script logic —
risky, and requires understanding Bash to do safely.

With separation:

    config.sh                       deploy.sh
      |                                |
      +-- settings only                +-- logic
                                        +-- actions
                                        +-- logging
                                        +-- source config.sh   <- loads
                                            the settings in

    source config.sh     (or the shorthand:  . config.sh)

"source" reads a file's variable assignments directly into the CURRENT
shell's environment, exactly as if you had typed those lines yourself —
not a subprocess, no isolation, the variables become immediately usable
in the rest of the calling script.

Editing config.sh alone changes the script's behavior on its very next
run. The script's actual logic is never touched — someone who doesn't
know Bash at all can safely change a retention policy or a target
directory just by editing plain variable assignments in a separate file.

Real-world relevance: this is the exact same underlying idea behind .env
files, Kubernetes ConfigMaps, and Ansible variable files — separate WHAT
a script does (logic, stays constant) from WHICH values it uses
(configuration, changes per environment: dev/staging/production).

## All four patterns, combined

                 A real automation script
                          |
         +----------------+----------------+
         |                |                |
      config           dry-run          logging
         |                |                |
         +----------------+----------------+
                          |
                  idempotent actions

Typical real usage:

    source config.sh              load settings first
    ./deploy.sh --dry-run            preview every action, nothing runs
    ./deploy.sh                        actually execute, for real

And every individual action in a script built this way is:
  - safe to repeat (idempotent)
  - previewable before running for real (dry-run)
  - clearly logged, normal output separated from problems (logging)
  - configurable without touching code (config separation)

## Cheat sheet — Session 13

    Idempotency
      check state before acting:  if [[ -d "$DIR" ]]; then ... fi
      mkdir -p                       built-in idempotent shortcut

    Dry-run
      DRY_RUN=true/false               toggle via a flag like --dry-run
      one function, one command path     both modes read from it

    Logging
      log_info()   -> stdout
      log_warn()     -> stderr (>&2)
      log_error()      -> stderr (>&2)
      2>/dev/null         discards stderr only, keeps stdout

    Configuration
      config.sh              plain variable assignments, no logic
      source config.sh         loads those variables into the current shell
