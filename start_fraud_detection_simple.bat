@echo off
echo ========================================
echo  Demarrage Fraud Detection Service
echo ========================================
echo.

cd fraud_detection_service

REM Installer si necessaire
pip show fastapi >nul 2>&1
if errorlevel 1 (
    echo Installation des dependances...
    pip install fastapi uvicorn[standard] pydantic numpy scikit-learn joblib
)

REM Verifier le modele
if not exist "..\ml_model\models\isolation_forest_model.pkl" (
    echo Le modele ML n'existe pas. Entrainement...
    cd ..\ml_model
    pip install pandas numpy scikit-learn joblib
    python train_model.py
    cd ..\fraud_detection_service
)

echo.
echo Demarrage sur http://localhost:8002
echo Swagger: http://localhost:8002/docs
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

uvicorn main:app --host 0.0.0.0 --port 8002 --reload

