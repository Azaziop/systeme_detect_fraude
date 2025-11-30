@echo off
echo ========================================
echo  Test Direct Sans Docker - Sans Venv
echo ========================================
echo.

REM Installer les dependances globalement (rapide)
echo Installation des dependances...
pip install Django djangorestframework djangorestframework-simplejwt django-cors-headers drf-spectacular --quiet
pip install fastapi uvicorn pydantic httpx numpy sqlalchemy --quiet
pip install pandas scikit-learn joblib --quiet

echo.
echo Verification du modele ML...
if not exist "ml_model\models\isolation_forest_model.pkl" (
    echo Entrainement du modele...
    cd ml_model
    python train_model.py
    cd ..
)

echo.
echo ========================================
echo  Lancement des Services
echo ========================================
echo.
echo Les services vont demarrer dans 3 fenetres separees...
echo.

REM Auth Service
start "Auth Service (8000)" cmd /k "cd auth_service && set USE_SQLITE=True && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"

timeout /t 3 /nobreak >nul

REM Fraud Detection
start "Fraud Detection (8002)" cmd /k "cd fraud_detection_service && uvicorn main:app --host 0.0.0.0 --port 8002"

timeout /t 3 /nobreak >nul

REM Transaction
start "Transaction Service (8001)" cmd /k "cd transaction_service && set DATABASE_URL=sqlite:///./transactions.db && uvicorn main:app --host 0.0.0.0 --port 8001"

echo.
echo ========================================
echo  Services Demarres!
echo ========================================
echo.
echo Acces:
echo   Auth:        http://localhost:8000/api/docs/
echo   Transaction: http://localhost:8001/docs
echo   Fraud:       http://localhost:8002/docs
echo.
echo Fermez les fenetres pour arreter.
echo.
timeout /t 5 /nobreak >nul

echo Test des services...
curl http://localhost:8000/api/users/ 2>nul
curl http://localhost:8001/health 2>nul
curl http://localhost:8002/health 2>nul

echo.
echo Test termine! Les services sont actifs.
pause

