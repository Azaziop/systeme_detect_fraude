@echo off
echo ========================================
echo  Demarrage Simple - Detection de Fraude
echo ========================================
echo.

REM Verifier Docker
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Docker n'est pas demarre.
    echo Demarrez Docker Desktop et reessayez.
    pause
    exit /b 1
)

REM Creer le dossier models s'il n'existe pas
if not exist "ml_model\models" mkdir ml_model\models

REM Entrainer le modele si necessaire
if not exist "ml_model\models\isolation_forest_model.pkl" (
    echo Entrainement du modele...
    call train_model_simple.bat
    if errorlevel 1 (
        echo [ERREUR] Echec de l'entrainement.
        pause
        exit /b 1
    )
)

REM Construire et lancer Docker
echo Construction des images Docker...
docker-compose build
if errorlevel 1 (
    echo [ERREUR] Echec de la construction.
    pause
    exit /b 1
)

echo Demarrage des services...
docker-compose up -d
if errorlevel 1 (
    echo [ERREUR] Echec du demarrage.
    pause
    exit /b 1
)

echo.
echo [OK] Services demarres!
echo.
echo Services:
echo   http://localhost:8000 - Auth
echo   http://localhost:8001 - Transaction
echo   http://localhost:8002 - Fraud Detection
echo.
pause

