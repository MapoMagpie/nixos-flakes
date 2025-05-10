#!/bin/sh
tmpfile=$(mktemp)".qml"
cat > "$tmpfile"     # 从stdin读取并写入临时文件
qmlformat "$tmpfile"
rm "$tmpfile"
