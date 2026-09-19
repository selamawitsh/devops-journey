# Notes — Automation Patterns

## Idempotency
A script is idempotent if running it once, or running it 5 times, produces
the same end state with no errors — safe to re-run at any time.

Non-idempotent example:
  mkdir /tmp/app_config        <- fails on every run after the first,
                                   since the directory already exists

Idempotent fix — check first, act only if needed:
  if [[ -d /tmp/app_config ]]; then
      echo "already exists, skipping"
  else
      mkdir /tmp/app_config
  fi

Shortcut specific to mkdir: mkdir -p is already idempotent on its own —
silently does nothing if the directory exists, no error, no need for a
manual if check.

Real-world relevance: a provisioning or deployment script that runs
automatically (via cron, CI/CD, or a config management tool checking in
repeatedly) MUST be idempotent, or it works once and then breaks on
every subsequent run even though nothing is actually wrong.

## Dry-run mode
Lets a script describe what it WOULD do without actually doing it —
critical before running anything destructive or hard to reverse.

  run_or_show() {
      if [[ "$DRY_RUN" == true ]]; then
          echo "[DRY RUN] Would run: $*"
      else
          echo "Running: $*"
          "$@"
      fi
  }

Key design point: both branches wrap the SAME command ("$@", quoted, from
Session 8) rather than maintaining two separate descriptions of what
"should" happen — this is what keeps the dry-run output trustworthy and
in sync with what the real run actually does.

${1:-} (Session 11's default-value expansion) is used to safely check
whether --dry-run was passed as an argument, without triggering an
"unbound variable" error under set -u when no argument was given at all.

Real-world relevance: before running a script that deletes old backups
or overwrites production config, an engineer runs --dry-run first, reads
exactly what it claims it would do, and only removes the flag once
confident it's correct. This is one of the biggest habits separating
careful production scripts from ones that cause middle-of-the-night
incidents.

## Proper logging
  log_info()  { echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*"; }
  log_warn()  { echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2; }
  log_error() { echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2; }

INFO goes to stdout. WARN and ERROR go to stderr (>&2, from Session 9).
This lets anything downstream — a person, a cron job, a monitoring
system — separate normal progress from things that need attention using
nothing but standard redirection:
  ./script.sh 2>/dev/null    shows only normal output, discards
                               warnings/errors entirely
A cron job can alert only when a script's stderr is non-empty,
completely independent of how much routine INFO chatter it produces.

## Configuration separated from logic
Hardcoded (bad for reuse/reconfiguration):
  BACKUP_DIR="/home/selamawit/backups"
  RETENTION_DAYS=7
  (values baked directly into the script)

Config file + source (good):
  config.sh:
    BACKUP_DIR="/home/selamawit/backups"
    RETENTION_DAYS=7

  script.sh:
    source config.sh          (or: . config.sh)
    echo "$BACKUP_DIR"

source loads a file's variable assignments directly into the current
shell's environment, as if you'd typed them yourself. Editing config.sh
alone changes the script's behavior on its next run — no edit to the
actual script logic required.

Real-world relevance: this is the same underlying idea behind .env
files, Kubernetes ConfigMaps, and Ansible variable files — separating
WHAT a script does (logic) from WHICH values it uses (configuration), so
non-developers or different environments (dev/staging/production) can
reconfigure behavior safely, without touching code.
