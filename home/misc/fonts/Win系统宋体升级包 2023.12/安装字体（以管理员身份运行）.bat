@echo off
setlocal EnableDelayedExpansion
set "font=%SystemRoot%\Fonts"
set "base=simsun.ttc"
set "extb=simsunb.ttf"
set "extg=simsung.ttf"
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
if exist "%font%\%extg%*" (
	takeown /f "%font%\%extg%*" /a
	icacls "%font%\%extg%*" /grant Administrators:F
)

if not exist "%font%\%base%.org" (
	echo * 备份原始"%font%\%base%"文件
	copy /y "%font%\%base%" "%font%\%base%.org"
)
if not exist "%font%\%extb%.org" (
	echo * 备份原始"%font%\%extb%"文件
	copy /y "%font%\%extb%" "%font%\%extb%.org"
)

echo * 删除原备份文件
if exist "%font%\%base%.bak" del /f "%font%\%base%.bak"
if exist "%font%\%extb%.bak" del /f "%font%\%extb%.bak"
if exist "%font%\%extg%.bak" del /f "%font%\%extg%.bak"

if exist "%font%\%base%" (
	echo * "%font%\%base%"文件更名
	ren "%font%\%base%" "%base%.bak"
	if errorlevel 1 goto error
)
echo * 更新"%font%\%base%"文件
copy /y "%~dp0%base%" "%font%\%base%"
if errorlevel 1 goto error

if exist "%font%\%extb%" (
	echo * "%font%\%extb%"文件更名
	ren "%font%\%extb%" "%extb%.bak"
	if errorlevel 1 goto error
)
echo * 更新"%font%\%extb%"文件
copy /y "%~dp0%extb%" "%font%\%extb%"
if errorlevel 1 goto error

if exist "%font%\%extg%" (
	echo * "%font%\%extg%"文件更名
	ren "%font%\%extg%" "%extg%.bak"
	if errorlevel 1 goto error
)
echo * 更新"%font%\%extg%"文件
copy /y "%~dp0%extg%" "%font%\%extg%"
if errorlevel 1 goto error

echo * 修改注册表
reg add "%fontkey%" /v "SimSun & NSimSun (TrueType)" /d "%base%" /f
reg add "%fontkey%" /v "SimSun-ExtB (TrueType)" /d "%extb%" /f
reg add "%fontkey%" /v "SimSun-ExtG (TrueType)" /d "%extg%" /f

reg add "%fallback%" /v "Plane1" /d "SimSun-ExtG" /f
reg add "%fallback%" /v "Plane2" /d "SimSun-ExtB" /f
reg add "%fallback%" /v "Plane3" /d "SimSun-ExtG" /f
reg add "%fallback%\SimSun" /v "Plane1" /d "SimSun-ExtG" /f
reg add "%fallback%\SimSun" /v "Plane2" /d "SimSun-ExtB" /f
reg add "%fallback%\SimSun" /v "Plane3" /d "SimSun-ExtG" /f
for /f "tokens=*" %%a in ('reg query "%fallback%"') do (
	set "str=%%a"
	if /i "!str:~0,4!"=="HKEY" (
		reg query "%%a" /v "Plane1" >nul 2>nul
		if errorlevel 1 reg add "%%a" /v "Plane1" /d "SimSun-ExtG" /f
		reg query "%%a" /v "Plane2" >nul 2>nul
		if errorlevel 1 reg add "%%a" /v "Plane2" /d "SimSun-ExtB" /f
		reg query "%%a" /v "Plane3" >nul 2>nul
		if errorlevel 1 reg add "%%a" /v "Plane3" /d "SimSun-ExtG" /f
	)
)

reg query "%linkkey%" /v "SimSun-ExtB" >nul 2>nul
if errorlevel 1 reg add "%linkkey%" /v "SimSun-ExtB" /t REG_MULTI_SZ /d "MICROSS.TTF,108,122\0MICROSS.TTF\0SIMSUN.TTC,SimSun\0MSGOTHIC.TTC,MS UI Gothic" /f
reg query "%linkkey%" /v "SimSun-ExtG" >nul 2>nul
if errorlevel 1 reg add "%linkkey%" /v "SimSun-ExtG" /t REG_MULTI_SZ /d "MICROSS.TTF,108,122\0MICROSS.TTF\0SIMSUN.TTC,SimSun\0MSGOTHIC.TTC,MS UI Gothic" /f

goto end

:error
echo * 安装失败！
if exist "%font%\%base%.bak" (
	echo * 恢复"%font%\%base%"文件
	if exist "%font%\%base%" del /f "%font%\%base%"
	ren "%font%\%base%.bak" "%base%"
)
if exist "%font%\%extb%.bak" (
	echo * 恢复"%font%\%extb%"文件
	if exist "%font%\%extb%" del /f "%font%\%extb%"
	ren "%font%\%extb%.bak" "%extb%"
)
if exist "%font%\%extg%.bak" (
	echo * 恢复"%font%\%extg%"文件
	if exist "%font%\%extg%" del /f "%font%\%extg%"
	ren "%font%\%extg%.bak" "%extg%"
)
:end
pause
