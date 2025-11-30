@echo off
echo ========================================
echo  Demarrage Transaction Service (FastAPI)
echo ========================================
echo.

cd transaction_service

if not exist "venv" (
    echo [ERREUR] Environnement virtuel non trouve.
    echo Executez d'abord: setup_local.bat
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

REM Configurer les variables d'environnement
if "%FRAUD_DETECTION_SERVICE_URL%"=="" set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002
if "%AUTH_SERVICE_URL%"=="" set AUTH_SERVICE_URL=http://localhost:8000
if "%REDIS_URL%"=="" set REDIS_URL=redis://localhost:6379/0
if "%DATABASE_URL%"=="" set DATABASE_URL=sqlite:///./transactions.db

echo Configuration:
echo   FRAUD_DETECTION_SERVICE_URL=%FRAUD_DETECTION_SERVICE_URL%
echo   AUTH_SERVICE_URL=%AUTH_SERVICE_URL%
echo   DATABASE_URL=%DATABASE_URL%
echo.

echo Demarrage du serveur sur http://localhost:8001
echo Swagger: http://localhost:8001/docs
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

uvicorn main:app --host 0.0.0.0 --port 8001 --reload

