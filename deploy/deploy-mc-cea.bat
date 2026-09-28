@echo off
REM ===================================================================
REM  Publish MC-CEA   C  ->  B   over SFTP
REM
REM  Run this ON C (RDP in from A). It mirrors the site folder into
REM  B's DOCROOT so the portal becomes the site home page.
REM
REM  Where is the site?  By default: the folder this script lives in,
REM  i.e. <site>\deploy\deploy-mc-cea.bat  ->  <site>.  Override with:
REM      deploy-mc-cea.bat D:\sites\mc-cea
REM
REM  Connection: the WinSCP saved session named "B" (see deploy\readme.md).
REM  /ini=nul is deliberately NOT passed - with it WinSCP ignores saved
REM  sessions and "open B" degrades to a hostname lookup.
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
echo === 2/2  WinSCP synchronize  -^>  B:/var/www/html  (docroot) ===
"%WINSCP%" /log="%TEMP%\mc-cea-deploy.log" /script="%SITE%\deploy\deploy.winscp.txt" /parameter // "%SITE%"
set RC=%ERRORLEVEL%

echo.
if "%RC%"=="0" (
  echo Deploy OK  -^>  the portal is now B's home page.
  echo ifr\, tag\ and phpmyadmin\ were left alone.
) else (
  echo [!] WinSCP exited with code %RC%  ^(log: %TEMP%\mc-cea-deploy.log^)
  echo.
  echo     "Host 'B' does not exist." or "session B not found"
  echo       -^> the saved WinSCP session named B has not been created yet.
  echo          Open WinSCP, New Session: SFTP, B's host, port 22, your user,
  echo          Save AS EXACTLY B, tick "Save password", log in once.
  echo.
  echo     "Authentication failed" or a password prompt
  echo       -^> open that saved session in the WinSCP GUI once and tick
  echo          "Save password" so the script can run unattended.
  echo.
  echo     Full log: %TEMP%\mc-cea-deploy.log
)
pause
