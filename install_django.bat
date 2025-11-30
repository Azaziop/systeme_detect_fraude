@echo off
echo ========================================
echo  Installation de Django et Dependances
echo ========================================
echo.

REM Verifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe ou n'est pas dans le PATH.
    echo Veuillez installer Python 3.9+ depuis https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [OK] Python detecte
python --version

echo.
echo [1/4] Mise a jour de pip...
python -m pip install --upgrade pip

echo.
echo [2/4] Creation de l'environnement virtuel...
if exist "venv" (
    echo Environnement virtuel deja present.
) else (
    python -m venv venv
    if errorlevel 1 (
        echo [ERREUR] Echec de la creation de l'environnement virtuel.
        pause
        exit /b 1
    )
    echo [OK] Environnement virtuel cree.
)

echo.
echo [3/4] Activation de l'environnement virtuel...
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo [ERREUR] Echec de l'activation de l'environnement virtuel.
    pause
    exit /b 1
)

echo.
echo [4/4] Installation de Django et des dependances...
cd auth_service
pip install -r requirements.txt
if errorlevel 1 (
    echo [ERREUR] Echec de l'installation des dependances.
    cd ..
    pause
    exit /b 1
)
cd ..

echo.
echo ========================================
echo  Installation terminee avec succes!
echo ========================================
echo.
echo Pour utiliser Django:
echo 1. Activez l'environnement virtuel: venv\Scripts\activate
echo 2. Allez dans auth_service: cd auth_service
echo 3. Lancez les migrations: python manage.py migrate
echo 4. Creez un superutilisateur: python manage.py createsuperuser
echo 5. Lancez le serveur: python manage.py runserver
echo.
echo Ou utilisez le script: run_django.bat
echo.
pause

