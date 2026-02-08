@echo off
:: ============================================================
:: Overtime Calculator Launcher
:: Runs payCalc.ps1 with execution policy bypass
:: Exit Codes: 0=Success, 1=Script not found
:: ============================================================

:: Use the directory this bat file lives in (portable)
set "SCRIPT_PATH=%~dp0payCalc.ps1"

:: Verify script exists
if not exist "%SCRIPT_PATH%" (
    echo [ERROR] Script not found: %SCRIPT_PATH%
    echo.
    pause
    exit /b 1
)

:: Run PowerShell script
powershell.exe -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_PATH%"

:: Keep window open to see results
pause
