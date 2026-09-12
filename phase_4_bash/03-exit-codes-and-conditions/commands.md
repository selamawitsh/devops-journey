# Commands — Session 3

ls /home/selamawit          # succeeds
echo $?                       # -> 0

ls /this/does/not/exist        # fails
echo $?                         # -> 2 (misuse/invalid path)

true
echo $?                          # -> 0

false
echo $?                           # -> 1

type [                              # [ is a shell builtin
type test                            # test is a shell builtin
type [[                               # [[ is a shell keyword

name="John Smith"
[ $name = "John Smith" ]                # fails: "too many arguments" (word-splitting)
[[ $name = "John Smith" ]]               # works: no word-splitting
[ "$name" = "John Smith" ]                # works: quoting protects it, even with [
