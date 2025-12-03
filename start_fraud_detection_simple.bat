@echo off
echo ========================================
echo  Demarrage Fraud Detection Service
echo ========================================
echo.

REM Activer l'environnement virtuel à la racine du projet
if exist "..\venv\Scripts\activate.bat" (
    call ..\venv\Scripts\activate.bat
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo [ATTENTION] Environnement virtuel non trouve.
    echo Installation des dependances dans l'environnement systeme...
    pip show fastapi >nul 2>&1
    if errorlevel 1 (
        echo Installation des dependances...
        pip install fastapi uvicorn[standard] pydantic numpy scikit-learn joblib
    )
)

cd fraud_detection_service

REM Verifier le modele
if not exist "..\ml_model\models\random_forest_model.pkl" (
    echo [ATTENTION] Le modele Random Forest n'existe pas!
    echo Verifiez que vous avez telecharge le modele depuis Google Drive.
    echo Utilisez: .\telecharger_depuis_colab.bat
    echo.
    pause
)

echo.
echo Demarrage sur http://localhost:8002
echo Swagger: http://localhost:8002/docs
echo.
echo Appuyez sur Ctrl+C pour arreter.
echo.

uvicorn main:app --host 0.0.0.0 --port 8002 --reload

