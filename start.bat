@echo off
setlocal enabledelayedexpansion
echo ========================================
echo  Demarrage du Systeme de Detection de Fraude
echo ========================================
echo.

REM Verifier si Docker est en cours d'execution
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Docker n'est pas demarre ou n'est pas accessible.
    echo Veuillez demarrer Docker Desktop et reessayer.
    pause
    exit /b 1
)

echo [1/3] Verification du modele ML...

REM Creer le dossier models s'il n'existe pas
if not exist "ml_model\models" mkdir ml_model\models

if not exist "ml_model\models\isolation_forest_model.pkl" (
    echo Le modele n'existe pas. Entrainement en cours...
    cd ml_model
    echo Installation des dependances - cela peut prendre quelques minutes...
    pip install --upgrade pip
    pip install -r requirements.txt
    if errorlevel 1 (
        echo.
        echo [ATTENTION] Echec avec les versions specifiees.
        echo Tentative avec des versions precompilees...
        pip install pandas numpy scikit-learn joblib
        if errorlevel 1 (
            echo [ERREUR] Echec de l'installation des dependances.
            echo.
            echo Solutions alternatives:
            echo 1. Utilisez train_model_simple.bat
            echo 2. Installez Visual Studio Build Tools
            echo 3. Utilisez un environnement virtuel
            echo.
            echo Voir INSTALL_WINDOWS.md pour plus de details.
            cd ..
            pause
            exit /b 1
        )
    )
    python train_model.py
    if errorlevel 1 (
        echo [ERREUR] Echec de l'entrainement du modele.
        cd ..
        pause
        exit /b 1
    )
    cd ..
    echo [OK] Modele entraine avec succes!
) else (
    echo [OK] Modele deja present.
)

echo.
echo [2/3] Construction des images Docker...
docker-compose build
if errorlevel 1 (
    echo [ERREUR] Echec de la construction des images.
    pause
    exit /b 1
)
echo [OK] Images construites avec succes!

echo.
echo [3/3] Demarrage des services...
docker-compose up -d
if errorlevel 1 (
    echo [ERREUR] Echec du demarrage des services.
    pause
    exit /b 1
)

echo.
echo ========================================
echo  Services demarres avec succes!
echo ========================================
echo.
echo Services disponibles:
echo   - Auth Service:        http://localhost:8000
echo   - Transaction Service:  http://localhost:8001
echo   - Fraud Detection:      http://localhost:8002
echo.
echo Pour voir les logs: docker-compose logs -f
echo Pour arreter: docker-compose down
echo.
pause
