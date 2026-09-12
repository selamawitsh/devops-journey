# Commands — Session 1

echo $SHELL              # login shell (can be stale, don't trust for live checks)
bash --version            # actual bash binary version
ps -p $$                  # ground truth: what shell this process is actually running

cat > hello.sh << 'INNER'  # heredoc: writes everything until INNER as file content
#!/bin/bash
echo "Hello, Selamawit"
INNER

chmod +x hello.sh          # sets execute bit
./hello.sh                 # kernel executes directly, needs +x and shebang
bash hello.sh               # bash reads file as input, no +x needed

ls -l /bin/bash             # confirms /bin/bash already has execute permission for everyone
ls -l hello.sh               # compare permission bits
