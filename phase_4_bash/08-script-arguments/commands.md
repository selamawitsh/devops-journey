# Commands — Session 8

./args_demo.sh                                  # $1/$2 empty, $# is 0
./args_demo.sh web01                              # $1=web01, $# is 1
./args_demo.sh web01 production extra_arg          # $3=extra_arg, $# is 3 (data still there, just unreferenced)

./all_args.sh "New York" "Los Angeles"
# unquoted $@ and $*  -> both word-split: New / York / Los / Angeles
# quoted "$@"          -> New York / Los Angeles (preserved)
# quoted "$*"           -> New York Los Angeles (joined into one string)

./shift_demo.sh web01 web02 web03
# shift moves $2->$1, $3->$2 each call, decrements $#

./getopts_demo.sh -e production -v                 # e requires OPTARG, v is boolean
./getopts_demo.sh -x                                  # "illegal option -- x" + case *) usage message
