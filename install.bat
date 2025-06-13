@echo off
REM -----------------------------------------------
REM Batch file to run install.ps1 with Bypass policy
REM -----------------------------------------------

REM Change directory to the folder containing this .bat
pushd "%~dp0"

REM Run the PowerShell script with no profile and bypass execution policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

REM Return to original folder
popd

REM Pause so you can read any errors/output
pause
