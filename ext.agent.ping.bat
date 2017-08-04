@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
setlocal enableextensions
if "%2"=="1" (
  for /f "tokens=4 delims==" %%i in ('ping -n 3 -w 2000 %1 ^|find /V "TTL" ^| find "ms"') do set delay=%%i
  if "!delay!"=="" (echo 0 ) else echo 1
)
if "%2"=="2" (
  for /f "tokens=4 delims==" %%i in ('ping -n 3 -w 2000 %1 ^|find /V "TTL" ^| find "ms"') do set delay=%%i
  if not "!delay!"=="" echo !delay:ms=!
)
