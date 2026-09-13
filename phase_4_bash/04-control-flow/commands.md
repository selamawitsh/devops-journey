# Commands — Session 4

count=5
if [[ $count -gt 3 ]]; then
    echo "count is greater than 3"
elif [[ $count -eq 3 ]]; then
    echo "count is exactly 3"
else
    echo "count is 3 or less"
fi

mkdir -p testdir
touch testfile.txt

if [[ -d testdir && -f testfile.txt ]]; then
    echo "both checks passed"
fi

if [[ -z "" || -n "not empty" ]]; then
    echo "at least one string check passed"
fi
