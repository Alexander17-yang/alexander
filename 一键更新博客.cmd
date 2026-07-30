@echo off
chcp 65001 >nul
title Alexander Blog 一键更新
cd /d "%~dp0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-blog.ps1"
set "UPDATE_EXIT=%ERRORLEVEL%"

echo.
if not "%UPDATE_EXIT%"=="0" (
  echo 更新过程中出现问题，请查看上方提示。
) else (
  echo 可以关闭此窗口。
)
pause
exit /b %UPDATE_EXIT%
