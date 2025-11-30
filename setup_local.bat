@echo off
echo ========================================
echo  Installation Locale (Sans Docker)
echo ========================================
echo.

REM Verifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe.
    pause
    exit /b 1
)

echo [1/4] Installation Auth Service...
cd auth_service
if not exist "venv" (
    python -m venv venv
)
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install -r requirements.txt
cd ..

echo.
echo [2/4] Installation Transaction Service...
cd transaction_service
if not exist "venv" (
    python -m venv venv
)
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install -r requirements.txt
cd ..

echo.
echo [3/4] Installation Fraud Detection Service...
cd fraud_detection_service
if not exist "venv" (
    python -m venv venv
)
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install -r requirements.txt
cd ..

echo.
echo [4/4] Verification du modele ML...
if not exist "ml_model\models\isolation_forest_model.pkl" (
    echo Le modele n'existe pas. Entrainement...
    cd ml_model
    pip install -r requirements.txt
    python train_model.py
    cd ..
)

echo.
echo ========================================
echo  Installation terminee!
echo ========================================
echo.
echo Pour lancer les services:
echo   start_auth.bat
echo   start_transaction.bat
echo   start_fraud_detection.bat
echo   start_celery.bat (optionnel)
echo.
pause

