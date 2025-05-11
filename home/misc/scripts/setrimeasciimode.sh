#!/bin/sh

if [ $# -eq 0 ]; then
    # 无参数时，获取当前状态并取反
    isAsciiMode=$(dbus-send --session --print-reply=literal --dest=org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1.IsAsciiMode | sd '.*?(true|false)' '$1')
    [ "$isAsciiMode" = "true" ] && newMode="false" || newMode="true"
else
    # 有参数时，直接使用参数值（默认为true）
    case "$1" in
        "false") newMode="false" ;;
        *)       newMode="true"  ;;
    esac
fi

# 统一设置新状态
dbus-send --session --print-reply=literal --dest=org.fcitx.Fcitx5 /rime org.fcitx.Fcitx.Rime1.SetAsciiMode boolean:"$newMode" > /dev/null
