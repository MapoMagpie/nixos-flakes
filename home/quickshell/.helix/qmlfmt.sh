#!/bin/sh
tmpfile=$(mktemp)".qml"
cat > "$tmpfile"     # 从stdin读取并写入临时文件
if ! command -v qmlformat >/dev/null 2>&1; then
  cat $tmpfile
else
  qmlformat "$tmpfile"
fi
rm "$tmpfile"
