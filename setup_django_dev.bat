@echo off
echo ========================================
echo  Configuration Complete Django
echo ========================================
echo.

REM Verifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe.
    pause
    exit /b 1
)

REM Creer l'environnement virtuel si necessaire
if not exist "venv" (
    echo Creation de l'environnement virtuel...
    python -m venv venv
)

REM Activer l'environnement
call venv\Scripts\activate.bat

REM Installer les dependances
echo Installation des dependances...
cd auth_service
pip install --upgrade pip
pip install -r requirements.txt

REM Appliquer les migrations
echo.
echo Application des migrations...
python manage.py migrate

REM Creer un superutilisateur si necessaire
echo.
echo Creation du superutilisateur...
python manage.py shell << EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'admin123')
    print('Superuser cree: admin / admin123')
else:
    print('Superuser existe deja')
EOF

cd ..

echo.
echo ========================================
echo  Configuration terminee!
echo ========================================
echo.
echo Pour lancer Django:
echo   run_django.bat
echo.
echo Ou manuellement:
echo   venv\Scripts\activate
echo   cd auth_service
echo   python manage.py runserver
echo.
pause

