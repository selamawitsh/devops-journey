#!/bin/bash
set -euo pipefail

CONFIG_FILE="$(dirname "$0")/template_config.sh"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

log_info()  { echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $*"; }
log_warn()  { echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2; }
log_error() { echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2; }

run_or_show() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "[DRY RUN] Would run: $*"
    else
        "$@"
    fi
}

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    log_warn "No config file found, using defaults"
    TARGET_DIR="/tmp/production_style_demo"
fi

log_info "Starting run (dry_run=$DRY_RUN)"

if [[ -d "$TARGET_DIR" ]]; then
    log_info "Target directory already exists: $TARGET_DIR"
else
    run_or_show mkdir -p "$TARGET_DIR"
    log_info "Target directory created: $TARGET_DIR"
fi

log_info "Run finished"
