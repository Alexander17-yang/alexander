@echo off
setlocal
cd /d "%~dp0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-blog.ps1"
set "UPDATE_EXIT=%ERRORLEVEL%"

echo.
if not "%UPDATE_EXIT%"=="0" (
  echo Update failed. Check the messages above.
) else (
  echo Update completed. You can close this window.
)
pause
exit /b %UPDATE_EXIT%
