@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
setlocal enableextensions

set a=0
set b=0
set c=0
set d=0
set e=0
set dateline=%date:~0,4%%date:~5,2%%date:~8,2%
rem set dateline=20170525

set rptfile=%1

set rptfile=!rptfile:'=!

if exist %rptfile% (
	for /f "skip=1 delims=| tokens=1,2,5" %%i in (%rptfile%) do (
	  set getfile=%%i
	  set getdate=%%j
	  set getstats=%%k
	  
rem	  echo !getfile!---!getdate!---!getstats!
	  
	  if "!getdate!"=="%dateline%" (
		set /a c=!c!+1
		if "!getstats!"=="2" set /a a=!a!+1
		if "!getstats!"=="1" set /a b=!b!+1
		if "!getfile:~0,2!"=="GH" (
		  set /a d=!d!+1
		  if "!getstats!"=="2" set /a e=!e!+1
		)
		if "!getfile:~0,5!"=="IPOGH" (
		  set /a d=!d!+1
		  if "!getstats!"=="2" set /a e=!e!+1
		)
		if "!getfile:~0,3!"=="ZQY" (
		  set /a d=!d!+1
		  if "!getstats!"=="2" set /a e=!e!+1
		)
	  )
	)
rem	echo %dateline%.!d!.!e!.!c!
) else (
	rem 文件不存在
rem	echo %rptfile%
	set return=9999
	goto end
)
if "%2"=="1" (
  rem 未下载数量返回
  set return=!b!
)
if "%2"=="2" (
  rem 已下载数量返回
  set return=!a!
)
if "%2"=="3" (
  rem 返回完成状态：1、已全部完成，0、未全部完成
  if "!c!"=="0" ( set return=0 ) else if "!c!"=="!a!" ( set return=1) else set return=0
)
if "%2"=="4" (
  rem 返回IPOGH\GH\ZQY完成状态：>1、已全部完成，=0、未全部完成
  if "!d!"=="0" ( set return=0 ) else if "!d!"=="!e!" ( set return=!e! ) else set return=0
)
:end
echo %return%
rem echo %date:~0,10%-%time%: %rptfile% %return% >> c:\zabbix_agentd.log
