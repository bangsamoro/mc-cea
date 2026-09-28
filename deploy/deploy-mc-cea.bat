@echo off
REM ===================================================================
REM  Publish MC-CEA   C  ->  B   over SFTP
REM
REM  Run this ON C. It mirrors the site folder into B's DOCROOT so the
REM  portal becomes the site home page.
REM
REM  How it reaches B:  deploy\connection.local.txt, if it exists,
REM  holds one line with the connection - either a saved WinSCP session
REM  name or a URL:
REM        B
REM        sftp://root@B-HOST/
REM  Without that file it falls back to the saved session named "B".
REM
REM  Where is the site?  By default the folder this script lives in,
REM  i.e. <site>\deploy\deploy-mc-cea.bat -> <site>. Override with:
REM      deploy-mc-cea.bat D:\sites\mc-cea
REM ===================================================================

set "WINSCP=C:\Program Files (x86)\WinSCP\WinSCP.com"

set "SITE=%~1"
if "%SITE%"=="" for %%I in ("%~dp0..") do set "SITE=%%~fI"

REM --- which connection? -------------------------------------------------
set "CONN=B"
if exist "%~dp0connection.local.txt" for /f "usebackq delims=" %%L in ("%~dp0connection.local.txt") do if not "%%L"=="" set "CONN=%%L"
if "%CONN%"=="" set "CONN=B"

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

echo Site folder : %SITE%
echo Connecting  : %CONN%

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
"%WINSCP%" /log="%TEMP%\mc-cea-deploy.log" /script="%SITE%\deploy\deploy.winscp.txt" /parameter // "%SITE%" "%CONN%"
set RC=%ERRORLEVEL%

echo.
if "%RC%"=="0" (
  echo Deploy OK  -^>  the portal is now B's home page.
  echo ifr\, tag\ and phpmyadmin\ were left alone.
) else (
  echo [!] WinSCP exited with code %RC%   log: %TEMP%\mc-cea-deploy.log
  echo.
  echo     "Looking up host" / "Host does not exist"
  echo       -^> the connection could not be resolved. Create deploy\connection.local.txt
  echo          with one line, e.g.   sftp://root@B-HOST/
  echo          (or create a saved WinSCP session named exactly B).
  echo.
  echo     "Authentication failed" or a password prompt
  echo       -^> open that host/session in the WinSCP GUI once and tick
  echo          "Save password".
  echo.
  echo     "Unknown host key" or a host key dialog
  echo       -^> connect once in the WinSCP GUI and accept the key.
)
pause
