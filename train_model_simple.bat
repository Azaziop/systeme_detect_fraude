@echo off
echo ========================================
echo  Entrainement du Modele ML (Version Simple)
echo ========================================
echo.

REM Creer le dossier models s'il n'existe pas
if not exist "ml_model\models" mkdir ml_model\models

cd ml_model

echo Installation des dependances...
pip install --upgrade pip
pip install pandas numpy scikit-learn joblib

if errorlevel 1 (
    echo.
    echo [ERREUR] Echec de l'installation.
    echo.
    echo Essayez une de ces solutions:
    echo 1. Utiliser un environnement virtuel:
    echo    python -m venv venv
    echo    venv\Scripts\activate
    echo    pip install pandas numpy scikit-learn joblib
    echo.
    echo 2. Installer Visual Studio Build Tools
    echo    https://visualstudio.microsoft.com/downloads/
    echo.
    pause
    exit /b 1
)

echo.
echo Entrainement du modele...
python train_model.py

if errorlevel 1 (
    echo [ERREUR] Echec de l'entrainement.
    pause
    exit /b 1
)

cd ..
echo.
echo [OK] Modele entraine avec succes!
pause

