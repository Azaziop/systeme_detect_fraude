@echo off
echo ========================================
echo  Demarrage Transaction Service
echo ========================================
echo.

cd transaction_service

REM Installer si necessaire
pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo Installation des dependances...
    pip install fastapi uvicorn[standard] pydantic httpx numpy sqlalchemy
)

REM Celery est optionnel - on peut fonctionner sans
echo Note: Celery est optionnel. Le service fonctionnera sans.

REM Configurer
set DATABASE_URL=sqlite:///./transactions.db
set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002
set AUTH_SERVICE_URL=http://localhost:8000

echo.
echo Demarrage sur http://localhost:8001
echo Swagger: http://localhost:8001/docs
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

uvicorn main:app --host 0.0.0.0 --port 8001 --reload

