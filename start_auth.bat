@echo off
echo ========================================
echo  Demarrage Auth Service (Django)
echo ========================================
echo.

REM Activer l'environnement virtuel à la racine du projet
if exist "..\venv\Scripts\activate.bat" (
    call ..\venv\Scripts\activate.bat
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo [ATTENTION] Environnement virtuel non trouve.
    echo Tentative avec Python systeme...
)

cd auth_service

REM Configurer les variables d'environnement PostgreSQL
if "%DB_HOST%"=="" set DB_HOST=localhost
if "%DB_NAME%"=="" set DB_NAME=fraud_detection
if "%DB_USER%"=="" set DB_USER=postgres
if "%DB_PASSWORD%"=="" set DB_PASSWORD=postgres
if "%DB_PORT%"=="" set DB_PORT=5432
if "%REDIS_URL%"=="" set REDIS_URL=redis://localhost:6379/1

echo Configuration PostgreSQL:
echo   DB_HOST=%DB_HOST%
echo   DB_NAME=%DB_NAME%
echo   DB_USER=%DB_USER%
echo   DB_PORT=%DB_PORT%
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

