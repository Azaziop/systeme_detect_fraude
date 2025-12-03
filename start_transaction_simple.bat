@echo off
echo ========================================
echo  Demarrage Transaction Service
echo ========================================
echo.

REM Activer l'environnement virtuel à la racine du projet
if exist "..\venv\Scripts\activate.bat" (
    call ..\venv\Scripts\activate.bat
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo [ATTENTION] Environnement virtuel non trouve.
    echo Installation des dependances dans l'environnement systeme...
    pip show fastapi >nul 2>&1
    if errorlevel 1 (
        echo Installation des dependances...
        pip install fastapi uvicorn[standard] pydantic httpx numpy sqlalchemy
    )
)

cd transaction_service

REM Celery est optionnel - on peut fonctionner sans
echo Note: Celery est optionnel. Le service fonctionnera sans.

REM Configurer PostgreSQL
if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_NAME%"=="" set DB_NAME=fraud_detection
if "%DB_USER%"=="" set DB_USER=postgres
if "%DB_PASSWORD%"=="" set DB_PASSWORD=postgres
if "%DB_PORT%"=="" set DB_PORT=5432
set FRAUD_DETECTION_SERVICE_URL=http://localhost:8002
set AUTH_SERVICE_URL=http://localhost:8000

echo.
echo Demarrage sur http://localhost:8001
echo Swagger: http://localhost:8001/docs
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

uvicorn main:app --host 0.0.0.0 --port 8001 --reload

