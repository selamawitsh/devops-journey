# Commands — Session 13

# idempotency
./not_idempotent.sh    # fails on 2nd run - directory already exists
./idempotent.sh          # safe on every run - checks first
mkdir -p /tmp/app_config   # mkdir's own built-in idempotent flag

# dry-run
./dry_run_demo.sh --dry-run    # describes actions, touches nothing
./dry_run_demo.sh                # actually runs mkdir/touch/rm for real

# logging
./logging_demo.sh                  # all 4 log levels print
./logging_demo.sh 2>/dev/null        # only INFO remains, WARN/ERROR discarded

# configuration
./hardcoded.sh                         # values baked into the script
./uses_config.sh                         # values loaded via source config.sh
sed -i 's/RETENTION_DAYS=7/RETENTION_DAYS=30/' config.sh
./uses_config.sh                             # behavior changed, script untouched
