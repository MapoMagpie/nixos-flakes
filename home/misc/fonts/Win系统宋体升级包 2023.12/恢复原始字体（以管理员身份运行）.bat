@echo off
setlocal EnableDelayedExpansion
set "font=%SystemRoot%\Fonts"
set "base=simsun.ttc"
set "extb=simsunb.ttf"
set "fontkey=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
set "fallback=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\LanguagePack\SurrogateFallback"
set "linkkey=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\FontLink\SystemLink"

echo * 取得文件权限
if exist "%font%\%base%*" (
	takeown /f "%font%\%base%*" /a
	icacls "%font%\%base%*" /grant Administrators:F
)
if exist "%font%\%extb%*" (
	takeown /f "%font%\%extb%*" /a
	icacls "%font%\%extb%*" /grant Administrators:F
)

echo * 删除原备份文件
if exist "%font%\%base%.bak" del /f "%font%\%base%.bak"
if exist "%font%\%extb%.bak" del /f "%font%\%extb%.bak"

if exist "%font%\%base%.org" (
	echo * "%font%\%base%"文件更名
	ren "%font%\%base%" "%base%.bak"
	echo * 恢复"%font%\%base%"文件
	ren "%font%\%base%.org" "%base%"
	if errorlevel 1 echo * 恢复失败！
)

if exist "%font%\%extb%.org" (
	echo * "%font%\%extb%"文件更名
	ren "%font%\%extb%" "%extb%.bak"
	echo * 恢复"%font%\%extb%"文件
	ren "%font%\%extb%.org" "%extb%"
	if errorlevel 1 echo * 恢复失败！
)

pause
