# Commands — Session 7

greet() { echo "Hello from a function"; }
greet

function greet2 { echo "Hello from the other style"; }
greet2

greet3                          # fails: called before defined
greet3() { echo "unreachable"; }

deploy() {
    echo "Deploying to server: $1"
    echo "Using environment: $2"
    echo "Total arguments received: $#"
}
deploy "web01" "production"
deploy                            # empty $1/$2, $# is 0, no error

name="global value"
change_name() { name="changed inside function"; }
change_name
echo "$name"                       # global overwritten — no local used

name="global value"
change_name_safely() {
    local name="changed inside function only"
    echo "Inside function: $name"
}
change_name_safely
echo "Outside function: $name"      # global untouched — local used

add_numbers() { local sum=$(( $1 + $2 )); return $sum; }
add_numbers 3 4; echo $?              # 7 — fine, under 255
add_numbers 200 100; echo $?           # 44 — wrapped! 300 mod 256

add_numbers() { local sum=$(( $1 + $2 )); echo "$sum"; }
result=$(add_numbers 200 100)
echo "The actual sum is: $result"        # 300 — correct, via echo + capture
