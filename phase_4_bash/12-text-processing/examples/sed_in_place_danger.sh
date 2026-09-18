#!/bin/bash

echo "Preview only (file NOT changed yet):"
sed 's/INFO/NOTICE/' logs/app.log

echo ""
echo "File content before -i:"
cat logs/app.log

echo ""
echo "Now applying -i (file WILL change):"
sed -i 's/INFO/NOTICE/' logs/app.log

echo ""
echo "File content after -i:"
cat logs/app.log
