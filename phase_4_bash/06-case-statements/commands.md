# Commands — Session 6

action="start"
case "$action" in
    start) echo "Starting the service..." ;;
    stop) echo "Stopping the service..." ;;
    restart) echo "Restarting the service..." ;;
    *) echo "Unknown option: $action" ;;
esac

read -p "Continue? (y/n): " answer
case "$answer" in
    y|Y|yes|Yes) echo "Proceeding..." ;;
    n|N|no|No) echo "Cancelled." ;;
    *) echo "Please answer y or n." ;;
esac

filename="backup.tar.gz"
case "$filename" in
    *.tar.gz) echo "Compressed tarball archive" ;;
    *.log) echo "Log file" ;;
    *.sh) echo "Shell script" ;;
    *) echo "Unknown file type" ;;
esac
