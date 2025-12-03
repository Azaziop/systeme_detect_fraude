@echo off
echo ========================================
echo  Demarrage de Tous les Services
echo ========================================
echo.
echo Les services vont demarrer dans 3 fenetres separees.
echo.
echo IMPORTANT: Gardez toutes les fenetres ouvertes!
echo.
pause

REM Activer l'environnement virtuel si disponible
if exist "venv\Scripts\activate.bat" (
    set VENV_ACTIVATE=call venv\Scripts\activate.bat &&
) else (
    set VENV_ACTIVATE=
)

echo Demarrage Auth Service...
start "Auth Service (8000)" cmd /k "cd /d %~dp0auth_service && %VENV_ACTIVATE% set USE_SQLITE=True && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"

timeout /t 5 /nobreak >nul

echo Demarrage Fraud Detection Service...
start "Fraud Detection (8002)" cmd /k "cd /d %~dp0fraud_detection_service && %VENV_ACTIVATE% uvicorn main:app --host 0.0.0.0 --port 8002"

timeout /t 5 /nobreak >nul

echo Demarrage Transaction Service...
start "Transaction Service (8001)" cmd /k "cd /d %~dp0transaction_service && %VENV_ACTIVATE% set DATABASE_URL=sqlite:///./transactions.db && set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002 && set AUTH_SERVICE_URL=http://localhost:8000 && uvicorn main:app --host 0.0.0.0 --port 8001"

echo.
echo ========================================
echo  Services Demarres!
echo ========================================
echo.
echo Services disponibles:
echo   - Auth:        http://localhost:8000/api/docs/
echo   - Transaction: http://localhost:8001/docs
echo   - Fraud:       http://localhost:8002/docs
echo.
echo Fermez les fenetres pour arreter les services.
echo.
timeout /t 3 /nobreak >nul

echo Test des services...
timeout /t 5 /nobreak >nul
curl http://localhost:8000/api/users/ 2>nul
curl http://localhost:8001/health 2>nul
curl http://localhost:8002/health 2>nul

echo.
echo Test termine!
pause

