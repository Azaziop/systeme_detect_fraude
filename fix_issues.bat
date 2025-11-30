@echo off
echo ========================================
echo  Correction des Problemes
echo ========================================
echo.

echo [1/4] Arret des services...
docker-compose down

echo.
echo [2/4] Verification du modele ML...
if not exist "ml_model\models\isolation_forest_model.pkl" (
    echo Le modele n'existe pas. Entrainement necessaire.
    echo Executez: train_model_simple.bat
    pause
    exit /b 1
)
echo [OK] Modele present.

echo.
echo [3/4] Reconstruction des images avec les corrections...
docker-compose build --no-cache

echo.
echo [4/4] Redemarrage des services...
docker-compose up -d

echo.
echo ========================================
echo  Corrections appliquees!
echo ========================================
echo.
echo Verifiez les logs avec: docker-compose logs -f
echo.
pause

