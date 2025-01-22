@echo off
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO ELEVATE >nul
GOTO ADMINTASKS

:ELEVATE
CD /d %~dp0 >nul
MSHTA "javascript: var shell = new ActiveXObject('shell.application'); shell.ShellExecute('%~nx0', '', '', 'runas', 1);close();" >nul
EXIT

:ADMINTASKS
REG ADD HKCU\Software\Policies\Microsoft\Windows\Explorer /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f >nul 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO FAILURE >nul
sc query "wsearch" | FIND /i "RUNNING" >nul 2>&1
IF ERRORLEVEL 1 sc config "wsearch" start=delayed-auto >nul 2>&1 && sc start "wsearch" >nul 2>&1
IF ERRORLEVEL 0 GOTO SUCCESS >nul
GOTO FAILURE >n
EXIT

:SUCCESS
echo Indexing has been enabled and internet search suggestions have been disabled.
echo **Restart to take effect.**
pause >nul
EXIT

:FAILURE
echo Failed to fix Windows search. Please try again.
pause >nul
EXIT

