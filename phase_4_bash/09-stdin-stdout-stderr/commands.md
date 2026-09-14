# Commands — Session 9

ls /home/selamawit /this/does/not/exist          # both streams print to terminal

ls /home/selamawit /this/does/not/exist > output.txt     # stdout only redirected
cat output.txt                                              # error never landed here, it still printed to screen

echo "first line" > log.txt
cat log.txt
echo "second line" > log.txt                                  # overwrites - "first line" gone
cat log.txt
echo "third line" >> log.txt                                    # appends
cat log.txt

ls /home/selamawit /this/does/not/exist 2> errors_only.txt        # stderr only
cat errors_only.txt

ls /home/selamawit /this/does/not/exist > everything.txt 2>&1       # both combined, correct order
cat everything.txt

ls -la /home/selamawit | grep ".txt"
ps aux | grep bash
