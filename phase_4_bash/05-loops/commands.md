# Commands — Session 5

touch app1.log app2.log app3.log
for file in *.log; do echo "Found log file: $file"; done

rm app1.log app2.log app3.log
for file in *.log; do echo "Found log file: $file"; done   # prints literal *.log

shopt -s nullglob
for file in *.log; do echo "Found log file: $file"; done    # no output, as expected

counter=1
while [[ $counter -le 5 ]]; do
    echo "Counter is: $counter"
    counter=$((counter + 1))
done

counter=1
until [[ $counter -gt 5 ]]; do
    echo "Counter is: $counter"
    counter=$((counter + 1))
done

for num in 1 2 3 4 5 6 7 8 9 10; do
    if [[ $num -eq 5 ]]; then break; fi
    echo "Number: $num"
done

for num in 1 2 3 4 5 6 7 8 9 10; do
    if [[ $((num % 2)) -eq 0 ]]; then continue; fi
    echo "Odd number: $num"
done
