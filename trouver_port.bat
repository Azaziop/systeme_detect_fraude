@echo off
echo ========================================
echo  Verification des Ports
echo ========================================
echo.

echo Port 8000 (Auth Service):
netstat -aon | findstr :8000 | findstr LISTENING
echo.

echo Port 8001 (Transaction Service):
netstat -aon | findstr :8001 | findstr LISTENING
echo.

echo Port 8002 (Fraud Detection Service):
netstat -aon | findstr :8002 | findstr LISTENING
echo.

pause

