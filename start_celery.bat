@echo off
echo ========================================
echo  Demarrage Celery Worker
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

REM Configurer Redis
if "%REDIS_URL%"=="" set REDIS_URL=redis://localhost:6379/0

echo Configuration:
echo   REDIS_URL=%REDIS_URL%
echo.

echo Demarrage du worker Celery...
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

celery -A celery_app worker --loglevel=info

