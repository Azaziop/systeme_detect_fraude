@echo off
echo ========================================
echo  Test Simple Sans Docker
echo ========================================
echo.

REM Verifier Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERREUR] Python n'est pas installe.
    pause
    exit /b 1
)

echo [1/3] Installation des dependances...
pip install --upgrade pip
pip install Django==4.2.7 djangorestframework==3.14.0 djangorestframework-simplejwt==5.3.0 django-cors-headers==4.3.1 drf-spectacular==0.26.5
pip install fastapi==0.104.1 uvicorn[standard]==0.24.0 pydantic==2.5.0 httpx==0.25.2 numpy==1.24.3 sqlalchemy==2.0.23
pip install pandas scikit-learn joblib

echo.
echo [2/3] Verification du modele ML...
if not exist "ml_model\models\isolation_forest_model.pkl" (
    echo Entrainement du modele...
    cd ml_model
    python train_model.py
    cd ..
)

echo.
echo [3/3] Configuration des services...
echo.
echo Pour tester, ouvrez 3 terminaux et executez:
echo.
echo Terminal 1 - Auth Service:
echo   cd auth_service
echo   set USE_SQLITE=True
echo   python manage.py migrate
echo   python manage.py runserver 0.0.0.0:8000
echo.
echo Terminal 2 - Fraud Detection Service:
echo   cd fraud_detection_service
echo   uvicorn main:app --host 0.0.0.0 --port 8002
echo.
echo Terminal 3 - Transaction Service:
echo   cd transaction_service
echo   set DATABASE_URL=sqlite:///./transactions.db
echo   uvicorn main:app --host 0.0.0.0 --port 8001
echo.
echo Ou utilisez les scripts: start_auth.bat, start_fraud_detection.bat, start_transaction.bat
echo.
pause

