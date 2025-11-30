@echo off
echo ========================================
echo  Demarrage Fraud Detection Service
echo ========================================
echo.

cd fraud_detection_service

if not exist "venv" (
    echo [ERREUR] Environnement virtuel non trouve.
    echo Executez d'abord: setup_local.bat
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

REM Verifier que le modele existe
if not exist "..\ml_model\models\isolation_forest_model.pkl" (
    echo [ERREUR] Modele ML non trouve.
    echo Entrainez d'abord le modele: cd ml_model ^&^& python train_model.py
    pause
    exit /b 1
)

echo Demarrage du serveur sur http://localhost:8002
echo Swagger: http://localhost:8002/docs
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

uvicorn main:app --host 0.0.0.0 --port 8002 --reload

