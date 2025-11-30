@echo off
echo ========================================
echo  Test Rapide - Tous les Services
echo ========================================
echo.

REM Installer les dependances rapidement
echo Installation des dependances...
pip install Django djangorestframework djangorestframework-simplejwt django-cors-headers drf-spectacular --quiet
pip install fastapi uvicorn pydantic httpx numpy sqlalchemy --quiet
pip install pandas scikit-learn joblib --quiet

echo.
echo Demarrage des services dans des fenetres separees...
echo.

REM Terminal 1 - Auth Service
start "Auth Service (8000)" cmd /k "cd auth_service && set USE_SQLITE=True && python manage.py migrate && python manage.py runserver 0.0.0.0:8000"

timeout /t 5 /nobreak >nul

REM Terminal 2 - Fraud Detection
start "Fraud Detection (8002)" cmd /k "cd fraud_detection_service && uvicorn main:app --host 0.0.0.0 --port 8002"

timeout /t 5 /nobreak >nul

REM Terminal 3 - Transaction
start "Transaction Service (8001)" cmd /k "cd transaction_service && set DATABASE_URL=sqlite:///./transactions.db && uvicorn main:app --host 0.0.0.0 --port 8001"

echo.
echo ========================================
echo  Services demarres!
echo ========================================
echo.
echo Services disponibles:
echo   - Auth:        http://localhost:8000/api/docs/
echo   - Transaction: http://localhost:8001/docs
echo   - Fraud:       http://localhost:8002/docs
echo.
echo Fermez les fenetres pour arreter.
echo.
pause

