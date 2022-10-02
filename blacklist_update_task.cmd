@echo off 
pushd "%~dp0"
set blacklist_url="https://antizapret.prostovpn.org/domains-export.txt"
set blacklist=%cd%\russia-blacklist.txt
:: set log=%temp%\blacklist_update.log
set mydate=%date:~4,2%/%date:~7,2%/%date:~10,4%
set mytime=%time: =0%
set log=nul
schtasks /Query /TN "GoodbyeDPI blacklist update" > nul
if ERRORLEVEL 1 schtasks /Create /TN "GoodbyeDPI blacklist update" /RU Administrators /TR "%~fs0" /SC HOURLY /ST %mytime:~,-3% /SD %mydate%
:download
:: bitsadmin /transfer blacklist %blacklist_url% "%temp%\goodbyedpi-blacklist.txt.new"
wget %blacklist_url% -O "%temp%\goodbyedpi-blacklist.txt.new"
for %%i in (%temp%\goodbyedpi-blacklist.txt.new) do (set /a size=%%~Zi)
if %size% == 0 (
	del /F /Q %temp%\goodbyedpi-blacklist.txt.new
	timeout 120
	goto download
)
<nul set /p strTemp=%date% %time:~0,-3% >> %log%
fc %blacklist% %temp%\goodbyedpi-blacklist.txt.new > nul
if ERRORLEVEL 1 (
	echo обновление списка блокировок >> %log%
	net stop GoodbyeDPI
	move /Y %temp%\goodbyedpi-blacklist.txt.new %blacklist%
	net start GoodbyeDPI
) else (
	echo список блокировок без изменений >> %log%
	del /F /Q %temp%\goodbyedpi-blacklist.txt.new
)
popd
exit