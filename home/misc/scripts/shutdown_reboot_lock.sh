#!/bin/sh

# usage() {
#     echo "Usage: $0 [OPTION]"
#     echo "Options:"
#     echo "  1. Shutdown    - 立即关机"
#     echo "  2. Reboot      - 立即重启"
#     echo "  3. Lock Screen - 锁定屏幕"
#     echo "  4. Cancel      - 取消关机或重启"
#     exit 1
# }

# if [ $# -ne 1 ]; then
#     usage
# fi
opt=$(echo -e "1. Shutdown\n2. Reboot\n3. Lock Screen\n4. Cancel" | fuzzel -d)

case $opt in
    "1. Shutdown")
        notify-send "Shutdown in 15 seconds"
        sleep 15 && shutdown now &
        ;;
    "2. Reboot")
        notify-send "Reboot in 10 seconds"
        sleep 10 && reboot &
        ;;
    "3. Lock Screen")
        hyprlock
        ;;
    "4. Cancel")
        pkill -f "sleep 15" && notify-send "Shutdown canceled"
        pkill -f "sleep 10" && notify-send "Reboot canceled"
        ;;
    *)
        echo "错误：无效选项 '$opt'"
        ;;
esac

exit 0
