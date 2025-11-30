@echo off
echo ========================================
echo  Demarrage Auth Service
echo ========================================
echo.

REM S'assurer qu'on est dans le bon dossier
cd /d %~dp0

REM Configurer SQLite
set USE_SQLITE=True

echo Application des migrations...
python manage.py migrate

echo.
echo Demarrage du serveur sur http://localhost:8000
echo Swagger: http://localhost:8000/api/docs/
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

python manage.py runserver 0.0.0.0:8000

