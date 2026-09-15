# Commands — Session 10

# set -e
./no_set_e.sh          # continues past the failed ls, all steps print
./with_set_e.sh          # stops immediately at the failed ls

# set -u
./no_set_u_safe.sh        # $backup_dir silently empty -> "/temp"
./with_set_u.sh              # "backup_dir: unbound variable" - stops immediately

# pipefail
set +o pipefail
ls /this/does/not/exist | wc -l
echo "Exit code WITHOUT pipefail: $?"          # -> 0 (wc's status, ls's failure hidden)

set -o pipefail
ls /this/does/not/exist | wc -l
echo "Exit code WITH pipefail: $?"               # -> 2 (ls's real failure surfaced)

# trap
./trap_demo.sh                                     # let it finish normally - cleanup runs at the end
./trap_demo.sh                                       # Ctrl+C mid-sleep - cleanup still runs
