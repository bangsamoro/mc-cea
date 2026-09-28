@echo off
REM ===================================================================
REM  Publish MC-CEA   C  ->  B   over SFTP
REM
REM  Run this ON C (RDP in from A). It mirrors the site folder into
REM  /var/www/html/mc-cea on B with WinSCP, so every later edit is a
REM  single double-click.
REM
REM  Where is the site?  By default: the folder this script lives in,
REM  i.e. <site>\deploy\deploy-mc-cea.bat  ->  <site>.  So it works
REM  whatever the clone folder is called.  Override if you need to:
REM      deploy-mc-cea.bat D:\sites\mc-cea
REM ===================================================================

set "WINSCP=C:\Program Files (x86)\WinSCP\WinSCP.com"

set "SITE=%~1"
if "%SITE%"=="" for %%I in ("%~dp0..") do set "SITE=%%~fI"

if not exist "%WINSCP%" (
  echo [!] WinSCP.com not found at "%WINSCP%"
  echo     Install WinSCP, or edit the WINSCP= line in this file.
  pause & exit /b 1
)
if not exist "%SITE%\index.html" (
  echo [!] No index.html found in "%SITE%"
  echo     Pass the site folder explicitly, e.g.
  echo         deploy-mc-cea.bat C:\Users\DELL\MCCEA
  pause & exit /b 1
)

echo Site folder: %SITE%

REM --- 1/2  refresh from GitHub, if this folder is a git clone -----------
REM          (an extracted zip has no .git, so the pull is skipped and the
REM           folder is published as-is - that is fine)
if exist "%SITE%\.git" (
  echo === 1/2  git pull origin main ===
  pushd "%SITE%"
  git pull origin main || (echo [!] git pull failed & popd & pause & exit /b 1)
  popd
) else (
  echo === 1/2  no .git here - not a clone, publishing the folder as-is ===
)

REM --- 2/2  SFTP the folder up to B -------------------------------------
echo.
echo === 2/2  WinSCP synchronize  -^>  B:/var/www/html/mc-cea ===
"%WINSCP%" /ini=nul /log="%TEMP%\mc-cea-deploy.log" /script="%SITE%\deploy\deploy.winscp.txt" /parameter // "%SITE%"
set RC=%ERRORLEVEL%

echo.
if "%RC%"=="0" (
  echo Deploy OK  -^>  https://mc-cea.ksu.edu.sa/mc-cea/
  echo Quick check from A:  http://B-HOST/mc-cea/
) else (
  echo [!] WinSCP exited with code %RC%  ^(log: %TEMP%\mc-cea-deploy.log^)
  echo     Usual cause: the saved session "B" does not exist yet, or the
  echo     password was not entered. See deploy\readme.md
)
pause
