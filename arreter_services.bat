@echo off
echo ========================================
echo  Arret des Services
echo ========================================
echo.

echo Recherche des processus sur les ports 8000, 8001, 8002...
echo.

REM Trouver et arreter les processus sur le port 8000
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8000 ^| findstr LISTENING') do (
    echo Arret du processus sur le port 8000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

REM Trouver et arreter les processus sur le port 8001
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8001 ^| findstr LISTENING') do (
    echo Arret du processus sur le port 8001 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

REM Trouver et arreter les processus sur le port 8002
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8002 ^| findstr LISTENING') do (
    echo Arret du processus sur le port 8002 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

echo.
echo ========================================
echo  Arret termine
echo ========================================
echo.
pause

