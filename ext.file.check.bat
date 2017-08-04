@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
setlocal enableextensions

set file_path=%1
set date1=%date%
set yyyy=%date1:~0,4%
set mm=%date1:~5,2%
set dd=%date1:~8,2%

if %mm% EQU 10 ( set m=a)
if %mm% EQU 11 ( set m=b)
if %mm% EQU 12 ( set m=c)
if %mm% LSS 10 ( set m=%mm:~1,1%)
if %mm% GTR 9 ( set M=%mm%) else set M=%mm:~1,1%
if %dd% GTR 9 ( set D=%dd%) else set D=%dd:~1,1%

echo %file_path% | findstr /C:"{yyyymmdd}" > nul && set file_path=!file_path:{yyyymmdd}=%yyyy%%mm%%dd%! 
echo %file_path% | findstr /C:"{yyyy-mm-dd}" > nul && set file_path=!file_path:{yyyy-mm-dd}=%yyyy%-%mm%-%dd%! 
echo %file_path% | findstr /C:"{yyyy-M-D}" > nul && set file_path=!file_path:{yyyy-M-D}=%yyyy%-%M%-%D%!
echo %file_path% | findstr /C:"{mdd}" > nul && set file_path=!file_path:{mdd}=%m%%dd%!

rem echo file_path=%file_path%

if "%2"=="1" (
  if exist %file_path% ( echo 1 ) else echo 0
)
if "%2"=="2" (
  for /f "tokens=3 delims== " %%i in ('dir /a-d %file_path% ^| find "/"') do set file_size=%%i
  if not "!file_size!"=="" echo !file_size!
)
