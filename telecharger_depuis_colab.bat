@echo off
echo ========================================
echo  Telechargement du Modele depuis Colab/Drive
echo ========================================
echo.
echo Ce script vous aide a telecharger votre modele Random Forest
echo depuis Google Drive vers ce projet.
echo.
echo Options:
echo 1. Vous avez le lien Google Drive du fichier .pkl
echo 2. Vous avez le File ID du fichier
echo 3. Vous voulez copier manuellement depuis Drive
echo.
pause

cd ml_model

echo Installation de gdown (si necessaire)...
pip install gdown >nul 2>&1

echo.
echo Lancement du script de telechargement...
echo.
python download_model_from_drive.py

echo.
echo ========================================
echo  Verification des fichiers
echo ========================================
if exist "models\random_forest_model.pkl" (
    echo [OK] random_forest_model.pkl trouve
) else (
    echo [ERREUR] random_forest_model.pkl non trouve!
)

if exist "models\scaler.pkl" (
    echo [OK] scaler.pkl trouve
) else (
    echo [INFO] scaler.pkl non trouve (optionnel)
)

if exist "models\feature_columns.json" (
    echo [OK] feature_columns.json trouve
) else (
    echo [INFO] feature_columns.json non trouve (optionnel)
)

echo.
pause

