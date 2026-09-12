# Commands — Session 2

name="Selamawit"              # correct assignment, no spaces around =
name = "Selamawit"             # fails — bash tries to run "name" as a command

echo "Hello, $name"             # double quotes: expands $name
echo 'Hello, $name'             # single quotes: literal, no expansion
echo "Cost: \$5"                 # backslash escapes the $, prints literal $5

today=$(date)                    # modern command substitution
today2=`date`                     # legacy backtick command substitution

plain_var="not exported"
export env_var="exported"
bash -c 'echo $plain_var'          # empty — child shell never received it
bash -c 'echo $env_var'             # prints — export copied it to the child

readonly PI=3.14159
PI=3.14                              # fails — readonly variable
