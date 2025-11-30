@echo off
echo ========================================
echo  Demarrage de Tous les Services
echo ========================================
echo.
echo Ce script va lancer tous les services dans des fenetres separees.
echo.
pause

REM Lancer Auth Service
start "Auth Service" cmd /k "start_auth.bat"

timeout /t 3 /nobreak >nul

REM Lancer Fraud Detection Service
start "Fraud Detection Service" cmd /k "start_fraud_detection.bat"

timeout /t 3 /nobreak >nul

REM Lancer Transaction Service
start "Transaction Service" cmd /k "start_transaction.bat"

timeout /t 3 /nobreak >nul

REM Lancer Celery Worker (optionnel)
echo.
echo Voulez-vous lancer Celery Worker? (O/N)
set /p launch_celery=
if /i "%launch_celery%"=="O" (
    start "Celery Worker" cmd /k "start_celery.bat"
)

echo.
echo ========================================
echo  Services demarres!
echo ========================================
echo.
echo Services disponibles:
echo   - Auth Service:        http://localhost:8000/api/docs/
echo   - Transaction Service:  http://localhost:8001/docs
echo   - Fraud Detection:      http://localhost:8002/docs
echo.
echo Fermez les fenetres pour arreter les services.
echo.

