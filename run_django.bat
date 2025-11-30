@echo off
echo ========================================
echo  Lancement du Service Django
echo ========================================
echo.

REM Verifier que l'environnement virtuel existe
if not exist "venv" (
    echo [ERREUR] Environnement virtuel non trouve.
    echo Executez d'abord: install_django.bat
    pause
    exit /b 1
)

REM Activer l'environnement virtuel
call venv\Scripts\activate.bat

REM Aller dans le dossier auth_service
cd auth_service

REM Verifier que les migrations sont appliquees
echo Verification des migrations...
python manage.py migrate --check >nul 2>&1
if errorlevel 1 (
    echo Application des migrations...
    python manage.py migrate
)

REM Verifier si un superutilisateur existe
echo.
echo Verification du superutilisateur...
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print('Superuser existe' if User.objects.filter(is_superuser=True).exists() else 'Aucun superuser')" 2>nul

echo.
echo ========================================
echo  Demarrage du serveur Django
echo ========================================
echo.
echo Le serveur sera accessible sur: http://localhost:8000
echo Admin: http://localhost:8000/admin/
echo API: http://localhost:8000/api/
echo.
echo Appuyez sur Ctrl+C pour arreter le serveur.
echo.

python manage.py runserver

