@echo off
echo ========================================
echo  Demarrage Auth Service (Django)
echo ========================================
echo.

cd auth_service

if not exist "venv" (
    echo [ERREUR] Environnement virtuel non trouve.
    echo Executez d'abord: setup_local.bat
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

REM Configurer les variables d'environnement
if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_NAME%"=="" set DB_NAME=fraud_detection
if "%DB_USER%"=="" set DB_USER=postgres
if "%DB_PASSWORD%"=="" set DB_PASSWORD=postgres
if "%USE_SQLITE%"=="" set USE_SQLITE=True
if "%REDIS_URL%"=="" set REDIS_URL=redis://localhost:6379/1

echo Configuration:
echo   DB_HOST=%DB_HOST%
echo   USE_SQLITE=%USE_SQLITE%
echo.

echo Application des migrations...
python manage.py migrate

echo.
echo Demarrage du serveur sur http://localhost:8000
echo Swagger: http://localhost:8000/api/docs/
echo Admin: http://localhost:8000/admin/
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

python manage.py runserver 0.0.0.0:8000

