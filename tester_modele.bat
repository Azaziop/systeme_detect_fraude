@echo off
echo ========================================
echo  Test du Modele Random Forest
echo ========================================
echo.

cd ml_model

echo Activation de l'environnement virtuel...
if exist "..\venv\Scripts\activate.bat" (
    call ..\venv\Scripts\activate.bat
) else (
    echo [INFO] Environnement virtuel non trouve, utilisation de Python systeme
)

echo.
echo Installation des dependances si necessaire...
pip install joblib numpy scikit-learn >nul 2>&1

echo.
echo Lancement du test...
echo.
python test_model.py

echo.
pause

