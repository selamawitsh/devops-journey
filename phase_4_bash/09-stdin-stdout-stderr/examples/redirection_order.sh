#!/bin/bash

echo "Correct order (stdout redirected first, stderr follows it):"
ls /home/selamawit /this/does/not/exist > correct_order.txt 2>&1
echo "Contents of correct_order.txt:"
cat correct_order.txt

echo ""
echo "Wrong order (stderr bound to terminal before stdout redirected):"
ls /home/selamawit /this/does/not/exist 2>&1 > wrong_order.txt
echo "Contents of wrong_order.txt (error is MISSING here, it printed above instead):"
cat wrong_order.txt
