# Commands — Session 12

find . -name "*.log"                      # recursive filename search
find . -type f                              # files only
find . -type d                               # directories only (includes .)
find . -mtime -1                               # modified within last day
find . -size +0c                                 # non-empty files/dirs (dirs have metadata size)
find . -name "*.log" -exec echo "Found: {}" \;     # run a command per match

grep "ERROR" logs/app.log            # matching lines
grep -i "error" logs/app.log           # case-insensitive
grep -c "ERROR" logs/app.log             # count only
grep -n "ERROR" logs/app.log               # with line numbers
grep -v "ERROR" logs/app.log                 # inverted: non-matching lines
grep -A 1 "ERROR" logs/app.log                 # match plus 1 line of context after
grep "ERROR" logs/app.log | wc -l                # count via pipe, same as -c

sed 's/ERROR/CRITICAL/' logs/app.log          # preview only, file untouched
cat logs/app.log                                # confirms file unchanged
sed -i 's/ERROR/CRITICAL/' logs/app.log            # actually modifies the file
echo "ERROR ERROR ERROR" | sed 's/ERROR/CRITICAL/'    # first match only
echo "ERROR ERROR ERROR" | sed 's/ERROR/CRITICAL/g'     # all matches, g flag

awk '{print $1}' logs/app.log            # field 1 of every line
awk '{print $2}' logs/app.log              # field 2
awk '/CRITICAL/ {print $1, $2}' logs/app.log # pattern filter + column print

echo "web01:running:8080" | cut -d ":" -f 1     # first field, colon-delimited
echo "web01:running:8080" | cut -d ":" -f 1,3     # multiple fields

sort servers_status.txt                   # groups identical lines together
sort servers_status.txt | uniq              # now duplicates collapse correctly
sort servers_status.txt | uniq -c             # with occurrence counts
uniq servers_status.txt                         # unsorted - does nothing useful

find . -name "*.log" | xargs echo "Processing:"      # one command, all filenames batched in
find . -name "*.log" -exec echo "Found:" {} \;         # one command PER file
