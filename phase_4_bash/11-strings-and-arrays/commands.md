# Commands — Session 11

unset name
echo "${name:-Guest}"              # Guest, name stays unset
echo "${name:=Guest}"                # Guest, name is NOW set to Guest
echo "${name:?Error: must be set}"     # errors if unset, stops the script
value="hello"
echo "${value:+Value is set}"           # prints replacement, only if value IS set

path="/home/selamawit/backups/db_backup.tar.gz"
echo "${path#*/}"                          # shortest strip from front
echo "${path##*/}"                          # longest strip from front (basename)
echo "${path%/*}"                             # shortest strip from back (dirname)
echo "${path%%.*}"                             # longest strip from back

name="Selamawit"
echo "${#name}"                                  # string length: 9

sentence="the cat sat on the mat"
echo "${sentence/cat/dog}"                          # first match only
echo "${sentence//the/a}"                             # all matches

servers=("web01" "web02" "web03")
echo "${servers[0]}"                                    # first element
echo "${servers[@]}"                                      # all elements
echo "${#servers[@]}"                                       # count of elements
servers+=("web04")                                            # append

for i in "${!servers[@]}"; do echo "Index $i: ${servers[$i]}"; done   # loop with index

servers=("web01" "web server two" "web03")
for s in "${servers[@]}"; do echo "[$s]"; done                          # preserved, quoted
for s in "${servers[*]}"; do echo "[$s]"; done                            # joined into one string
