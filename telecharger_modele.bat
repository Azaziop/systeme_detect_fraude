@echo off
echo ========================================
echo  Telechargement du Modele Random Forest
echo ========================================
echo.

cd ml_model

echo Installation de gdown (si necessaire)...
pip install gdown >nul 2>&1

echo.
echo Lancement du script de telechargement...
echo.
python download_model_from_drive.py

echo.
pause

